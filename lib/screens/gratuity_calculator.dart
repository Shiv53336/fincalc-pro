import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';

class GratuityCalculatorScreen extends StatefulWidget {
  const GratuityCalculatorScreen({Key? key}) : super(key: key);
  @override
  State<GratuityCalculatorScreen> createState() => _GratuityCalculatorScreenState();
}

class _GratuityCalculatorScreenState extends State<GratuityCalculatorScreen> {
  double _basic = 50000; // Monthly basic + DA
  double _years = 10;
  int _type = 0; // 0 = Covered under Act, 1 = Not covered

  // Gratuity = (Basic × 15 × Years) / 26 (if covered under Payment of Gratuity Act)
  // Gratuity = (Basic × 15 × Years) / 30 (if not covered)
  double get _gratuity {
    double amount;
    if (_type == 0) {
      amount = (_basic * 15 * _years) / 26;
    } else {
      amount = (_basic * 15 * _years) / 30;
    }
    return amount;
  }

  // Tax-free limit for gratuity
  double get _taxFreeLimit => 2000000; // ₹20 lakh limit
  double get _taxFreeAmount => min(_gratuity, _taxFreeLimit);
  double get _taxableAmount => max(_gratuity - _taxFreeLimit, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gratuity Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Type toggle
          SegmentedTab(
            labels: const ['Covered under Act', 'Not Covered'],
            selectedIndex: _type,
            onChanged: (i) => setState(() => _type = i),
          ),
          const SizedBox(height: 16),

          ResultCard(children: [
            Text('Gratuity Amount', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
            const SizedBox(height: 4),
            Text(formatRupee(_gratuity), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              MiniStat('Tax-Free', formatRupee(_taxFreeAmount), const Color(0xFF48BB78)),
              if (_taxableAmount > 0)
                MiniStat('Taxable', formatRupee(_taxableAmount), const Color(0xFFFC8181)),
            ]),
            if (_taxableAmount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('⚠️ Amount exceeds ₹20L tax-free limit', style: TextStyle(color: Color(0xFFFC8181), fontSize: 11)),
              ),
            ],
          ]),
          const SizedBox(height: 20),

          // Formula display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Formula', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  'Gratuity = (Basic × 15 × Years) / ${_type == 0 ? "26" : "30"}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '= (${formatRupee(_basic)} × 15 × ${_years.round()}) / ${_type == 0 ? "26" : "30"}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMed),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          SliderCard(label: 'Monthly Basic + DA', value: _basic, displayValue: formatRupee(_basic),
              min: 5000, max: 500000, color: AppColors.accent,
              onChanged: (v) => setState(() => _basic = (v / 1000).round() * 1000)),
          SliderCard(label: 'Years of Service', value: _years, displayValue: '${_years.round()} years',
              min: 5, max: 40, color: AppColors.success,
              onChanged: (v) => setState(() => _years = v.roundToDouble())),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'ℹ️ Gratuity is payable after 5+ years of continuous service. '
              'For employees covered under the Payment of Gratuity Act (10+ employees), '
              'divisor is 26 (working days). Others use 30. '
              'Tax-free limit: ₹20,00,000. Minimum eligibility: 5 years of service.',
              style: TextStyle(fontSize: 10, color: AppColors.textMed, height: 1.5),
            ),
          ),
        ]),
      ),
    );
  }
}
