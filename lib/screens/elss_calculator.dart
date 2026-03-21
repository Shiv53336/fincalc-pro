import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/banner_ad_widget.dart';

class ElssCalculatorScreen extends StatefulWidget {
  const ElssCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<ElssCalculatorScreen> createState() => _ElssCalculatorScreenState();
}

class _ElssCalculatorScreenState extends State<ElssCalculatorScreen> {
  double _monthly = 5000;
  double _returnRate = 12;
  double _years = 10;

  static const double _limit80C = 150000; // Rs.1.5L 80C limit
  static const double _taxRate = 0.30; // 30% tax bracket
  static const double _fdRate = 7.0; // FD comparison rate

  @override
  Widget build(BuildContext context) {
    final int years = _years.toInt();
    final int months = years * 12;
    final double r = _returnRate / 100 / 12;

    // SIP maturity
    final double maturity = r == 0
        ? _monthly * months
        : _monthly * (pow(1 + r, months) - 1) / r * (1 + r);
    final double invested = _monthly * months;
    final double returns = maturity - invested;

    // Tax saved under 80C (capped at Rs.1.5L per year)
    final double yearlyInvested = _monthly * 12;
    final double eligible80C = yearlyInvested.clamp(0, _limit80C);
    final double taxSaved = eligible80C * _taxRate;

    // FD comparison (quarterly compounding on same invested amount)
    final double fdMaturity = invested * pow(1 + _fdRate / 100 / 4, 4 * years);
    final double elssAdvantage = maturity - fdMaturity;

    return Scaffold(
      appBar: AppBar(title: const Text('ELSS Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // 80C + lock-in badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.4)),
            ),
            child: Row(children: [
              const Text('🔒', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('3-Year Lock-in · Section 80C', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                Text('Shortest lock-in among 80C instruments. Market-linked returns.', style: TextStyle(fontSize: 11, color: AppColors.textMed)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),

          // Result card
          _ResultCard(maturity: maturity, invested: invested, returns: returns, taxSaved: taxSaved),
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
            min: 8,
            max: 25,
            divisions: 170,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.success,
            onChanged: (v) => setState(() => _returnRate = v),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Investment Period',
            value: _years,
            min: 3,
            max: 30,
            divisions: 27,
            format: (v) => '${v.toInt()} yrs',
            color: AppColors.warning,
            onChanged: (v) => setState(() => _years = v),
          ),
          const SizedBox(height: 16),

          // FD Comparison
          _FdComparisonCard(
            elssMaturity: maturity,
            fdMaturity: fdMaturity,
            elssAdvantage: elssAdvantage,
            fdRate: _fdRate,
            returnRate: _returnRate,
          ),
          const BannerAdWidget(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final double maturity, invested, returns, taxSaved;
  const _ResultCard({required this.maturity, required this.invested, required this.returns, required this.taxSaved});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryLight]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        const Text('Maturity Value', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Text(formatRupee(maturity), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _Pill('Invested', formatRupee(invested), AppColors.accent.withOpacity(0.3))),
          const SizedBox(width: 8),
          Expanded(child: _Pill('Returns', formatRupee(returns), AppColors.success.withOpacity(0.3))),
          const SizedBox(width: 8),
          Expanded(child: _Pill('Tax Saved', formatRupee(taxSaved), AppColors.gold.withOpacity(0.4))),
        ]),
      ]),
    );
  }
}

class _FdComparisonCard extends StatelessWidget {
  final double elssMaturity, fdMaturity, elssAdvantage, fdRate, returnRate;
  const _FdComparisonCard({required this.elssMaturity, required this.fdMaturity, required this.elssAdvantage, required this.fdRate, required this.returnRate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ELSS vs FD Comparison', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _CompareBox('ELSS', '${returnRate.toStringAsFixed(1)}%', formatRupee(elssMaturity), AppColors.accent)),
          const SizedBox(width: 12),
          Expanded(child: _CompareBox('Fixed Deposit', '${fdRate.toStringAsFixed(1)}%', formatRupee(fdMaturity), AppColors.textMed)),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'ELSS earns ${formatRupee(elssAdvantage.abs())} ${elssAdvantage >= 0 ? "more" : "less"} than FD',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success),
            )),
          ]),
        ),
      ]),
    );
  }
}

class _CompareBox extends StatelessWidget {
  final String label, rate, value;
  final Color color;
  const _CompareBox(this.label, this.rate, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        Text(rate, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
