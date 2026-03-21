import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/banner_ad_widget.dart';

class AffordabilityCalculatorScreen extends StatefulWidget {
  const AffordabilityCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<AffordabilityCalculatorScreen> createState() => _AffordabilityCalculatorScreenState();
}

class _AffordabilityCalculatorScreenState extends State<AffordabilityCalculatorScreen> {
  double _salary = 100000;
  double _expenses = 40000;
  double _existingEmi = 10000;
  double _interestRate = 8.5;
  double _tenure = 20;

  @override
  Widget build(BuildContext context) {
    final double disposable = (_salary - _expenses - _existingEmi).clamp(0, double.infinity);
    // Safe EMI: 40% of salary rule (total EMI including existing should not exceed 40%)
    final double maxTotalEmi = _salary * 0.40;
    final double safeNewEmi = (maxTotalEmi - _existingEmi).clamp(0, double.infinity);
    // Also check: new EMI should not exceed 50% of disposable
    final double safeEmiDisposable = disposable * 0.50;
    final double safeEmi = safeNewEmi < safeEmiDisposable ? safeNewEmi : safeEmiDisposable;

    // Max loan from safe EMI
    final double r = _interestRate / 100 / 12;
    final int n = (_tenure * 12).round();
    final double maxLoan = safeEmi > 0 && r > 0
        ? safeEmi * (pow(1 + r, n) - 1) / (r * pow(1 + r, n))
        : safeEmi * n;

    // Debt-to-income ratio
    final double dti = _salary > 0 ? (_existingEmi / _salary) * 100 : 0;
    final double afterDti = _salary > 0 ? ((_existingEmi + safeEmi) / _salary) * 100 : 0;

    // Affordability rating
    String rating;
    String emoji;
    if (safeEmi > _salary * 0.2) { rating = 'Comfortable'; emoji = '✅'; }
    else if (safeEmi > _salary * 0.1) { rating = 'Moderate'; emoji = '⚠️'; }
    else if (safeEmi > 0) { rating = 'Stretched'; emoji = '🔴'; }
    else { rating = 'Not Advisable'; emoji = '❌'; }

    return Scaffold(
      appBar: AppBar(title: const Text('EMI Affordability')),
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
              Text('$emoji $rating', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              const Text('Safe Monthly EMI', style: TextStyle(color: Colors.white60, fontSize: 12)),
              Text(formatRupee(safeEmi), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Max loan: ${formatRupee(maxLoan)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _Pill('Disposable Income', formatRupee(disposable), Colors.white.withOpacity(0.15))),
                const SizedBox(width: 8),
                Expanded(child: _Pill('Current DTI', '${dti.toStringAsFixed(1)}%', AppColors.warning.withOpacity(0.35))),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          SliderCard(
            label: 'Monthly Salary (Take-Home)',
            value: _salary,
            min: 10000,
            max: 1000000,
            divisions: 99,
            format: formatRupee,
            color: AppColors.success,
            onChanged: (v) => setState(() => _salary = (v / 5000).round() * 5000.0),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Monthly Expenses (excl. EMIs)',
            value: _expenses,
            min: 5000,
            max: 500000,
            divisions: 99,
            format: formatRupee,
            color: AppColors.danger,
            onChanged: (v) => setState(() => _expenses = (v / 5000).round() * 5000.0),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Existing Monthly EMIs',
            value: _existingEmi,
            min: 0,
            max: 200000,
            divisions: 100,
            format: formatRupee,
            color: AppColors.warning,
            onChanged: (v) => setState(() => _existingEmi = (v / 2000).round() * 2000.0),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Loan Interest Rate (p.a.)',
            value: _interestRate,
            min: 5,
            max: 20,
            divisions: 150,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.accent,
            onChanged: (v) => setState(() => _interestRate = v),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Loan Tenure',
            value: _tenure,
            min: 1,
            max: 30,
            divisions: 29,
            format: (v) => '${v.toInt()} yrs',
            color: AppColors.purple,
            onChanged: (v) => setState(() => _tenure = v),
          ),
          const SizedBox(height: 16),

          // Breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Income Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 12),
              _IncomeBar(salary: _salary, expenses: _expenses, existingEmi: _existingEmi, safeEmi: safeEmi),
              const SizedBox(height: 12),
              DetailRow(label: 'Take-Home Salary', value: formatRupee(_salary), isBold: true),
              DetailRow(label: 'Monthly Expenses', value: '− ${formatRupee(_expenses)}', valueColor: AppColors.danger),
              DetailRow(label: 'Existing EMIs', value: '− ${formatRupee(_existingEmi)}', valueColor: AppColors.danger),
              DetailRow(label: 'Disposable Income', value: formatRupee(disposable), isBold: true),
              const Divider(height: 20),
              DetailRow(label: 'Max EMI (40% rule)', value: formatRupee(maxTotalEmi - _existingEmi)),
              DetailRow(label: 'Max EMI (50% disposable)', value: formatRupee(safeEmiDisposable)),
              DetailRow(label: 'Safe New EMI (lower)', value: formatRupee(safeEmi), isBold: true, valueColor: AppColors.success),
              DetailRow(label: 'Max Loan Amount', value: formatRupee(maxLoan), isBold: true, valueColor: AppColors.accent),
              const Divider(height: 20),
              DetailRow(label: 'Current DTI Ratio', value: '${dti.toStringAsFixed(1)}%'),
              DetailRow(label: 'After New Loan DTI', value: '${afterDti.toStringAsFixed(1)}%', valueColor: afterDti > 40 ? AppColors.danger : AppColors.success),
            ]),
          ),
          const SizedBox(height: 16),

          // Tips
          _TipsCard(dti: dti, afterDti: afterDti, safeEmi: safeEmi, salary: _salary),
          const BannerAdWidget(),
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _IncomeBar extends StatelessWidget {
  final double salary, expenses, existingEmi, safeEmi;
  const _IncomeBar({required this.salary, required this.expenses, required this.existingEmi, required this.safeEmi});

  @override
  Widget build(BuildContext context) {
    final double expPct = (expenses / salary).clamp(0, 1);
    final double emiPct = (existingEmi / salary).clamp(0, 1 - expPct);
    final double newEmiPct = (safeEmi / salary).clamp(0, 1 - expPct - emiPct);
    final double freePct = (1 - expPct - emiPct - newEmiPct).clamp(0, 1);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 16,
          child: Row(children: [
            if (expPct > 0) Expanded(flex: (expPct * 100).round(), child: Container(color: AppColors.danger)),
            if (emiPct > 0) Expanded(flex: (emiPct * 100).round(), child: Container(color: AppColors.warning)),
            if (newEmiPct > 0) Expanded(flex: (newEmiPct * 100).round(), child: Container(color: AppColors.accent)),
            if (freePct > 0) Expanded(flex: (freePct * 100).round(), child: Container(color: AppColors.successBg)),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(spacing: 12, runSpacing: 4, children: [
        _Legend(AppColors.danger, 'Expenses'),
        _Legend(AppColors.warning, 'Existing EMI'),
        _Legend(AppColors.accent, 'Safe New EMI'),
        _Legend(AppColors.successBg, 'Free'),
      ]),
    ]);
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMed)),
    ]);
  }
}

class _TipsCard extends StatelessWidget {
  final double dti, afterDti, safeEmi, salary;
  const _TipsCard({required this.dti, required this.afterDti, required this.safeEmi, required this.salary});

  @override
  Widget build(BuildContext context) {
    final tips = <String>[];
    if (dti > 30) tips.add('Your existing EMI burden is high (>30%). Consider prepaying loans before taking new ones.');
    if (afterDti > 40) tips.add('Total EMI after new loan exceeds 40% of income — lenders may reject the application.');
    if (safeEmi < salary * 0.05) tips.add('Very little room for new EMI. Reduce expenses or increase income first.');
    tips.add('Maintain 6 months\' expenses as emergency fund before taking on new debt.');
    tips.add('A higher credit score (750+) can get you a lower interest rate, increasing your loan eligibility.');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.accent.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.lightbulb_outline_rounded, color: AppColors.accent, size: 18),
          SizedBox(width: 8),
          Text('Smart Tips', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent)),
        ]),
        const SizedBox(height: 10),
        ...tips.take(3).map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('• ', style: TextStyle(fontSize: 13, color: AppColors.accent)),
            Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.textMed, height: 1.4))),
          ]),
        )),
      ]),
    );
  }
}
