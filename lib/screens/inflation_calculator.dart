import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';

class InflationCalculatorScreen extends StatefulWidget {
  const InflationCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<InflationCalculatorScreen> createState() => _InflationCalculatorScreenState();
}

class _InflationCalculatorScreenState extends State<InflationCalculatorScreen> {
  double _currentCost = 100000;
  double _inflationRate = 6;
  double _years = 10;

  @override
  Widget build(BuildContext context) {
    final double futureCost = _currentCost * pow(1 + _inflationRate / 100, _years);
    final double erosion = _currentCost - (_currentCost / pow(1 + _inflationRate / 100, _years));
    final double erosionPct = _currentCost > 0 ? erosion / _currentCost * 100 : 0;

    // Milestone table
    final milestones = [1, 3, 5, 10, 15, 20, 25, 30].where((y) => y <= _years.toInt() || y == _years.toInt()).toList();
    if (!milestones.contains(_years.toInt())) milestones.add(_years.toInt());
    milestones.sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Inflation Calculator')),
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
              const Text('Future Cost', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(formatRupee(futureCost), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              Text('in ${_years.toInt()} years at ${_inflationRate.toStringAsFixed(1)}% inflation', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _Pill('Today\'s Cost', formatRupee(_currentCost), Colors.white.withOpacity(0.15))),
                const SizedBox(width: 8),
                Expanded(child: _Pill('Purchasing Power Lost', '${erosionPct.toStringAsFixed(1)}%', AppColors.danger.withOpacity(0.35))),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          SliderCard(
            label: "Current Cost / Amount",
            value: _currentCost,
            min: 1000,
            max: 10000000,
            divisions: 99,
            format: formatRupee,
            color: AppColors.accent,
            onChanged: (v) => setState(() => _currentCost = (v / 1000).round() * 1000.0),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Inflation Rate (p.a.)',
            value: _inflationRate,
            min: 1,
            max: 15,
            divisions: 140,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.danger,
            onChanged: (v) => setState(() => _inflationRate = v),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Time Period',
            value: _years,
            min: 1,
            max: 40,
            divisions: 39,
            format: (v) => '${v.toInt()} yrs',
            color: AppColors.warning,
            onChanged: (v) => setState(() => _years = v),
          ),
          const SizedBox(height: 16),

          // Erosion visual
          _ErosionBar(current: _currentCost, future: futureCost),
          const SizedBox(height: 16),

          // Milestone table
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Cost Over Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Expanded(flex: 1, child: Text('Year', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text('Future Cost', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text('Cost Increase', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                ]),
              ),
              ...milestones.asMap().entries.map((e) {
                final y = e.value;
                final fc = _currentCost * pow(1 + _inflationRate / 100, y);
                final increase = fc - _currentCost;
                final even = e.key % 2 == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  color: even ? AppColors.bg : Colors.white,
                  child: Row(children: [
                    Expanded(flex: 1, child: Text('$y', style: const TextStyle(fontSize: 12, color: AppColors.textMed))),
                    Expanded(flex: 2, child: Text(formatShortIndian(fc), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text), textAlign: TextAlign.right)),
                    Expanded(flex: 2, child: Text('+${formatShortIndian(increase)}', style: const TextStyle(fontSize: 12, color: AppColors.danger), textAlign: TextAlign.right)),
                  ]),
                );
              }),
            ]),
          ),
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

class _ErosionBar extends StatelessWidget {
  final double current, future;
  const _ErosionBar({required this.current, required this.future});

  @override
  Widget build(BuildContext context) {
    // Shows purchasing power: how much "today's 100" buys in the future
    final double pct = future > 0 ? (current / future).clamp(0.0, 1.0) : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Purchasing Power Erosion', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Remaining power', style: TextStyle(fontSize: 12, color: AppColors.textMed)),
          Text('${(pct * 100).toStringAsFixed(1)}% of today\'s value', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(children: [
            Container(height: 14, color: AppColors.dangerLight),
            FractionallySizedBox(widthFactor: pct, child: Container(height: 14, color: AppColors.success)),
          ]),
        ),
        const SizedBox(height: 8),
        Text(
          'To maintain the same purchasing power as ${formatRupee(current)} today, you\'ll need ${formatRupee(future)}.',
          style: const TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.4),
        ),
      ]),
    );
  }
}
