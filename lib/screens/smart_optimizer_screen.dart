import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../engine/tax_engine.dart';
import '../widgets/shared_widgets.dart';

class SmartTaxOptimizerScreen extends StatefulWidget {
  final double salary;
  const SmartTaxOptimizerScreen({Key? key, this.salary = 0}) : super(key: key);
  @override
  State<SmartTaxOptimizerScreen> createState() => _SmartTaxOptimizerScreenState();
}

class _SmartTaxOptimizerScreenState extends State<SmartTaxOptimizerScreen> {
  late TextEditingController _salaryCtrl;

  @override
  void initState() {
    super.initState();
    _salaryCtrl = TextEditingController(text: widget.salary > 0 ? widget.salary.round().toString() : '');
  }

  @override
  void dispose() { _salaryCtrl.dispose(); super.dispose(); }

  double get _salary => double.tryParse(_salaryCtrl.text.replaceAll(',', '')) ?? 0;

  List<_Rec> _getRecs() {
    if (_salary <= 0) return [];
    TaxResult base = TaxEngine.calculateOldRegime(grossSalary: _salary);
    List<_Rec> recs = [];

    TaxResult r1 = TaxEngine.calculateOldRegime(grossSalary: _salary, deduction80C: 150000);
    double s1 = base.totalTax - r1.totalTax;
    if (s1 > 0) recs.add(_Rec(1, 'Max out 80C (Rs.1.5L)', 'Invest in ELSS, PPF, EPF, or NSC to claim full deduction', s1, 'Not invested'));

    TaxResult r2 = TaxEngine.calculateOldRegime(grossSalary: _salary, deduction80C: 150000, deduction80D: 75000);
    double s2 = r1.totalTax - r2.totalTax;
    if (s2 > 0) recs.add(_Rec(2, 'Health Insurance (80D)', 'Rs.25K self + Rs.50K parents (senior) = Rs.75K deduction', s2, 'Recommended'));

    TaxResult r3 = TaxEngine.calculateOldRegime(grossSalary: _salary, deduction80C: 150000, deduction80D: 75000, deductionNPS: 50000);
    double s3 = r2.totalTax - r3.totalTax;
    if (s3 > 0) recs.add(_Rec(3, 'NPS Contribution (80CCD)', 'Extra Rs.50,000 deduction over 80C. Great for retirement.', s3, 'Not started'));

    TaxResult r4 = TaxEngine.calculateOldRegime(grossSalary: _salary, deduction80C: 150000, deduction80D: 75000, deductionNPS: 50000, homeLoanInterest: 200000);
    double s4 = r3.totalTax - r4.totalTax;
    if (s4 > 0) recs.add(_Rec(4, 'Home Loan Interest (24b)', 'Up to Rs.2L deduction on home loan interest', s4, 'If applicable'));

    return recs;
  }

  @override
  Widget build(BuildContext context) {
    double totalSavings = _getRecs().fold(0.0, (s, r) => s + r.saving);
    return Scaffold(
      appBar: AppBar(title: const Text('✨ Smart Tax Optimizer'),
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF744210), AppColors.gold])))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.salary <= 0)
            Padding(padding: const EdgeInsets.only(bottom: 16),
                child: StyledInput(controller: _salaryCtrl, label: 'Enter Annual Salary', hint: 'E.g. 1800000', onChanged: (_) => setState(() {}))),

          ResultCard(children: [
            Text('You could save up to', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
            const SizedBox(height: 4),
            Text(_salary > 0 ? formatRupee(totalSavings) : 'Rs.---',
                style: const TextStyle(color: Color(0xFF48BB78), fontSize: 36, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('by optimizing your investments', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
            if (_salary > 0) ...[
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text('Based on salary: ${formatRupee(_salary)} / year', style: const TextStyle(color: Colors.white, fontSize: 12))),
            ],
          ]),
          const SizedBox(height: 20),
          if (_salary > 0) ...[
            const Text('Recommended Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
            const SizedBox(height: 12),
            ..._getRecs().map((r) => _RecCard(rec: r)),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(10)),
                child: const Text('⚠️ These are estimates based on Old Regime with maximum deductions. Actual savings depend on your tax slab. Consult a tax professional.',
                    style: TextStyle(fontSize: 10, color: AppColors.textLight, height: 1.5))),
          ] else
            const Center(child: Padding(padding: EdgeInsets.only(top: 40),
                child: Text('Enter your salary above to get recommendations', style: TextStyle(color: AppColors.textLight)))),
        ]),
      ),
    );
  }
}

class _Rec {
  final int priority; final String title, desc; final double saving; final String status;
  _Rec(this.priority, this.title, this.desc, this.saving, this.status);
}

class _RecCard extends StatelessWidget {
  final _Rec rec;
  const _RecCard({required this.rec});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 32, height: 32, alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('${rec.priority}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.success))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(rec.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
                child: Text('Save ${formatRupee(rec.saving)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success))),
          ]),
          const SizedBox(height: 4),
          Text(rec.desc, style: const TextStyle(fontSize: 12, color: AppColors.textMed, height: 1.4)),
          const SizedBox(height: 6),
          Row(children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: rec.priority <= 2 ? AppColors.danger : AppColors.warning, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(rec.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: rec.priority <= 2 ? AppColors.danger : AppColors.textLight)),
          ]),
        ])),
      ]),
    );
  }
}
