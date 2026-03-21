import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';
import '../services/sip_pdf.dart';
import '../widgets/banner_ad_widget.dart';

class SipCalculatorScreen extends StatefulWidget {
  const SipCalculatorScreen({Key? key}) : super(key: key);
  @override
  State<SipCalculatorScreen> createState() => _SipCalculatorScreenState();
}

class _SipCalculatorScreenState extends State<SipCalculatorScreen> {
  double _monthly = 5000, _rate = 12, _years = 10;

  double get _totalInv => _monthly * _years * 12;
  double get _fv {
    double r = _rate / 100 / 12; int n = (_years * 12).round();
    if (r == 0 || n == 0) return _totalInv;
    return _monthly * (pow(1 + r, n) - 1) / r * (1 + r);
  }
  double get _ret => _fv - _totalInv;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SIP Calculator'), actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf_rounded),
          tooltip: 'Export PDF',
          onPressed: () => SipPdfGenerator.generateAndShare(context,
              monthly: _monthly, rate: _rate, years: _years),
        ),
      ]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ResultCard(children: [
          Text('Total Value', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 4),
          Text(formatRupee(_fv), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('+${formatRupee(_ret)} returns (${(_ret / max(_totalInv, 1) * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(color: Color(0xFF48BB78), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            MiniStat('Invested', formatRupee(_totalInv), Colors.white.withOpacity(0.8)),
            MiniStat('Returns', formatRupee(_ret), const Color(0xFF48BB78)),
          ]),
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: Row(children: [
            Expanded(flex: (_totalInv / max(_fv, 1) * 100).round().clamp(1, 99), child: Container(height: 8, color: Colors.white.withOpacity(0.3))),
            Expanded(flex: (_ret / max(_fv, 1) * 100).round().clamp(1, 99), child: Container(height: 8, color: const Color(0xFF48BB78))),
          ])),
        ]),
        const SizedBox(height: 20),
        SliderCard(label: 'Monthly SIP Amount', value: _monthly, displayValue: formatRupee(_monthly),
            min: 500, max: 100000, color: AppColors.accent, onChanged: (v) => setState(() => _monthly = v.roundToDouble())),
        SliderCard(label: 'Expected Returns (p.a.)', value: _rate, displayValue: '${_rate.toStringAsFixed(1)}%',
            min: 1, max: 30, color: AppColors.success, onChanged: (v) => setState(() => _rate = v)),
        SliderCard(label: 'Time Period', value: _years, displayValue: '${_years.round()} years',
            min: 1, max: 40, color: AppColors.warning, onChanged: (v) => setState(() => _years = v.roundToDouble())),
        const SizedBox(height: 12),

        // PDF Export Button
        Row(children: [
          Expanded(child: ActionButton(icon: Icons.picture_as_pdf_rounded, label: 'Save PDF',
              onTap: () => SipPdfGenerator.generateAndShare(context, monthly: _monthly, rate: _rate, years: _years))),
          const SizedBox(width: 10),
          Expanded(child: ActionButton(icon: Icons.share_rounded, label: 'Share',
              onTap: () => SipPdfGenerator.generateAndShare(context, monthly: _monthly, rate: _rate, years: _years))),
        ]),
        const SizedBox(height: 16),

        const Text('Year-wise Growth', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 10),
        _YearTable(monthly: _monthly, rate: _rate, years: _years.round()),
        const SizedBox(height: 16),
        const BannerAdWidget(),
        const SizedBox(height: 8),
      ])),
    );
  }
}

class _YearTable extends StatelessWidget {
  final double monthly, rate; final int years;
  const _YearTable({required this.monthly, required this.rate, required this.years});

  @override
  Widget build(BuildContext context) {
    List<int> ms = [];
    for (int y = 5; y <= years; y += 5) ms.add(y);
    if (!ms.contains(years) && years > 0) ms.add(years);
    if (ms.isEmpty && years > 0) ms.add(years);

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
      child: Column(children: ms.asMap().entries.map((e) {
        int y = e.value, n = y * 12; double r = rate / 100 / 12;
        double inv = monthly * n;
        double fv = r > 0 ? monthly * (pow(1 + r, n) - 1) / r * (1 + r) : inv;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: e.key % 2 == 0 ? Colors.white : AppColors.bg,
              border: e.key < ms.length - 1 ? const Border(bottom: BorderSide(color: AppColors.borderLight)) : null),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Year $y', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
            Text(formatRupee(inv), style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            Text(formatRupee(fv), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
          ]),
        );
      }).toList()),
    );
  }
}
