import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';

class FdVsSipScreen extends StatefulWidget {
  const FdVsSipScreen({Key? key}) : super(key: key);

  @override
  State<FdVsSipScreen> createState() => _FdVsSipScreenState();
}

class _FdVsSipScreenState extends State<FdVsSipScreen> {
  double _amount = 10000; // Monthly investment for SIP / Lump sum for FD
  bool _isMonthly = true; // true = monthly SIP vs monthly FD
  double _fdRate = 7;
  double _sipReturn = 12;
  double _years = 10;

  @override
  Widget build(BuildContext context) {
    final int months = (_years * 12).round();
    final double r = _sipReturn / 100 / 12;

    // SIP maturity
    final double sipMaturity = r == 0
        ? _amount * months
        : _amount * (pow(1 + r, months) - 1) / r * (1 + r);
    final double sipInvested = _amount * months;

    // FD maturity (quarterly compounding on cumulative deposit)
    // For monthly: treat all deposits as lump sum (conservative)
    // FD with quarterly compounding
    final double fdTotal = _isMonthly ? _amount * months : _amount;
    final double fdMaturity = fdTotal * pow(1 + _fdRate / 100 / 4, 4 * _years);

    final double sipAdvantage = sipMaturity - fdMaturity;

    // Crossover: year where SIP overtakes FD
    int crossoverYear = -1;
    for (int y = 1; y <= _years.toInt(); y++) {
      final int m = y * 12;
      final double sipVal = r == 0 ? _amount * m : _amount * (pow(1 + r, m) - 1) / r * (1 + r);
      final double fdVal = (_isMonthly ? _amount * m : _amount) * pow(1 + _fdRate / 100 / 4, 4.0 * y);
      if (sipVal > fdVal && crossoverYear == -1) {
        crossoverYear = y;
      }
    }

    // Year-wise comparison table
    final List<_CompareRow> table = [];
    for (int y = 1; y <= _years.toInt(); y++) {
      final int m = y * 12;
      final double sv = r == 0 ? _amount * m : _amount * (pow(1 + r, m) - 1) / r * (1 + r);
      final double fv = (_isMonthly ? _amount * m : _amount) * pow(1 + _fdRate / 100 / 4, 4.0 * y);
      table.add(_CompareRow(year: y, sipValue: sv, fdValue: fv));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('FD vs SIP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Result card
          _ResultCard(
            sipMaturity: sipMaturity,
            fdMaturity: fdMaturity,
            sipAdvantage: sipAdvantage,
            crossoverYear: crossoverYear,
          ),
          const SizedBox(height: 16),

          // Investment type toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              _Toggle('Monthly SIP vs RD', _isMonthly, () => setState(() => _isMonthly = true)),
              _Toggle('Lump Sum', !_isMonthly, () => setState(() => _isMonthly = false)),
            ]),
          ),
          const SizedBox(height: 12),

          SliderCard(
            label: _isMonthly ? 'Monthly Investment' : 'Lump Sum Amount',
            value: _amount,
            min: 1000,
            max: 100000,
            divisions: 99,
            format: formatRupee,
            color: AppColors.accent,
            onChanged: (v) => setState(() => _amount = (v / 1000).round() * 1000.0),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'FD Rate (p.a.)',
            value: _fdRate,
            min: 4,
            max: 10,
            divisions: 60,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.textMed,
            onChanged: (v) => setState(() => _fdRate = v),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'SIP Expected Return (p.a.)',
            value: _sipReturn,
            min: 8,
            max: 25,
            divisions: 170,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.success,
            onChanged: (v) => setState(() => _sipReturn = v),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Time Period',
            value: _years,
            min: 1,
            max: 30,
            divisions: 29,
            format: (v) => '${v.toInt()} yrs',
            color: AppColors.warning,
            onChanged: (v) => setState(() => _years = v),
          ),
          const SizedBox(height: 16),

          // Year-wise table
          _ComparisonTable(rows: table, crossoverYear: crossoverYear),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _Toggle(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textMed))),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final double sipMaturity, fdMaturity, sipAdvantage;
  final int crossoverYear;
  const _ResultCard({required this.sipMaturity, required this.fdMaturity, required this.sipAdvantage, required this.crossoverYear});

  @override
  Widget build(BuildContext context) {
    final bool sipWins = sipAdvantage > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryLight]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        Text(sipWins ? 'SIP Wins by' : 'FD Wins by', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(formatRupee(sipAdvantage.abs()), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
        if (crossoverYear > 0 && crossoverYear < 99)
          Text('SIP overtakes FD in Year $crossoverYear', style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _Pill('SIP Maturity', formatRupee(sipMaturity), AppColors.success.withOpacity(0.3))),
          const SizedBox(width: 8),
          Expanded(child: _Pill('FD Maturity', formatRupee(fdMaturity), AppColors.textMed.withOpacity(0.4))),
        ]),
      ]),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final List<_CompareRow> rows;
  final int crossoverYear;
  const _ComparisonTable({required this.rows, required this.crossoverYear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Year-wise Comparison', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Expanded(flex: 1, child: Text('Year', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
            Expanded(flex: 3, child: Text('SIP', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            Expanded(flex: 3, child: Text('FD', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          ]),
        ),
        ...rows.asMap().entries.map((e) {
          final r = e.value;
          final even = e.key % 2 == 0;
          final isCross = r.year == crossoverYear;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: isCross ? AppColors.successLight : (even ? AppColors.bg : Colors.white),
            child: Row(children: [
              Expanded(flex: 1, child: Row(children: [
                Text('${r.year}', style: const TextStyle(fontSize: 11, color: AppColors.textMed)),
                if (isCross) const Text(' ⭐', style: TextStyle(fontSize: 10)),
              ])),
              Expanded(flex: 3, child: Text(formatShortIndian(r.sipValue),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: r.sipValue >= r.fdValue ? AppColors.success : AppColors.text), textAlign: TextAlign.right)),
              Expanded(flex: 3, child: Text(formatShortIndian(r.fdValue),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: r.fdValue > r.sipValue ? AppColors.success : AppColors.textMed), textAlign: TextAlign.right)),
            ]),
          );
        }),
      ]),
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _CompareRow {
  final int year;
  final double sipValue, fdValue;
  _CompareRow({required this.year, required this.sipValue, required this.fdValue});
}
