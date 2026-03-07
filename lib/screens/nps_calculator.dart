import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';

class NpsCalculatorScreen extends StatefulWidget {
  const NpsCalculatorScreen({Key? key}) : super(key: key);
  @override
  State<NpsCalculatorScreen> createState() => _NpsCalculatorScreenState();
}

class _NpsCalculatorScreenState extends State<NpsCalculatorScreen> {
  double _monthly = 5000;
  double _rate = 10;
  double _currentAge = 30;
  double _retireAge = 60;
  double _annuityPct = 40; // Min 40% must be used for annuity

  double get _years => _retireAge - _currentAge;
  double get _totalInvested => _monthly * 12 * _years;

  double get _corpus {
    double r = _rate / 100 / 12;
    int n = (_years * 12).round();
    if (r == 0 || n == 0) return _totalInvested;
    return _monthly * (pow(1 + r, n) - 1) / r * (1 + r);
  }

  double get _lumpSum => _corpus * (1 - _annuityPct / 100); // Tax-free lump sum (60%)
  double get _annuityCorpus => _corpus * (_annuityPct / 100);
  double get _monthlyPension => _annuityCorpus * 0.06 / 12; // ~6% annuity rate estimate

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NPS Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Result Card
          ResultCard(children: [
            Text('Total Corpus at ${_retireAge.round()}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
            const SizedBox(height: 4),
            Text(formatRupee(_corpus), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            // Three stats
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _NpsStat('Lump Sum\n(Tax-free)', formatRupee(_lumpSum), Colors.white),
              _NpsStat('Monthly\nPension', formatRupee(_monthlyPension), const Color(0xFF48BB78)),
              _NpsStat('Total\nInvested', formatRupee(_totalInvested), Colors.white.withOpacity(0.7)),
            ]),
          ]),
          const SizedBox(height: 20),

          // Sliders
          SliderCard(label: 'Monthly Contribution', value: _monthly, displayValue: formatRupee(_monthly),
              min: 500, max: 50000, color: AppColors.accent,
              onChanged: (v) => setState(() => _monthly = (v / 500).round() * 500)),
          SliderCard(label: 'Expected Returns (p.a.)', value: _rate, displayValue: '${_rate.toStringAsFixed(1)}%',
              min: 5, max: 15, color: AppColors.success,
              onChanged: (v) => setState(() => _rate = (v * 10).round() / 10)),
          SliderCard(label: 'Current Age', value: _currentAge, displayValue: '${_currentAge.round()} yrs',
              min: 18, max: 55, color: AppColors.warning,
              onChanged: (v) => setState(() { _currentAge = v.roundToDouble(); if (_currentAge >= _retireAge) _retireAge = _currentAge + 5; })),
          SliderCard(label: 'Retirement Age', value: _retireAge, displayValue: '${_retireAge.round()} yrs',
              min: _currentAge + 5, max: 75, color: AppColors.purple,
              onChanged: (v) => setState(() => _retireAge = v.roundToDouble())),
          SliderCard(label: 'Annuity Purchase (%)', value: _annuityPct, displayValue: '${_annuityPct.round()}%',
              min: 40, max: 100, color: AppColors.danger,
              onChanged: (v) => setState(() => _annuityPct = v.roundToDouble())),

          const SizedBox(height: 16),
          // Info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'ℹ️ NPS offers extra ₹50,000 deduction under 80CCD(1B) beyond 80C limit. '
              'At retirement, min 40% corpus must buy annuity (pension). Remaining 60% is tax-free lump sum. '
              'Pension estimate assumes ~6% annuity rate. Actual returns depend on fund choice (Equity/Corporate/Govt).',
              style: TextStyle(fontSize: 10, color: AppColors.textMed, height: 1.5),
            ),
          ),
        ]),
      ),
    );
  }
}

class _NpsStat extends StatelessWidget {
  final String label, value; final Color color;
  const _NpsStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, height: 1.3)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
    ]);
  }
}
