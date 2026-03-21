import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/premium_gate.dart';
import '../services/premium_manager.dart';
import '../services/prepayment_pdf.dart';
import '../widgets/banner_ad_widget.dart';

// ─── Public model classes ───────────────────
class PrepaymentResult {
  final double emi;
  final double totalInterestWithout;
  final double totalInterestWith;
  final double interestSaved;
  final int originalMonths;
  final int newMonths;
  final int yearsSaved;
  final int monthsSaved;
  final List<PrepaymentMonthRow> table;

  PrepaymentResult({
    required this.emi,
    required this.totalInterestWithout,
    required this.totalInterestWith,
    required this.interestSaved,
    required this.originalMonths,
    required this.newMonths,
    required this.yearsSaved,
    required this.monthsSaved,
    required this.table,
  });
}

class PrepaymentMonthRow {
  final int month;
  final double payment;
  final double interest;
  final double principal;
  final double balance;
  PrepaymentMonthRow(this.month, this.payment, this.interest, this.principal, this.balance);
}

// ─── Screen ─────────────────────────────────
class PrepaymentCalculatorScreen extends StatefulWidget {
  const PrepaymentCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<PrepaymentCalculatorScreen> createState() => _PrepaymentCalculatorScreenState();
}

class _PrepaymentCalculatorScreenState extends State<PrepaymentCalculatorScreen> {
  double _loanAmount = 3000000;
  double _interestRate = 8.5;
  double _tenureYears = 20;
  double _prepaymentAmount = 200000;
  String _prepaymentType = 'one_time';
  int _prepaymentYear = 3;

  late PrepaymentResult _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    _result = _compute();
  }

  PrepaymentResult _compute() {
    final int tenureMonths = (_tenureYears * 12).round();
    final double r = _interestRate / 100 / 12;
    final double emi = r == 0
        ? _loanAmount / tenureMonths
        : _loanAmount * r * pow(1 + r, tenureMonths) / (pow(1 + r, tenureMonths) - 1);

    // Interest without prepayment
    final double interestWithout = (emi * tenureMonths) - _loanAmount;

    // Simulate with prepayment
    double balance = _loanAmount;
    double totalInterestWith = 0;
    int monthsActual = 0;
    final List<PrepaymentMonthRow> table = [];

    for (int month = 1; month <= tenureMonths * 2; month++) {
      if (balance <= 0) break;
      final double interest = balance * r;
      double principal = emi - interest;
      if (principal > balance) principal = balance;
      totalInterestWith += interest;
      balance -= principal;

      double extra = 0;
      if (_prepaymentType == 'one_time' && month == _prepaymentYear * 12) {
        extra = min(_prepaymentAmount, max(balance, 0));
        balance -= extra;
      } else if (_prepaymentType == 'yearly' && month % 12 == 0) {
        extra = min(_prepaymentAmount, max(balance, 0));
        balance -= extra;
      } else if (_prepaymentType == 'monthly') {
        extra = min(_prepaymentAmount, max(balance, 0));
        balance -= extra;
      }

      if (month <= 12 || month % 12 == 0 || balance <= 0) {
        table.add(PrepaymentMonthRow(month, emi + extra, interest, principal + extra, max(balance, 0)));
      }

      monthsActual = month;
      if (balance <= 0) break;
    }

    final double interestSaved = interestWithout - totalInterestWith;
    final int monthsSaved = tenureMonths - monthsActual;

    return PrepaymentResult(
      emi: emi,
      totalInterestWithout: interestWithout,
      totalInterestWith: totalInterestWith,
      interestSaved: interestSaved.clamp(0, double.infinity),
      originalMonths: tenureMonths,
      newMonths: monthsActual,
      yearsSaved: monthsSaved > 0 ? monthsSaved ~/ 12 : 0,
      monthsSaved: monthsSaved > 0 ? monthsSaved % 12 : 0,
      table: table,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Prepayment Simulator'),
        actions: [
          if (PremiumManager.isPremium)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              onPressed: () => PrepaymentPdfGenerator.generateAndShare(
                context,
                loanAmount: _loanAmount,
                interestRate: _interestRate,
                tenureYears: _tenureYears.toInt(),
                prepaymentAmount: _prepaymentAmount,
                prepaymentType: _prepaymentType,
                result: _result,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _ResultCard(result: _result),
          const SizedBox(height: 16),
          SliderCard(
            label: 'Loan Amount',
            value: _loanAmount,
            min: 100000,
            max: 10000000,
            divisions: 99,
            format: formatRupee,
            color: AppColors.accent,
            onChanged: (v) => setState(() { _loanAmount = (v / 100000).round() * 100000.0; _calculate(); }),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Interest Rate (p.a.)',
            value: _interestRate,
            min: 5,
            max: 20,
            divisions: 150,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.warning,
            onChanged: (v) => setState(() { _interestRate = v; _calculate(); }),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Loan Tenure',
            value: _tenureYears,
            min: 1,
            max: 30,
            divisions: 29,
            format: (v) => '${v.toInt()} yrs',
            color: AppColors.purple,
            onChanged: (v) => setState(() { _tenureYears = v; _calculate(); }),
          ),
          const SizedBox(height: 12),
          _PrepaymentInputCard(
            prepaymentType: _prepaymentType,
            prepaymentAmount: _prepaymentAmount,
            prepaymentYear: _prepaymentYear,
            maxYear: _tenureYears.toInt(),
            onTypeChanged: (t) => setState(() { _prepaymentType = t; _calculate(); }),
            onAmountChanged: (v) => setState(() { _prepaymentAmount = v; _calculate(); }),
            onYearChanged: (y) => setState(() { _prepaymentYear = y; _calculate(); }),
          ),
          const SizedBox(height: 16),

          // Premium gated detail breakdown
          PremiumGate(
            featureName: 'Full Prepayment Analysis',
            child: _DetailedBreakdown(result: _result),
          ),
          const BannerAdWidget(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ─── Result Card ─────────────────────────────
class _ResultCard extends StatelessWidget {
  final PrepaymentResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        const Text('Interest Saved', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          formatRupee(result.interestSaved),
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            result.yearsSaved > 0 || result.monthsSaved > 0
                ? '${result.yearsSaved > 0 ? "${result.yearsSaved} yr " : ""}${result.monthsSaved > 0 ? "${result.monthsSaved} mo" : ""} saved'
                : 'No tenure reduction',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _StatPill('Without Prepayment', formatRupee(result.totalInterestWithout), AppColors.danger.withOpacity(0.3))),
          const SizedBox(width: 8),
          Expanded(child: _StatPill('With Prepayment', formatRupee(result.totalInterestWith), AppColors.success.withOpacity(0.3))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _StatPill('Monthly EMI', formatRupee(result.emi), Colors.white.withOpacity(0.15))),
          const SizedBox(width: 8),
          Expanded(child: _StatPill('New Tenure', '${(result.newMonths / 12).toStringAsFixed(1)} yrs', Colors.white.withOpacity(0.15))),
        ]),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  const _StatPill(this.label, this.value, this.bg);

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

// ─── Prepayment Input Card ───────────────────
class _PrepaymentInputCard extends StatelessWidget {
  final String prepaymentType;
  final double prepaymentAmount;
  final int prepaymentYear;
  final int maxYear;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<int> onYearChanged;

  const _PrepaymentInputCard({
    required this.prepaymentType,
    required this.prepaymentAmount,
    required this.prepaymentYear,
    required this.maxYear,
    required this.onTypeChanged,
    required this.onAmountChanged,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Prepayment Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        Row(children: [
          _TypeBtn('One-Time', 'one_time', prepaymentType, onTypeChanged),
          const SizedBox(width: 8),
          _TypeBtn('Yearly', 'yearly', prepaymentType, onTypeChanged),
          const SizedBox(width: 8),
          _TypeBtn('Monthly', 'monthly', prepaymentType, onTypeChanged),
        ]),
        const SizedBox(height: 16),
        SliderCard(
          label: prepaymentType == 'monthly' ? 'Extra Monthly Amount' : 'Prepayment Amount',
          value: prepaymentAmount,
          min: 10000,
          max: 2000000,
          divisions: 199,
          format: formatRupee,
          color: AppColors.success,
          onChanged: (v) => onAmountChanged((v / 10000).round() * 10000.0),
        ),
        if (prepaymentType == 'one_time') ...[
          const SizedBox(height: 12),
          SliderCard(
            label: 'Prepayment in Year',
            value: prepaymentYear.toDouble(),
            min: 1,
            max: maxYear.toDouble().clamp(2, 30),
            divisions: (maxYear - 1).clamp(1, 29),
            format: (v) => 'Year ${v.toInt()}',
            color: AppColors.accent,
            onChanged: (v) => onYearChanged(v.toInt()),
          ),
        ],
      ]),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final String type;
  final String current;
  final ValueChanged<String> onTap;
  const _TypeBtn(this.label, this.type, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final bool active = current == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppColors.accent : AppColors.border),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.textMed,
            )),
          ),
        ),
      ),
    );
  }
}

// ─── Detailed Breakdown (Premium) ────────────
class _DetailedBreakdown extends StatelessWidget {
  final PrepaymentResult result;
  const _DetailedBreakdown({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Amortization Comparison', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        _SavingsBar(without: result.totalInterestWithout, saved: result.interestSaved),
        const SizedBox(height: 16),
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Expanded(flex: 2, child: Text('Month', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
            Expanded(flex: 3, child: Text('Payment', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            Expanded(flex: 3, child: Text('Interest', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            Expanded(flex: 3, child: Text('Balance', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          ]),
        ),
        ...result.table.asMap().entries.map((e) {
          final row = e.value;
          final even = e.key % 2 == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: even ? AppColors.bg : Colors.white,
            child: Row(children: [
              Expanded(flex: 2, child: Text('${row.month}', style: const TextStyle(fontSize: 11, color: AppColors.textMed))),
              Expanded(flex: 3, child: Text(formatShortIndian(row.payment), style: const TextStyle(fontSize: 11, color: AppColors.text), textAlign: TextAlign.right)),
              Expanded(flex: 3, child: Text(formatShortIndian(row.interest), style: const TextStyle(fontSize: 11, color: AppColors.danger), textAlign: TextAlign.right)),
              Expanded(flex: 3, child: Text(formatShortIndian(row.balance), style: const TextStyle(fontSize: 11, color: AppColors.textMed), textAlign: TextAlign.right)),
            ]),
          );
        }),
      ]),
    );
  }
}

class _SavingsBar extends StatelessWidget {
  final double without;
  final double saved;
  const _SavingsBar({required this.without, required this.saved});

  @override
  Widget build(BuildContext context) {
    final double pct = without > 0 ? (saved / without).clamp(0.0, 1.0) : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Original interest: ${formatRupee(without)}', style: const TextStyle(fontSize: 12, color: AppColors.textMed)),
        Text('Saved: ${(pct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(children: [
          Container(height: 12, color: AppColors.dangerLight),
          FractionallySizedBox(
            widthFactor: pct,
            child: Container(height: 12, color: AppColors.success),
          ),
        ]),
      ),
    ]);
  }
}
