import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';

class EpfCalculatorScreen extends StatefulWidget {
  const EpfCalculatorScreen({Key? key}) : super(key: key);
  @override
  State<EpfCalculatorScreen> createState() => _EpfCalculatorScreenState();
}

class _EpfCalculatorScreenState extends State<EpfCalculatorScreen> {
  double _basicDA = 30000; // Monthly basic + DA
  double _rate = 8.25; // Current EPF rate 2024-25
  double _currentAge = 28;
  double _retireAge = 58;
  double _currentBalance = 0;

  double get _years => _retireAge - _currentAge;
  double get _employeeMonthly => _basicDA * 0.12;
  double get _employerEPF => _basicDA * 0.0367; // 3.67% to EPF (8.33% goes to EPS)
  double get _totalMonthly => _employeeMonthly + _employerEPF;

  double get _maturity {
    double monthlyRate = _rate / 100 / 12;
    int months = (_years * 12).round();
    if (monthlyRate == 0 || months == 0) return _currentBalance + _totalMonthly * months;
    // FV of existing balance
    double fvExisting = _currentBalance * pow(1 + monthlyRate, months);
    // FV of monthly contributions
    double fvContrib = _totalMonthly * (pow(1 + monthlyRate, months) - 1) / monthlyRate;
    return fvExisting + fvContrib;
  }

  double get _totalContribution => _totalMonthly * _years * 12 + _currentBalance;
  double get _totalInterest => _maturity - _totalContribution;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EPF Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ResultCard(children: [
            Text('EPF Balance at Retirement', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
            const SizedBox(height: 4),
            Text(formatRupee(_maturity), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              MiniStat('You + Employer', formatRupee(_totalContribution), Colors.white.withOpacity(0.8)),
              MiniStat('Interest', formatRupee(_totalInterest), const Color(0xFF48BB78)),
            ]),
          ]),
          const SizedBox(height: 16),

          // Contribution Breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Monthly Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
              const SizedBox(height: 12),
              _Row('Your Contribution (12%)', formatRupee(_employeeMonthly)),
              _Row('Employer to EPF (3.67%)', formatRupee(_employerEPF)),
              _Row('Employer to EPS (8.33%)', formatRupee(_basicDA * 0.0833)),
              const Divider(height: 16),
              _Row('Total to EPF/month', formatRupee(_totalMonthly), bold: true),
            ]),
          ),
          const SizedBox(height: 20),

          SliderCard(label: 'Monthly Basic + DA', value: _basicDA, displayValue: formatRupee(_basicDA),
              min: 5000, max: 200000, color: AppColors.accent,
              onChanged: (v) => setState(() => _basicDA = (v / 1000).round() * 1000)),
          SliderCard(label: 'EPF Interest Rate', value: _rate, displayValue: '${_rate.toStringAsFixed(2)}%',
              min: 5, max: 12, color: AppColors.success,
              onChanged: (v) => setState(() => _rate = (v * 100).round() / 100)),
          SliderCard(label: 'Current Age', value: _currentAge, displayValue: '${_currentAge.round()} yrs',
              min: 18, max: 50, color: AppColors.warning,
              onChanged: (v) => setState(() { _currentAge = v.roundToDouble(); if (_currentAge >= _retireAge) _retireAge = _currentAge + 5; })),
          SliderCard(label: 'Retirement Age', value: _retireAge, displayValue: '${_retireAge.round()} yrs',
              min: _currentAge + 5, max: 60, color: AppColors.purple,
              onChanged: (v) => setState(() => _retireAge = v.roundToDouble())),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'ℹ️ EPF rate: 8.25% (FY 2024-25). Employee contributes 12% of Basic+DA. '
              'Employer contributes 12% — split as 8.33% to EPS (pension, max ₹15K salary) and 3.67% to EPF. '
              'EPF withdrawal is tax-free after 5 years of continuous service.',
              style: TextStyle(fontSize: 10, color: AppColors.textMed, height: 1.5),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value; final bool bold;
  const _Row(this.label, this.value, {this.bold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 12, color: bold ? AppColors.text : AppColors.textMed, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: bold ? AppColors.success : AppColors.text)),
      ]),
    );
  }
}
