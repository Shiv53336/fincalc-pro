import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/banner_ad_widget.dart';

class SsyCalculatorScreen extends StatefulWidget {
  const SsyCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<SsyCalculatorScreen> createState() => _SsyCalculatorScreenState();
}

class _SsyCalculatorScreenState extends State<SsyCalculatorScreen> {
  double _girlAge = 0;
  double _yearlyDeposit = 50000;
  double _interestRate = 8.2;

  // SSY rules: deposits for 15 years, matures at 21 years from opening
  // Account can be opened from birth to age 10
  static const int _depositYears = 15;
  static const int _maturityAge = 21;

  _SsyResult _calculate() {
    final double r = _interestRate / 100;
    final int maturityYear = _maturityAge - _girlAge.toInt();

    double balance = 0;
    double totalDeposited = 0;
    final List<_SsyYearRow> table = [];

    for (int year = 1; year <= maturityYear; year++) {
      final double deposit = year <= _depositYears ? _yearlyDeposit : 0;
      // Interest calculated on (prev balance + deposit)
      final double interest = (balance + deposit) * r;
      balance += deposit + interest;
      totalDeposited += deposit;

      table.add(_SsyYearRow(
        year: year,
        age: _girlAge.toInt() + year,
        deposit: deposit,
        interest: interest,
        balance: balance,
      ));
    }

    return _SsyResult(
      totalDeposited: totalDeposited,
      totalInterest: balance - totalDeposited,
      maturityAmount: balance,
      yearsToMaturity: maturityYear,
      table: table,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _calculate();

    return Scaffold(
      appBar: AppBar(title: const Text('SSY Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // EEE Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.4)),
            ),
            child: Row(children: [
              const Text('🏆', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tax-Free EEE Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
                Text('Exempt on investment · Exempt on interest · Exempt on maturity', style: TextStyle(fontSize: 11, color: AppColors.success)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),

          // Result card
          _ResultCard(result: result),
          const SizedBox(height: 16),

          SliderCard(
            label: "Girl's Current Age",
            value: _girlAge,
            min: 0,
            max: 10,
            divisions: 10,
            format: (v) => '${v.toInt()} yrs',
            color: AppColors.purple,
            onChanged: (v) => setState(() => _girlAge = v),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Yearly Deposit',
            value: _yearlyDeposit,
            min: 250,
            max: 150000,
            divisions: 299,
            format: formatRupee,
            color: AppColors.accent,
            onChanged: (v) => setState(() => _yearlyDeposit = (v / 500).round() * 500.0),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Interest Rate (p.a.)',
            value: _interestRate,
            min: 6,
            max: 10,
            divisions: 40,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.success,
            onChanged: (v) => setState(() => _interestRate = v),
          ),
          const SizedBox(height: 16),

          // Year-wise table
          _YearTable(table: result.table),
          const BannerAdWidget(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _SsyResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryLight]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        const Text('Maturity Amount', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Text(formatRupee(result.maturityAmount), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
        Text('at age ${21} (in ${result.yearsToMaturity} years)', style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _Pill('Total Deposited', formatRupee(result.totalDeposited), AppColors.accent.withOpacity(0.3))),
          const SizedBox(width: 8),
          Expanded(child: _Pill('Interest Earned', formatRupee(result.totalInterest), AppColors.success.withOpacity(0.3))),
        ]),
      ]),
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

class _YearTable extends StatelessWidget {
  final List<_SsyYearRow> table;
  const _YearTable({required this.table});

  @override
  Widget build(BuildContext context) {
    // Show only deposit years + a few milestone years
    final rows = table.where((r) => r.year <= 15 || r.year % 3 == 0 || r.age == 21).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Year-wise Growth', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Expanded(flex: 1, child: Text('Age', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
            Expanded(flex: 2, child: Text('Deposit', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            Expanded(flex: 2, child: Text('Interest', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            Expanded(flex: 2, child: Text('Balance', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          ]),
        ),
        ...rows.asMap().entries.map((e) {
          final r = e.value;
          final even = e.key % 2 == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: even ? AppColors.bg : Colors.white,
            child: Row(children: [
              Expanded(flex: 1, child: Text('${r.age}', style: const TextStyle(fontSize: 11, color: AppColors.textMed))),
              Expanded(flex: 2, child: Text(formatShortIndian(r.deposit), style: const TextStyle(fontSize: 11, color: AppColors.text), textAlign: TextAlign.right)),
              Expanded(flex: 2, child: Text(formatShortIndian(r.interest), style: const TextStyle(fontSize: 11, color: AppColors.success), textAlign: TextAlign.right)),
              Expanded(flex: 2, child: Text(formatShortIndian(r.balance), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary), textAlign: TextAlign.right)),
            ]),
          );
        }),
      ]),
    );
  }
}

class _SsyResult {
  final double totalDeposited, totalInterest, maturityAmount;
  final int yearsToMaturity;
  final List<_SsyYearRow> table;
  _SsyResult({required this.totalDeposited, required this.totalInterest, required this.maturityAmount, required this.yearsToMaturity, required this.table});
}

class _SsyYearRow {
  final int year, age;
  final double deposit, interest, balance;
  _SsyYearRow({required this.year, required this.age, required this.deposit, required this.interest, required this.balance});
}
