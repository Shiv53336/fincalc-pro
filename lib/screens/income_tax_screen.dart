import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../engine/tax_engine.dart';
import '../widgets/shared_widgets.dart';
import 'tax_results_screen.dart';

class IncomeTaxInputScreen extends StatefulWidget {
  const IncomeTaxInputScreen({Key? key}) : super(key: key);
  @override
  State<IncomeTaxInputScreen> createState() => _IncomeTaxInputScreenState();
}

class _IncomeTaxInputScreenState extends State<IncomeTaxInputScreen> {
  final _salaryCtrl = TextEditingController();
  final _otherIncomeCtrl = TextEditingController();
  final _ded80CCtrl = TextEditingController();
  final _ded80DCtrl = TextEditingController();
  final _dedNPSCtrl = TextEditingController();
  final _homeLoanCtrl = TextEditingController();
  final _hraCtrl = TextEditingController();
  final _ded80GCtrl = TextEditingController();
  final _ded80ECtrl = TextEditingController();
  final _ded80TTACtrl = TextEditingController();
  int _regimeIndex = 0;

  @override
  void dispose() {
    _salaryCtrl.dispose(); _otherIncomeCtrl.dispose();
    _ded80CCtrl.dispose(); _ded80DCtrl.dispose();
    _dedNPSCtrl.dispose(); _homeLoanCtrl.dispose();
    _hraCtrl.dispose(); _ded80GCtrl.dispose();
    _ded80ECtrl.dispose(); _ded80TTACtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '')) ?? 0;

  void _calculate() {
    double salary = _parse(_salaryCtrl);
    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please enter your annual salary'),
        backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    double other = _parse(_otherIncomeCtrl);
    TaxResult newR = TaxEngine.calculateNewRegime(grossSalary: salary, otherIncome: other);
    TaxResult oldR = TaxEngine.calculateOldRegime(
      grossSalary: salary, otherIncome: other,
      deduction80C: _parse(_ded80CCtrl), deduction80D: _parse(_ded80DCtrl),
      deductionNPS: _parse(_dedNPSCtrl), homeLoanInterest: _parse(_homeLoanCtrl),
      hraExemption: _parse(_hraCtrl),
      deduction80G: _parse(_ded80GCtrl),
      deduction80E: _parse(_ded80ECtrl),
      deduction80TTA: _parse(_ded80TTACtrl),
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => TaxResultsScreen(newResult: newR, oldResult: oldR)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Income Tax Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // FY Selector
          Row(children: [
            _buildChip('FY 2025-26', true, null),
            const SizedBox(width: 8),
            Expanded(child: Tooltip(
              message: 'Coming soon',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight)),
                alignment: Alignment.center,
                child: const Text('FY 2026-27', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textLight)),
              ),
            )),
          ]),
          const SizedBox(height: 16),
          SegmentedTab(labels: const ['New Regime', 'Old Regime'], selectedIndex: _regimeIndex,
              onChanged: (i) => setState(() => _regimeIndex = i)),
          const SizedBox(height: 20),
          // Salary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Gross Taxable Salary', style: TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(children: [
                const Text('Rs.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _salaryCtrl, keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: '12,00,000', hintStyle: TextStyle(color: AppColors.borderLight)))),
              ]),
              Container(height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
            ]),
          ),
          const SizedBox(height: 12),
          StyledInput(controller: _otherIncomeCtrl, label: 'Other Income', hint: 'Rental, FD interest, etc.'),
          const SizedBox(height: 20),
          if (_regimeIndex == 1) ...[
            const Text('Deductions (Old Regime)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
            const SizedBox(height: 12),
            DeductionInput(controller: _ded80CCtrl, label: 'Section 80C', maxLabel: 'Rs.1.5L'),
            DeductionInput(controller: _ded80DCtrl, label: 'Section 80D (Health Ins.)', maxLabel: 'Rs.75K'),
            DeductionInput(controller: _dedNPSCtrl, label: 'NPS - 80CCD(1B)', maxLabel: 'Rs.50K'),
            DeductionInput(controller: _homeLoanCtrl, label: 'Home Loan Interest (24b)', maxLabel: 'Rs.2L'),
            DeductionInput(controller: _hraCtrl, label: 'HRA Exemption', maxLabel: 'Actuals'),
            DeductionInput(controller: _ded80GCtrl, label: 'Section 80G (Donations)', maxLabel: 'No limit'),
            DeductionInput(controller: _ded80ECtrl, label: 'Section 80E (Edu. Loan Interest)', maxLabel: 'No limit'),
            DeductionInput(controller: _ded80TTACtrl, label: 'Section 80TTA (Savings Interest)', maxLabel: 'Rs.10K'),
            const SizedBox(height: 12),
          ],
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
                  child: const Text('Calculate Tax →')),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildChip(String text, bool selected, VoidCallback? onTap) {
    return Expanded(child: GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: selected ? AppColors.accent : Colors.white, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border)),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textMed)),
    )));
  }
}
