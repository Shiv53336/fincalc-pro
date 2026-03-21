import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/premium_gate.dart';
import '../services/premium_manager.dart';
import '../services/nudge_service.dart';
import '../widgets/premium_nudge_sheet.dart';
import '../widgets/banner_ad_widget.dart';

class FinancialHealthScoreScreen extends StatefulWidget {
  const FinancialHealthScoreScreen({Key? key}) : super(key: key);

  @override
  State<FinancialHealthScoreScreen> createState() => _FinancialHealthScoreScreenState();
}

class _FinancialHealthScoreScreenState extends State<FinancialHealthScoreScreen> {
  double _income = 100000;
  double _expenses = 60000;
  double _emi = 15000;
  double _investments = 10000;
  double _emergencyFund = 300000;
  bool _hasHealth = false;
  bool _hasLife = false;
  bool _has80C = false;

  @override
  void initState() {
    super.initState();
    // Nudge #4: score below 70 — offer detailed breakdown
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!PremiumManager.isPremium && _calculate().score < 70) {
        await PremiumNudgeSheet.showIfEligible(
          context,
          nudgeId: 'health_score_low',
          headline: 'Improve Your Financial Health',
          body: 'Your score needs work. Unlock a detailed 6-parameter breakdown with personalised improvement tips.',
          ctaLabel: 'Unlock Detailed Plan',
        );
      }
    });
  }

  _HealthResult _calculate() {
    double score = 0;
    final List<_ScoreParam> params = [];

    // 1. Savings Rate (max 25)
    final double savingsRate = _income > 0 ? (_income - _expenses - _emi) / _income * 100 : 0;
    double savingsScore;
    if (savingsRate >= 30) savingsScore = 25;
    else if (savingsRate >= 20) savingsScore = 18;
    else if (savingsRate >= 10) savingsScore = 10;
    else if (savingsRate > 0) savingsScore = 5;
    else savingsScore = 0;
    score += savingsScore;
    params.add(_ScoreParam('Savings Rate', savingsScore, 25, '${savingsRate.toStringAsFixed(1)}% of income saved'));

    // 2. EMI-to-Income Ratio (max 20)
    final double emiRatio = _income > 0 ? _emi / _income * 100 : 100;
    double emiScore;
    if (emiRatio <= 20) emiScore = 20;
    else if (emiRatio <= 30) emiScore = 15;
    else if (emiRatio <= 40) emiScore = 8;
    else if (emiRatio <= 50) emiScore = 3;
    else emiScore = 0;
    score += emiScore;
    params.add(_ScoreParam('EMI-to-Income Ratio', emiScore, 20, '${emiRatio.toStringAsFixed(1)}% of income on EMIs'));

    // 3. Investment Rate (max 20)
    final double investRate = _income > 0 ? _investments / _income * 100 : 0;
    double investScore;
    if (investRate >= 20) investScore = 20;
    else if (investRate >= 15) investScore = 15;
    else if (investRate >= 10) investScore = 10;
    else if (investRate >= 5) investScore = 5;
    else investScore = 0;
    score += investScore;
    params.add(_ScoreParam('Investment Rate', investScore, 20, '${investRate.toStringAsFixed(1)}% of income invested'));

    // 4. Emergency Fund (max 15)
    final double monthsOfExpenses = (_expenses + _emi) > 0 ? _emergencyFund / (_expenses + _emi) : 0;
    double emergencyScore;
    if (monthsOfExpenses >= 6) emergencyScore = 15;
    else if (monthsOfExpenses >= 3) emergencyScore = 8;
    else if (monthsOfExpenses >= 1) emergencyScore = 4;
    else emergencyScore = 0;
    score += emergencyScore;
    params.add(_ScoreParam('Emergency Fund', emergencyScore, 15, '${monthsOfExpenses.toStringAsFixed(1)} months of expenses'));

    // 5. Insurance (max 10)
    double insuranceScore = 0;
    if (_hasHealth && _hasLife) insuranceScore = 10;
    else if (_hasHealth || _hasLife) insuranceScore = 5;
    score += insuranceScore;
    params.add(_ScoreParam('Insurance Coverage', insuranceScore, 10, _hasHealth && _hasLife ? 'Both health & life' : (_hasHealth || _hasLife) ? 'Partial coverage' : 'No insurance'));

    // 6. Tax Optimization (max 10)
    final double taxScore = _has80C ? 10 : 0;
    score += taxScore;
    params.add(_ScoreParam('Tax Optimization', taxScore, 10, _has80C ? '80C fully utilized' : '80C not utilized'));

    // Rating
    String rating;
    Color ratingColor;
    String emoji;
    if (score >= 90) { rating = 'Excellent'; ratingColor = AppColors.success; emoji = '🌟'; }
    else if (score >= 70) { rating = 'Good'; ratingColor = AppColors.accent; emoji = '👍'; }
    else if (score >= 50) { rating = 'Needs Work'; ratingColor = AppColors.warning; emoji = '⚠️'; }
    else { rating = 'At Risk'; ratingColor = AppColors.danger; emoji = '🚨'; }

    // Top 3 tips
    final List<String> tips = [];
    final sorted = List<_ScoreParam>.from(params)
      ..sort((a, b) => (a.score / a.maxScore).compareTo(b.score / b.maxScore));
    for (final p in sorted) {
      if (tips.length >= 3) break;
      if (p.score < p.maxScore) {
        tips.add(_tipFor(p.name, p.score, p.maxScore));
      }
    }

    return _HealthResult(
      score: score.round(),
      rating: rating,
      ratingColor: ratingColor,
      emoji: emoji,
      params: params,
      tips: tips,
      savingsRate: savingsRate,
    );
  }

  String _tipFor(String name, double score, double maxScore) {
    switch (name) {
      case 'Savings Rate': return 'Increase savings to at least 30% of income. Cut discretionary expenses.';
      case 'EMI-to-Income Ratio': return 'Reduce EMI burden below 30% of income. Consider prepayment.';
      case 'Investment Rate': return 'Invest at least 20% of income in SIP/ELSS/NPS for wealth creation.';
      case 'Emergency Fund': return 'Build an emergency fund of 6 months\' expenses in liquid instruments.';
      case 'Insurance Coverage': return 'Get health insurance (min Rs.5L cover) and term life insurance.';
      case 'Tax Optimization': return 'Utilize Section 80C limit (Rs.1.5L) via PPF, ELSS, NPS, LIC.';
      default: return 'Improve $name for a better score.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _calculate();

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Health Score')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Score gauge — always visible (free)
          _ScoreGauge(result: result),
          const SizedBox(height: 16),

          // Inputs
          _InputSection(
            income: _income,
            expenses: _expenses,
            emi: _emi,
            investments: _investments,
            emergencyFund: _emergencyFund,
            hasHealth: _hasHealth,
            hasLife: _hasLife,
            has80C: _has80C,
            onIncomeChanged: (v) => setState(() => _income = v),
            onExpensesChanged: (v) => setState(() => _expenses = v),
            onEmiChanged: (v) => setState(() => _emi = v),
            onInvestmentsChanged: (v) => setState(() => _investments = v),
            onEmergencyChanged: (v) => setState(() => _emergencyFund = v),
            onHealthChanged: (v) => setState(() => _hasHealth = v),
            onLifeChanged: (v) => setState(() => _hasLife = v),
            on80CChanged: (v) => setState(() => _has80C = v),
          ),
          const SizedBox(height: 16),

          // Share card button (free)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _shareScore(result),
              icon: const Icon(Icons.share_rounded),
              label: Text('Share My Score: ${result.score}/100'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Detailed breakdown — premium gated
          PremiumGate(
            featureName: 'Detailed Health Breakdown',
            child: _DetailedBreakdown(result: result),
          ),
          const BannerAdWidget(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  void _shareScore(_HealthResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.emoji} My Financial Health Score is ${result.score}/100 — ${result.rating}! Check yours on FinCalc Pro.'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ─── Score Gauge ─────────────────────────────
class _ScoreGauge extends StatelessWidget {
  final _HealthResult result;
  const _ScoreGauge({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        Text(result.emoji, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(
          '${result.score}',
          style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.w900, height: 1),
        ),
        const Text('/100', style: TextStyle(color: Colors.white54, fontSize: 18)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: result.ratingColor.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: result.ratingColor.withOpacity(0.5)),
          ),
          child: Text(result.rating, style: TextStyle(color: result.ratingColor, fontSize: 14, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 16),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(children: [
            Container(height: 10, color: Colors.white.withOpacity(0.2)),
            FractionallySizedBox(
              widthFactor: result.score / 100,
              child: Container(height: 10, color: result.ratingColor),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Input Section ────────────────────────────
class _InputSection extends StatelessWidget {
  final double income, expenses, emi, investments, emergencyFund;
  final bool hasHealth, hasLife, has80C;
  final ValueChanged<double> onIncomeChanged, onExpensesChanged, onEmiChanged, onInvestmentsChanged, onEmergencyChanged;
  final ValueChanged<bool> onHealthChanged, onLifeChanged, on80CChanged;

  const _InputSection({
    required this.income, required this.expenses, required this.emi,
    required this.investments, required this.emergencyFund,
    required this.hasHealth, required this.hasLife, required this.has80C,
    required this.onIncomeChanged, required this.onExpensesChanged,
    required this.onEmiChanged, required this.onInvestmentsChanged,
    required this.onEmergencyChanged,
    required this.onHealthChanged, required this.onLifeChanged, required this.on80CChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SliderCard(label: 'Monthly Income', value: income, min: 10000, max: 1000000, divisions: 99, format: formatRupee, color: AppColors.success,
          onChanged: (v) => onIncomeChanged((v / 5000).round() * 5000.0)),
      const SizedBox(height: 12),
      SliderCard(label: 'Monthly Expenses', value: expenses, min: 5000, max: 500000, divisions: 99, format: formatRupee, color: AppColors.danger,
          onChanged: (v) => onExpensesChanged((v / 5000).round() * 5000.0)),
      const SizedBox(height: 12),
      SliderCard(label: 'Monthly EMI Total', value: emi, min: 0, max: 200000, divisions: 100, format: formatRupee, color: AppColors.warning,
          onChanged: (v) => onEmiChanged((v / 2000).round() * 2000.0)),
      const SizedBox(height: 12),
      SliderCard(label: 'Monthly Investments (SIP/PPF etc.)', value: investments, min: 0, max: 200000, divisions: 100, format: formatRupee, color: AppColors.accent,
          onChanged: (v) => onInvestmentsChanged((v / 1000).round() * 1000.0)),
      const SizedBox(height: 12),
      SliderCard(label: 'Emergency Fund', value: emergencyFund, min: 0, max: 5000000, divisions: 100, format: formatRupee, color: AppColors.purple,
          onChanged: (v) => onEmergencyChanged((v / 50000).round() * 50000.0)),
      const SizedBox(height: 12),

      // Toggle section
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Protection & Tax', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 12),
          _Toggle('Health Insurance', '🏥', hasHealth, onHealthChanged),
          const SizedBox(height: 8),
          _Toggle('Life Insurance / Term Plan', '🛡', hasLife, onLifeChanged),
          const SizedBox(height: 8),
          _Toggle('Section 80C Fully Utilized', '💰', has80C, on80CChanged),
        ]),
      ),
    ]);
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final String icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle(this.label, this.icon, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: value ? AppColors.successLight : AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value ? AppColors.success : AppColors.border),
        ),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: value ? AppColors.success : AppColors.text))),
          Icon(value ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: value ? AppColors.success : AppColors.textLight, size: 22),
        ]),
      ),
    );
  }
}

// ─── Detailed Breakdown (Premium) ────────────
class _DetailedBreakdown extends StatelessWidget {
  final _HealthResult result;
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
        const Text('Score Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        ...result.params.map((p) => _ParamRow(p)),
        const Divider(height: 24),
        const Text('Top Improvement Tips', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 8),
        ...result.tips.asMap().entries.map((e) => _TipRow(e.key + 1, e.value)),
      ]),
    );
  }
}

class _ParamRow extends StatelessWidget {
  final _ScoreParam param;
  const _ParamRow(this.param);

  @override
  Widget build(BuildContext context) {
    final double pct = param.maxScore > 0 ? param.score / param.maxScore : 0;
    final Color barColor = pct >= 0.8 ? AppColors.success : pct >= 0.5 ? AppColors.warning : AppColors.danger;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(param.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
            Text(param.detail, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
          ])),
          Text('${param.score.toInt()}/${param.maxScore.toInt()}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: barColor)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(children: [
            Container(height: 6, color: AppColors.bg),
            FractionallySizedBox(
              widthFactor: pct,
              child: Container(height: 6, color: barColor),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _TipRow extends StatelessWidget {
  final int num;
  final String tip;
  const _TipRow(this.num, this.tip);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(6)),
          child: Center(child: Text('$num', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(tip, style: const TextStyle(fontSize: 12, color: AppColors.textMed, height: 1.4))),
      ]),
    );
  }
}

// ─── Data models ──────────────────────────────
class _HealthResult {
  final int score;
  final String rating;
  final Color ratingColor;
  final String emoji;
  final List<_ScoreParam> params;
  final List<String> tips;
  final double savingsRate;
  _HealthResult({required this.score, required this.rating, required this.ratingColor, required this.emoji, required this.params, required this.tips, required this.savingsRate});
}

class _ScoreParam {
  final String name;
  final double score;
  final double maxScore;
  final String detail;
  _ScoreParam(this.name, this.score, this.maxScore, this.detail);
}
