import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/banner_ad_widget.dart';

class CostOfDelayScreen extends StatefulWidget {
  const CostOfDelayScreen({Key? key}) : super(key: key);

  @override
  State<CostOfDelayScreen> createState() => _CostOfDelayScreenState();
}

class _CostOfDelayScreenState extends State<CostOfDelayScreen> {
  double _monthly = 5000;
  double _returnRate = 12;
  double _totalYears = 20;
  double _delayYears = 3;

  _DelayResult _calculate() {
    final double r = _returnRate / 100 / 12;
    final int totalMonths = (_totalYears * 12).round();
    final int delayMonths = (_delayYears * 12).round();
    final int investMonths = (totalMonths - delayMonths).clamp(0, totalMonths);

    // Without delay: invest full period
    double withoutDelay = r == 0
        ? _monthly * totalMonths
        : _monthly * (pow(1 + r, totalMonths) - 1) / r * (1 + r);
    double investedWithout = _monthly * totalMonths;

    // With delay: invest shorter, then same end date
    double withDelay = r == 0
        ? _monthly * investMonths
        : _monthly * (pow(1 + r, investMonths) - 1) / r * (1 + r);
    double investedWith = _monthly * investMonths;

    final double opportunityCost = withoutDelay - withDelay;
    final double extraInvestedWithout = investedWithout - investedWith;

    // Year-by-year comparison
    final List<_DelayRow> table = [];
    for (int y = 1; y <= _totalYears.toInt(); y++) {
      final int m = y * 12;
      // Without delay value
      final double wov = r == 0 ? _monthly * m : _monthly * (pow(1 + r, m) - 1) / r * (1 + r);
      // With delay value (only starts after delay)
      final int activeMonths = (m - delayMonths).clamp(0, m);
      final double wdv = activeMonths > 0
          ? (r == 0 ? _monthly * activeMonths : _monthly * (pow(1 + r, activeMonths) - 1) / r * (1 + r))
          : 0.0;
      table.add(_DelayRow(year: y, withoutDelay: wov, withDelay: wdv));
    }

    return _DelayResult(
      withoutDelay: withoutDelay,
      withDelay: withDelay,
      opportunityCost: opportunityCost,
      investedWithout: investedWithout,
      investedWith: investedWith,
      extraInvested: extraInvestedWithout,
      table: table,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _calculate();

    return Scaffold(
      appBar: AppBar(title: const Text('Cost of Delay')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Result card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryLight]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              const Text('Opportunity Cost of Delay', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(formatRupee(result.opportunityCost), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              Text('by delaying ${_delayYears.toInt()} years', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _Pill('Start Now', formatRupee(result.withoutDelay), AppColors.success.withOpacity(0.3))),
                const SizedBox(width: 8),
                Expanded(child: _Pill('Start in ${_delayYears.toInt()} yrs', formatRupee(result.withDelay), AppColors.danger.withOpacity(0.3))),
              ]),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  'Delaying ${_delayYears.toInt()} year${_delayYears.toInt() > 1 ? "s" : ""} costs you ${formatRupee(result.opportunityCost)} — even though you invest ${formatRupee(result.extraInvested)} more by starting now.',
                  style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          SliderCard(
            label: 'Monthly SIP Amount',
            value: _monthly,
            min: 500,
            max: 100000,
            divisions: 199,
            format: formatRupee,
            color: AppColors.accent,
            onChanged: (v) => setState(() => _monthly = (v / 500).round() * 500.0),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Expected Return (p.a.)',
            value: _returnRate,
            min: 6,
            max: 20,
            divisions: 140,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.success,
            onChanged: (v) => setState(() => _returnRate = v),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Total Investment Period',
            value: _totalYears,
            min: 5,
            max: 40,
            divisions: 35,
            format: (v) => '${v.toInt()} yrs',
            color: AppColors.warning,
            onChanged: (v) => setState(() {
              _totalYears = v;
              if (_delayYears >= _totalYears) _delayYears = _totalYears - 1;
            }),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Delay Period',
            value: _delayYears,
            min: 1,
            max: (_totalYears - 1).clamp(1, 15),
            divisions: ((_totalYears - 2).clamp(1, 14)).toInt(),
            format: (v) => '${v.toInt()} yr${v.toInt() > 1 ? "s" : ""}',
            color: AppColors.danger,
            onChanged: (v) => setState(() => _delayYears = v),
          ),
          const SizedBox(height: 16),

          // Summary stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
            child: Column(children: [
              DetailRow(label: 'Invested (Start Now)', value: formatRupee(result.investedWithout)),
              DetailRow(label: 'Invested (With Delay)', value: formatRupee(result.investedWith)),
              DetailRow(label: 'Extra Invested (Start Now)', value: formatRupee(result.extraInvested)),
              const Divider(height: 20),
              DetailRow(label: 'Corpus (Start Now)', value: formatRupee(result.withoutDelay), isBold: true),
              DetailRow(label: 'Corpus (With Delay)', value: formatRupee(result.withDelay)),
              DetailRow(label: 'Opportunity Cost', value: formatRupee(result.opportunityCost), isBold: true, valueColor: AppColors.danger),
            ]),
          ),
          const SizedBox(height: 16),

          // Year-wise table
          _YearTable(rows: result.table, delayYears: _delayYears.toInt()),
          const BannerAdWidget(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label; final String value; final Color bg;
  const _Pill(this.label, this.value, this.bg);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _YearTable extends StatelessWidget {
  final List<_DelayRow> rows;
  final int delayYears;
  const _YearTable({required this.rows, required this.delayYears});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Growth Comparison', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Expanded(flex: 1, child: Text('Year', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
            Expanded(flex: 3, child: Text('Start Now', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            Expanded(flex: 3, child: Text('With Delay', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          ]),
        ),
        ...rows.asMap().entries.map((e) {
          final r = e.value;
          final even = e.key % 2 == 0;
          final isDelayStart = r.year == delayYears + 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: isDelayStart ? AppColors.warningLight : (even ? AppColors.bg : Colors.white),
            child: Row(children: [
              Expanded(flex: 1, child: Text('${r.year}', style: const TextStyle(fontSize: 11, color: AppColors.textMed))),
              Expanded(flex: 3, child: Text(formatShortIndian(r.withoutDelay), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success), textAlign: TextAlign.right)),
              Expanded(flex: 3, child: Text(r.withDelay > 0 ? formatShortIndian(r.withDelay) : '—', style: const TextStyle(fontSize: 11, color: AppColors.textMed), textAlign: TextAlign.right)),
            ]),
          );
        }),
      ]),
    );
  }
}

class _DelayResult {
  final double withoutDelay, withDelay, opportunityCost, investedWithout, investedWith, extraInvested;
  final List<_DelayRow> table;
  _DelayResult({required this.withoutDelay, required this.withDelay, required this.opportunityCost, required this.investedWithout, required this.investedWith, required this.extraInvested, required this.table});
}

class _DelayRow {
  final int year;
  final double withoutDelay, withDelay;
  _DelayRow({required this.year, required this.withoutDelay, required this.withDelay});
}
