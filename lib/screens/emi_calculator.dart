import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';
import '../services/emi_pdf.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/premium_manager.dart';
import '../services/nudge_service.dart';
import '../widgets/premium_nudge_sheet.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({Key? key}) : super(key: key);
  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  double _loan = 5000000, _rate = 8.5, _tenure = 20;
  int _type = 0;

  @override
  void initState() {
    super.initState();
    // Nudge #3: show prepayment nudge when interest is high
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!PremiumManager.isPremium && _interest > 100000) {
        await PremiumNudgeSheet.showIfEligible(
          context,
          nudgeId: 'emi_high_interest',
          headline: 'Save Lakhs on Interest!',
          body: 'Prepayment could save you ${formatRupee(_interest * 0.2)}+ in interest.\nUnlock the Loan Prepayment Simulator.',
          ctaLabel: 'Unlock Prepayment Simulator',
        );
      }
    });
  }

  static const _typeNames = ['Home', 'Car', 'Personal'];

  double get _mr => _rate / 100 / 12;
  int get _months => (_tenure * 12).round();
  double get _emi { if (_mr == 0 || _months == 0) return 0; double f = pow(1 + _mr, _months).toDouble(); return _loan * _mr * f / (f - 1); }
  double get _total => _emi * _months;
  double get _interest => _total - _loan;

  @override
  Widget build(BuildContext context) {
    double pp = _total > 0 ? _loan / _total : 0.5;
    return Scaffold(
      appBar: AppBar(title: const Text('EMI Calculator'), actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf_rounded),
          tooltip: 'Export PDF',
          onPressed: () => _exportPdf(),
        ),
      ]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(children: [_tab('🏠 Home', 0), const SizedBox(width: 8), _tab('🚗 Car', 1), const SizedBox(width: 8), _tab('💳 Personal', 2)]),
        const SizedBox(height: 16),
        ResultCard(children: [
          Text('Monthly EMI', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 4),
          Text(formatRupee(_emi), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: Row(children: [
            Expanded(flex: (pp * 100).round().clamp(1, 99), child: Container(height: 12, color: const Color(0xFF48BB78))),
            Expanded(flex: ((1 - pp) * 100).round().clamp(1, 99), child: Container(height: 12, color: const Color(0xFFFC8181))),
          ])),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Stat(const Color(0xFF48BB78), 'Principal', formatRupee(_loan)),
            _Stat(const Color(0xFFFC8181), 'Interest', formatRupee(_interest)),
          ]),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('Total: ${formatRupee(_total)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 16),

        // PDF/Share buttons
        Row(children: [
          Expanded(child: ActionButton(icon: Icons.picture_as_pdf_rounded, label: 'Save PDF', onTap: _exportPdf)),
          const SizedBox(width: 10),
          Expanded(child: ActionButton(icon: Icons.share_rounded, label: 'Share', onTap: _exportPdf)),
        ]),
        const SizedBox(height: 16),

        SliderCard(label: 'Loan Amount', value: _loan, displayValue: formatRupee(_loan),
            min: 100000, max: _type == 0 ? 50000000 : (_type == 1 ? 5000000 : 2000000),
            color: AppColors.accent, onChanged: (v) => setState(() => _loan = (v / 10000).round() * 10000)),
        SliderCard(label: 'Interest Rate (p.a.)', value: _rate, displayValue: '${_rate.toStringAsFixed(1)}%',
            min: 1, max: 30, color: AppColors.warning, onChanged: (v) => setState(() => _rate = (v * 10).round() / 10)),
        SliderCard(label: 'Loan Tenure', value: _tenure, displayValue: '${_tenure.round()} years',
            min: 1, max: _type == 0 ? 30 : (_type == 1 ? 7 : 5),
            color: AppColors.success, onChanged: (v) => setState(() => _tenure = v.roundToDouble())),
        const SizedBox(height: 16),
        const BannerAdWidget(),
        const SizedBox(height: 8),
      ])),
    );
  }

  void _exportPdf() {
    EmiPdfGenerator.generateAndShare(context,
        loanAmount: _loan, rate: _rate, tenure: _tenure, loanType: _typeNames[_type]);
  }

  Widget _tab(String label, int i) {
    bool s = _type == i;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() { _type = i;
        if (i == 0) { _loan = 5000000; _rate = 8.5; _tenure = 20; }
        else if (i == 1) { _loan = 800000; _rate = 9.5; _tenure = 5; }
        else { _loan = 500000; _rate = 12; _tenure = 3; }
      }),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: s ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: s ? AppColors.primary : AppColors.border)),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: s ? Colors.white : AppColors.textMed))),
    ));
  }
}

class _Stat extends StatelessWidget {
  final Color c; final String l, v;
  const _Stat(this.c, this.l, this.v);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(l, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
      ]),
      const SizedBox(height: 2),
      Text(v, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w700)),
    ]);
  }
}
