import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';

class PpfCalculatorScreen extends StatefulWidget {
  const PpfCalculatorScreen({Key? key}) : super(key: key);
  @override
  State<PpfCalculatorScreen> createState() => _PpfCalculatorScreenState();
}

class _PpfCalculatorScreenState extends State<PpfCalculatorScreen> {
  double _yearly = 150000;
  double _rate = 7.1; // Current PPF rate
  double _years = 15; // Minimum PPF lock-in

  List<Map<String, double>> get _yearlyData {
    List<Map<String, double>> data = [];
    double balance = 0;
    for (int y = 1; y <= _years.round(); y++) {
      balance = (balance + _yearly) * (1 + _rate / 100);
      data.add({
        'year': y.toDouble(),
        'invested': _yearly * y,
        'balance': balance,
        'interest': balance - (_yearly * y),
      });
    }
    return data;
  }

  double get _totalInvested => _yearly * _years;
  double get _maturity => _yearlyData.isEmpty ? 0 : _yearlyData.last['balance']!;
  double get _totalInterest => _maturity - _totalInvested;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PPF Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Result Card
          ResultCard(children: [
            Text('Maturity Amount', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
            const SizedBox(height: 4),
            Text(formatRupee(_maturity), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF48BB78).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('🎯 100% Tax-Free Returns under Section 80C', style: const TextStyle(color: Color(0xFF48BB78), fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              MiniStat('Invested', formatRupee(_totalInvested), Colors.white.withOpacity(0.8)),
              MiniStat('Interest', formatRupee(_totalInterest), const Color(0xFF48BB78)),
            ]),
            const SizedBox(height: 16),
            // Visual bar
            ClipRRect(borderRadius: BorderRadius.circular(4), child: Row(children: [
              Expanded(flex: (_totalInvested / max(_maturity, 1) * 100).round().clamp(1, 99),
                  child: Container(height: 8, color: Colors.white.withOpacity(0.3))),
              Expanded(flex: (_totalInterest / max(_maturity, 1) * 100).round().clamp(1, 99),
                  child: Container(height: 8, color: const Color(0xFF48BB78))),
            ])),
          ]),
          const SizedBox(height: 20),

          // Sliders
          SliderCard(label: 'Yearly Investment', value: _yearly, displayValue: formatRupee(_yearly),
              min: 500, max: 150000, color: AppColors.accent,
              onChanged: (v) => setState(() => _yearly = (v / 500).round() * 500)),
          SliderCard(label: 'Interest Rate (p.a.)', value: _rate, displayValue: '${_rate.toStringAsFixed(1)}%',
              min: 5, max: 10, color: AppColors.success,
              onChanged: (v) => setState(() => _rate = (v * 10).round() / 10)),
          SliderCard(label: 'Period', value: _years, displayValue: '${_years.round()} years',
              min: 15, max: 50, color: AppColors.warning,
              onChanged: (v) => setState(() => _years = v.roundToDouble())),

          const SizedBox(height: 16),
          const Text('Year-wise Growth', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 10),

          // Year-wise table
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
            child: Column(children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                  Text('Year', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMed)),
                  Text('Invested', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMed)),
                  Text('Balance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMed)),
                ]),
              ),
              ..._yearlyData.where((d) => d['year']! % 5 == 0 || d['year'] == _years).map((d) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderLight))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Year ${d['year']!.round()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
                    Text(formatRupee(d['invested']!), style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                    Text(formatRupee(d['balance']!), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ]),
                );
              }),
            ]),
          ),
          const SizedBox(height: 16),
          // Info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
            child: Text(
              'ℹ️ PPF has a 15-year lock-in period (extendable in 5-year blocks). '
              'Rate shown (${_rate.toStringAsFixed(1)}% p.a.) is set by the government quarterly — adjust the slider to model rate changes. '
              'Max investment: Rs.1,50,000/year. Interest and maturity are fully tax-free.',
              style: const TextStyle(fontSize: 10, color: AppColors.textMed, height: 1.5),
            ),
          ),
        ]),
      ),
    );
  }
}
