import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';

class FdCalculatorScreen extends StatefulWidget {
  const FdCalculatorScreen({Key? key}) : super(key: key);
  @override
  State<FdCalculatorScreen> createState() => _FdCalculatorScreenState();
}

class _FdCalculatorScreenState extends State<FdCalculatorScreen> {
  double _principal = 500000, _rate = 7.0, _years = 5;
  double get _maturity { double r = _rate / 100 / 4; return _principal * pow(1 + r, (_years * 4).round()); }
  double get _interest => _maturity - _principal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FD Calculator')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        ResultCard(children: [
          Text('Maturity Amount', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          Text(formatRupee(_maturity), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Interest Earned: ${formatRupee(_interest)}', style: const TextStyle(color: Color(0xFF48BB78), fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            MiniStat('Invested', formatRupee(_principal), Colors.white.withOpacity(0.8)),
            MiniStat('Interest', formatRupee(_interest), const Color(0xFF48BB78)),
          ]),
        ]),
        const SizedBox(height: 20),
        SliderCard(label: 'Deposit Amount', value: _principal, displayValue: formatRupee(_principal),
            min: 10000, max: 10000000, color: AppColors.accent, onChanged: (v) => setState(() => _principal = (v / 1000).round() * 1000)),
        SliderCard(label: 'Interest Rate (p.a.)', value: _rate, displayValue: '${_rate.toStringAsFixed(1)}%',
            min: 4, max: 15, color: AppColors.warning, onChanged: (v) => setState(() => _rate = (v * 10).round() / 10)),
        SliderCard(label: 'Period', value: _years, displayValue: '${_years.round()} years',
            min: 1, max: 10, color: AppColors.success, onChanged: (v) => setState(() => _years = v.roundToDouble())),
      ])),
    );
  }
}
