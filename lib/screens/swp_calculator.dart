import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/banner_ad_widget.dart';

class SwpCalculatorScreen extends StatefulWidget {
  const SwpCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<SwpCalculatorScreen> createState() => _SwpCalculatorScreenState();
}

class _SwpCalculatorScreenState extends State<SwpCalculatorScreen> {
  double _corpus = 5000000;
  double _monthlyWithdrawal = 25000;
  double _returnRate = 8;
  double _years = 15;

  _SwpResult _calculate() {
    final double r = _returnRate / 100 / 12;
    final int months = (_years * 12).round();
    double balance = _corpus;
    double totalWithdrawn = 0;
    double totalEarned = 0;
    int monthsActual = 0;
    final List<_SwpYearRow> yearTable = [];

    for (int month = 1; month <= months; month++) {
      if (balance <= 0) break;
      final double interest = balance * r;
      totalEarned += interest;
      balance += interest;
      final double withdrawn = _monthlyWithdrawal.clamp(0, balance);
      balance -= withdrawn;
      totalWithdrawn += withdrawn;
      monthsActual = month;

      if (month % 12 == 0 || month == months || balance <= 0) {
        // For the final partial year, only count actual months of withdrawal
        final int monthInYear = month % 12 == 0 ? 12 : month % 12;
        final bool isPartialYear = balance <= 0 && month % 12 != 0;
        yearTable.add(_SwpYearRow(
          year: (month / 12).ceil(),
          withdrawn: isPartialYear ? _monthlyWithdrawal * monthInYear : _monthlyWithdrawal * 12,
          earned: totalEarned,
          balance: max(balance, 0),
        ));
      }

      if (balance <= 0) break;
    }

    final bool corpusExhausted = balance <= 0;
    final int yearsLast = corpusExhausted ? (monthsActual / 12).ceil() : months ~/ 12;

    return _SwpResult(
      remainingBalance: max(balance, 0),
      totalWithdrawn: totalWithdrawn,
      totalEarned: totalEarned,
      corpusExhausted: corpusExhausted,
      yearsLast: yearsLast,
      monthsActual: monthsActual,
      yearTable: yearTable,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _calculate();

    return Scaffold(
      appBar: AppBar(title: const Text('SWP Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _ResultCard(result: result, corpus: _corpus),
          const SizedBox(height: 16),

          SliderCard(
            label: 'Initial Corpus',
            value: _corpus,
            min: 100000,
            max: 50000000,
            divisions: 99,
            format: formatRupee,
            color: AppColors.accent,
            onChanged: (v) => setState(() => _corpus = (v / 100000).round() * 100000.0),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Monthly Withdrawal',
            value: _monthlyWithdrawal,
            min: 1000,
            max: 500000,
            divisions: 499,
            format: formatRupee,
            color: AppColors.danger,
            onChanged: (v) => setState(() => _monthlyWithdrawal = (v / 1000).round() * 1000.0),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Expected Return (p.a.)',
            value: _returnRate,
            min: 3,
            max: 15,
            divisions: 120,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.success,
            onChanged: (v) => setState(() => _returnRate = v),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Withdrawal Period',
            value: _years,
            min: 1,
            max: 40,
            divisions: 39,
            format: (v) => '${v.toInt()} yrs',
            color: AppColors.warning,
            onChanged: (v) => setState(() => _years = v),
          ),
          const SizedBox(height: 16),

          _YearTable(rows: result.yearTable),
          const BannerAdWidget(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _SwpResult result;
  final double corpus;
  const _ResultCard({required this.result, required this.corpus});

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
        if (result.corpusExhausted) ...[
          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
          const SizedBox(height: 4),
          const Text('Corpus Exhausted', style: TextStyle(color: Colors.white70, fontSize: 13)),
          Text('Lasts ${result.yearsLast} years ${result.monthsActual % 12} months', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        ] else ...[
          const Text('Remaining Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(formatRupee(result.remainingBalance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          const Text('after the withdrawal period', style: TextStyle(color: Colors.white60, fontSize: 12)),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _Pill('Total Withdrawn', formatRupee(result.totalWithdrawn), AppColors.danger.withOpacity(0.3))),
          const SizedBox(width: 8),
          Expanded(child: _Pill('Total Earned', formatRupee(result.totalEarned), AppColors.success.withOpacity(0.3))),
        ]),
      ]),
    );
  }
}

class _YearTable extends StatelessWidget {
  final List<_SwpYearRow> rows;
  const _YearTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Year-wise Balance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Expanded(flex: 1, child: Text('Year', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
            Expanded(flex: 2, child: Text('Withdrawn', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            Expanded(flex: 2, child: Text('Balance', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          ]),
        ),
        ...rows.asMap().entries.map((e) {
          final r = e.value;
          final even = e.key % 2 == 0;
          final isExhausted = r.balance <= 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: even ? AppColors.bg : Colors.white,
            child: Row(children: [
              Expanded(flex: 1, child: Text('${r.year}', style: const TextStyle(fontSize: 11, color: AppColors.textMed))),
              Expanded(flex: 2, child: Text(formatShortIndian(r.withdrawn), style: const TextStyle(fontSize: 11, color: AppColors.danger), textAlign: TextAlign.right)),
              Expanded(flex: 2, child: Text(isExhausted ? 'Exhausted' : formatShortIndian(r.balance),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isExhausted ? AppColors.danger : AppColors.primary), textAlign: TextAlign.right)),
            ]),
          );
        }),
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

class _SwpResult {
  final double remainingBalance, totalWithdrawn, totalEarned;
  final bool corpusExhausted;
  final int yearsLast, monthsActual;
  final List<_SwpYearRow> yearTable;
  _SwpResult({required this.remainingBalance, required this.totalWithdrawn, required this.totalEarned, required this.corpusExhausted, required this.yearsLast, required this.monthsActual, required this.yearTable});
}

class _SwpYearRow {
  final int year;
  final double withdrawn, earned, balance;
  _SwpYearRow({required this.year, required this.withdrawn, required this.earned, required this.balance});
}
