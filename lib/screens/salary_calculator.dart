import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../engine/tax_engine.dart';
import '../widgets/shared_widgets.dart';

class SalaryCalculatorScreen extends StatefulWidget {
  const SalaryCalculatorScreen({Key? key}) : super(key: key);
  @override
  State<SalaryCalculatorScreen> createState() => _SalaryCalculatorScreenState();
}

class _SalaryCalculatorScreenState extends State<SalaryCalculatorScreen> {
  final _ctcCtrl = TextEditingController();
  bool _isMetro = true;
  bool _calculated = false;

  // Salary breakdown
  double _ctc = 0;
  double _basic = 0;
  double _hra = 0;
  double _specialAllowance = 0;
  double _employerPF = 0;
  double _employeePF = 0;
  double _professionalTax = 0;
  double _incomeTax = 0;
  double _monthlyTakeHome = 0;

  void _calculate() {
    _ctc = double.tryParse(_ctcCtrl.text.replaceAll(',', '')) ?? 0;
    if (_ctc <= 0) return;

    // Standard CTC breakdown
    _basic = _ctc * 0.40; // 40% of CTC
    _hra = _basic * 0.50; // 50% of basic (metro)
    _employerPF = min(_basic * 0.12, 21600 * 12 / 12 * 12); // 12% of basic (capped at ₹1800/mo for EPS portion)
    _employerPF = _basic * 0.12; // Full 12% employer contribution
    _specialAllowance = _ctc - _basic - _hra - _employerPF;

    // Deductions
    _employeePF = _basic * 0.12; // 12% of basic
    _professionalTax = 2500 * 12; // ₹2,500/month (Maharashtra)

    // Income tax (New Regime)
    TaxResult taxResult = TaxEngine.calculateNewRegime(grossSalary: _ctc - _employerPF);
    _incomeTax = taxResult.totalTax;

    // Monthly take-home
    double annualGross = _ctc - _employerPF; // Gross salary
    double annualDeductions = _employeePF + _professionalTax + _incomeTax;
    _monthlyTakeHome = (annualGross - annualDeductions) / 12;

    setState(() => _calculated = true);
  }

  @override
  void dispose() { _ctcCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salary Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          StyledInput(controller: _ctcCtrl, label: 'Annual CTC', hint: 'E.g. 1200000'),
          const SizedBox(height: 8),
          SegmentedTab(labels: const ['Metro City', 'Non-Metro'], selectedIndex: _isMetro ? 0 : 1,
              onChanged: (i) => setState(() => _isMetro = i == 0)),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.accent, AppColors.primary]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: ElevatedButton(onPressed: _calculate,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  child: const Text('Calculate Take-Home →')),
            ),
          ),
          const SizedBox(height: 20),

          if (_calculated && _ctc > 0) ...[
            // Result Card
            ResultCard(children: [
              Text('Monthly Take-Home', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 4),
              Text(formatRupee(_monthlyTakeHome), style: const TextStyle(color: Color(0xFF48BB78), fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Annual: ${formatRupee(_monthlyTakeHome * 12)}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
              const SizedBox(height: 12),
              // Visual bar
              ClipRRect(borderRadius: BorderRadius.circular(4), child: Row(children: [
                Expanded(flex: (_monthlyTakeHome * 12 / max(_ctc, 1) * 100).round().clamp(1, 99),
                    child: Container(height: 10, color: const Color(0xFF48BB78))),
                Expanded(flex: ((_ctc - _monthlyTakeHome * 12) / max(_ctc, 1) * 100).round().clamp(1, 99),
                    child: Container(height: 10, color: const Color(0xFFFC8181))),
              ])),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('In Hand (${(_monthlyTakeHome * 12 / _ctc * 100).toStringAsFixed(0)}%)',
                    style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
                Text('Deductions', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
              ]),
            ]),
            const SizedBox(height: 16),

            // CTC Breakdown
            _BreakdownCard(title: 'CTC Breakdown (Annual)', rows: [
              _BRow('Basic', formatRupee(_basic), '40%'),
              _BRow('HRA', formatRupee(_hra), '${(_isMetro ? 50 : 40)}% of Basic'),
              _BRow('Special Allowance', formatRupee(_specialAllowance), 'Balance'),
              _BRow('Employer PF', formatRupee(_employerPF), '12% of Basic'),
            ], total: _BRow('Total CTC', formatRupee(_ctc), '')),

            const SizedBox(height: 12),

            // Deductions Breakdown
            _BreakdownCard(title: 'Deductions (Annual)', rows: [
              _BRow('Employee PF', formatRupee(_employeePF), '12% of Basic'),
              _BRow('Professional Tax', formatRupee(_professionalTax), '₹2,500/mo'),
              _BRow('Income Tax (New)', formatRupee(_incomeTax), 'FY 2025-26'),
            ], total: _BRow('Total Deductions', formatRupee(_employeePF + _professionalTax + _incomeTax), '')),

            const SizedBox(height: 12),

            // Monthly Summary
            _BreakdownCard(title: 'Monthly Summary', rows: [
              _BRow('Gross Salary', formatRupee((_ctc - _employerPF) / 12), ''),
              _BRow('Employee PF', '- ${formatRupee(_employeePF / 12)}', ''),
              _BRow('Prof. Tax', '- ${formatRupee(_professionalTax / 12)}', ''),
              _BRow('Income Tax', '- ${formatRupee(_incomeTax / 12)}', ''),
            ], total: _BRow('Take-Home', formatRupee(_monthlyTakeHome), ''), totalColor: AppColors.success),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(10)),
              child: const Text(
                '⚠️ This is an approximate calculation. Actual take-home depends on your specific CTC structure, '
                'bonus components, flexible benefits, and tax deductions. Tax calculated under New Regime (FY 2025-26).',
                style: TextStyle(fontSize: 10, color: AppColors.textLight, height: 1.5),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _BRow {
  final String label, value, note;
  const _BRow(this.label, this.value, this.note);
}

class _BreakdownCard extends StatelessWidget {
  final String title;
  final List<_BRow> rows;
  final _BRow total;
  final Color totalColor;
  const _BreakdownCard({required this.title, required this.rows, required this.total, this.totalColor = AppColors.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 12),
        ...rows.map((r) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Expanded(child: Text(r.label, style: const TextStyle(fontSize: 12, color: AppColors.textMed))),
            if (r.note.isNotEmpty) Text(r.note, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
            const SizedBox(width: 8),
            Text(r.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
          ]),
        )),
        const Divider(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(total.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          Text(total.value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: totalColor)),
        ]),
      ]),
    );
  }
}
