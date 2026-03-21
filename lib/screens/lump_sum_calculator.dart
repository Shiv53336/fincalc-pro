import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';

class LumpSumCalculatorScreen extends StatefulWidget {
  const LumpSumCalculatorScreen({Key? key}) : super(key: key);
  @override
  State<LumpSumCalculatorScreen> createState() => _LumpSumCalculatorScreenState();
}

class _LumpSumCalculatorScreenState extends State<LumpSumCalculatorScreen> {
  double _amount = 100000, _rate = 12, _years = 10;
  double get _fv => _amount * pow(1 + _rate / 100, _years);
  double get _ret => _fv - _amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lump Sum Calculator')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        ResultCard(children: [
          Text('Future Value', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          Text(formatRupee(_fv), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('+${formatRupee(_ret)} returns (${(_ret / max(_amount, 1) * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(color: Color(0xFF48BB78), fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            MiniStat('Invested', formatRupee(_amount), Colors.white.withOpacity(0.8)),
            MiniStat('Returns', formatRupee(_ret), const Color(0xFF48BB78)),
          ]),
        ]),
        const SizedBox(height: 20),
        SliderCard(label: 'Investment Amount', value: _amount, displayValue: formatRupee(_amount),
            min: 10000, max: 10000000, color: AppColors.accent, onChanged: (v) => setState(() => _amount = (v / 1000).round() * 1000)),
        SliderCard(label: 'Expected Returns (p.a.)', value: _rate, displayValue: '${_rate.toStringAsFixed(1)}%',
            min: 1, max: 30, color: AppColors.success, onChanged: (v) => setState(() => _rate = (v * 10).round() / 10)),
        SliderCard(label: 'Time Period', value: _years, displayValue: '${_years.round()} years',
            min: 1, max: 30, color: AppColors.warning, onChanged: (v) => setState(() => _years = v.roundToDouble())),
      ])),
    );
  }
}
