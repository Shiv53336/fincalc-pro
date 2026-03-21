import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/banner_ad_widget.dart';

class RdCalculatorScreen extends StatefulWidget {
  const RdCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<RdCalculatorScreen> createState() => _RdCalculatorScreenState();
}

class _RdCalculatorScreenState extends State<RdCalculatorScreen> {
  double _monthly = 5000;
  double _rate = 7;
  double _tenureMonths = 24;

  _RdResult _calculate() {
    final int n = _tenureMonths.toInt();
    final double r = _rate / 100 / 4; // quarterly rate
    // RD maturity formula (quarterly compounding):
    // M = R × [(1+r)^n - 1] / (1 - (1+r)^(-1/3))
    // Simpler: simulate month by month with quarterly compounding
    double balance = 0;
    for (int m = 1; m <= n; m++) {
      balance += _monthly;
      if (m % 3 == 0) {
        balance *= (1 + r);
      }
    }
    // Handle remaining months that didn't complete a quarter
    final int rem = n % 3;
    if (rem > 0) {
      // Partial quarter: simple interest for partial period
      balance += balance * (_rate / 100) * rem / 12;
    }

    final double totalDeposited = _monthly * n;
    final double interest = balance - totalDeposited;

    // Quarter-wise breakdown (show every quarter)
    final List<_QtrRow> qtrTable = [];
    double runBal = 0;
    for (int q = 1; q <= (n / 3).ceil(); q++) {
      final int startMonth = (q - 1) * 3 + 1;
      final int endMonth = (q * 3).clamp(0, n);
      final double qDeposit = _monthly * (endMonth - startMonth + 1);
      runBal += qDeposit;
      if (q * 3 <= n) {
        runBal *= (1 + r);
      }
      qtrTable.add(_QtrRow(quarter: q, deposit: qDeposit, balance: runBal));
    }

    return _RdResult(totalDeposited: totalDeposited, interest: interest, maturity: balance, qtrTable: qtrTable);
  }

  @override
  Widget build(BuildContext context) {
    final result = _calculate();

    return Scaffold(
      appBar: AppBar(title: const Text('RD Calculator')),
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
              const Text('Maturity Value', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(formatRupee(result.maturity), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              Text('in ${_tenureMonths.toInt()} months', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _Pill('Total Deposited', formatRupee(result.totalDeposited), AppColors.accent.withOpacity(0.3))),
                const SizedBox(width: 8),
                Expanded(child: _Pill('Interest Earned', formatRupee(result.interest), AppColors.success.withOpacity(0.3))),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          SliderCard(
            label: 'Monthly Deposit',
            value: _monthly,
            min: 500,
            max: 100000,
            divisions: 199,
            format: formatRupee,
            color: AppColors.accent,
            onChanged: (v) => setState(() => _monthly = (v / 500).round() * 500.0),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Interest Rate (p.a.)',
            value: _rate,
            min: 3,
            max: 10,
            divisions: 70,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.success,
            onChanged: (v) => setState(() => _rate = v),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Tenure',
            value: _tenureMonths,
            min: 6,
            max: 120,
            divisions: 114,
            format: (v) => '${v.toInt()} mo',
            color: AppColors.warning,
            onChanged: (v) => setState(() => _tenureMonths = v),
          ),
          const SizedBox(height: 16),

          // Quarter-wise table
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Quarter-wise Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Expanded(flex: 1, child: Text('Qtr', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text('Deposit', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text('Balance', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                ]),
              ),
              ...result.qtrTable.asMap().entries.map((e) {
                final r = e.value;
                final even = e.key % 2 == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  color: even ? AppColors.bg : Colors.white,
                  child: Row(children: [
                    Expanded(flex: 1, child: Text('Q${r.quarter}', style: const TextStyle(fontSize: 11, color: AppColors.textMed))),
                    Expanded(flex: 2, child: Text(formatShortIndian(r.deposit), style: const TextStyle(fontSize: 11, color: AppColors.text), textAlign: TextAlign.right)),
                    Expanded(flex: 2, child: Text(formatShortIndian(r.balance), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary), textAlign: TextAlign.right)),
                  ]),
                );
              }),
            ]),
          ),
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

class _RdResult {
  final double totalDeposited, interest, maturity;
  final List<_QtrRow> qtrTable;
  _RdResult({required this.totalDeposited, required this.interest, required this.maturity, required this.qtrTable});
}

class _QtrRow {
  final int quarter;
  final double deposit, balance;
  _QtrRow({required this.quarter, required this.deposit, required this.balance});
}
