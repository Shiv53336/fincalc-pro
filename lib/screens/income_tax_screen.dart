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
  String _selectedFY = 'FY 2025-26';
  int _regimeIndex = 0;

  @override
  void dispose() {
    _salaryCtrl.dispose(); _otherIncomeCtrl.dispose();
    _ded80CCtrl.dispose(); _ded80DCtrl.dispose();
    _dedNPSCtrl.dispose(); _homeLoanCtrl.dispose();
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
            _buildChip('FY 2025-26', _selectedFY == 'FY 2025-26', () => setState(() => _selectedFY = 'FY 2025-26')),
            const SizedBox(width: 8),
            _buildChip('FY 2026-27', _selectedFY == 'FY 2026-27', () => setState(() => _selectedFY = 'FY 2026-27')),
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
              const Text('Annual Salary (CTC)', style: TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
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
            DeductionInput(controller: _ded80DCtrl, label: 'Section 80D (Health)', maxLabel: 'Rs.75K'),
            DeductionInput(controller: _dedNPSCtrl, label: 'NPS - 80CCD(1B)', maxLabel: 'Rs.50K'),
            DeductionInput(controller: _homeLoanCtrl, label: 'Home Loan Interest (24b)', maxLabel: 'Rs.2L'),
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

  Widget _buildChip(String text, bool selected, VoidCallback onTap) {
    return Expanded(child: GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: selected ? AppColors.accent : Colors.white, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border)),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textMed)),
    )));
  }
}
