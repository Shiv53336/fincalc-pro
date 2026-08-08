import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/premium_gate.dart';
import '../services/premium_manager.dart';
import '../widgets/banner_ad_widget.dart';

class GoalPlannerScreen extends StatefulWidget {
  const GoalPlannerScreen({Key? key}) : super(key: key);

  @override
  State<GoalPlannerScreen> createState() => _GoalPlannerScreenState();
}

class _GoalPlannerScreenState extends State<GoalPlannerScreen> {
  // Goal type
  final List<Map<String, dynamic>> _goalTypes = [
    {'label': 'House', 'icon': '🏠', 'default': 10000000},
    {'label': 'Car', 'icon': '🚗', 'default': 1500000},
    {'label': 'Child Education', 'icon': '🎓', 'default': 3000000},
    {'label': 'Retirement', 'icon': '🏖', 'default': 30000000},
    {'label': 'Wedding', 'icon': '💒', 'default': 2000000},
    {'label': 'Emergency Fund', 'icon': '🛡', 'default': 600000},
    {'label': 'Custom', 'icon': '⭐', 'default': 1000000},
  ];

  int _selectedGoalType = 0;
  double _targetAmount = 5000000;
  double _timeHorizon = 10;
  double _returnRate = 12;
  double _inflationRate = 6;

  int _savedGoalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadGoalCount();
  }

  Future<void> _loadGoalCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedGoalCount = prefs.getInt('goal_count') ?? 0;
    });
  }

  Future<void> _saveGoal() async {
    if (!PremiumManager.isPremium && _savedGoalCount >= 1) {
      _showPremiumPrompt();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final count = (_savedGoalCount) + 1;
    await prefs.setInt('goal_count', count);
    setState(() => _savedGoalCount = count);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goal saved!'), backgroundColor: AppColors.success),
    );
  }

  void _showPremiumPrompt() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Upgrade to Premium', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Free users can create 1 goal. Upgrade to Premium for unlimited goals with detailed projections and milestone tracker.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text('Unlock Rs.99'),
          ),
        ],
      ),
    );
  }

  _GoalResult _calculate() {
    final double r = _returnRate / 100;
    final double inf = _inflationRate / 100;
    final int years = _timeHorizon.toInt();

    // Inflation-adjusted target
    final double inflatedTarget = _targetAmount * pow(1 + inf, years);

    // Monthly SIP needed (FV formula reversed)
    final double rm = _returnRate / 100 / 12;
    final int months = years * 12;
    final double sip = rm == 0
        ? inflatedTarget / months
        : inflatedTarget * rm / (pow(1 + rm, months) - 1);

    // Lump sum needed today
    final double lumpSum = _targetAmount / pow(1 + r, years);

    // Year-wise projection using correct monthly SIP compounding
    final List<_YearRow> projection = [];
    for (int y = 1; y <= years; y++) {
      final int m = y * 12;
      final double corpus = rm == 0
          ? sip * m
          : sip * (pow(1 + rm, m) - 1) / rm * (1 + rm);
      projection.add(_YearRow(y, sip * m, corpus));
    }

    return _GoalResult(
      inflatedTarget: inflatedTarget,
      monthlySip: sip,
      lumpSumToday: lumpSum,
      projection: projection,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _calculate();
    final goalType = _goalTypes[_selectedGoalType];

    return Scaffold(
      appBar: AppBar(title: const Text('Goal-Based Planner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Goal type selector
          _GoalTypeSelector(
            goalTypes: _goalTypes,
            selected: _selectedGoalType,
            onSelect: (i) => setState(() {
              _selectedGoalType = i;
              _targetAmount = (_goalTypes[i]['default'] as int).toDouble();
            }),
          ),
          const SizedBox(height: 16),

          // Result card
          _GoalResultCard(result: result, goalType: goalType),
          const SizedBox(height: 16),

          // Inputs
          SliderCard(
            label: 'Target Amount (Today\'s Value)',
            value: _targetAmount,
            min: 100000,
            max: 50000000,
            divisions: 499,
            format: formatRupee,
            color: AppColors.accent,
            onChanged: (v) => setState(() => _targetAmount = (v / 100000).round() * 100000.0),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Time Horizon',
            value: _timeHorizon,
            min: 1,
            max: 40,
            divisions: 39,
            format: (v) => '${v.toInt()} yrs',
            color: AppColors.warning,
            onChanged: (v) => setState(() => _timeHorizon = v),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Expected Return Rate',
            value: _returnRate,
            min: 4,
            max: 20,
            divisions: 160,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.success,
            onChanged: (v) => setState(() => _returnRate = v),
          ),
          const SizedBox(height: 12),
          SliderCard(
            label: 'Inflation Rate',
            value: _inflationRate,
            min: 2,
            max: 12,
            divisions: 100,
            format: (v) => '${v.toStringAsFixed(1)}%',
            color: AppColors.danger,
            onChanged: (v) => setState(() => _inflationRate = v),
          ),
          const SizedBox(height: 16),

          // Save goal button
          if (!PremiumManager.isPremium && _savedGoalCount >= 1)
            _PremiumBanner(onTap: _showPremiumPrompt)
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveGoal,
                icon: const Icon(Icons.bookmark_add_rounded),
                label: const Text('Save This Goal'),
              ),
            ),
          const SizedBox(height: 16),

          // Year-wise projection — premium gated
          PremiumGate(
            featureName: 'Detailed Goal Projection',
            child: _ProjectionTable(result: result),
          ),
          const BannerAdWidget(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ─── Goal Type Selector ───────────────────────
class _GoalTypeSelector extends StatelessWidget {
  final List<Map<String, dynamic>> goalTypes;
  final int selected;
  final ValueChanged<int> onSelect;
  const _GoalTypeSelector({required this.goalTypes, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: goalTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final g = goalTypes[i];
          final active = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 80,
              decoration: BoxDecoration(
                color: active ? AppColors.accent : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: active ? AppColors.accent : AppColors.borderLight),
                boxShadow: active ? [BoxShadow(color: AppColors.accent.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(g['icon'] as String, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(g['label'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.text), textAlign: TextAlign.center),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ─── Result Card ─────────────────────────────
class _GoalResultCard extends StatelessWidget {
  final _GoalResult result;
  final Map<String, dynamic> goalType;
  const _GoalResultCard({required this.result, required this.goalType});

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
        Text('${goalType['icon']} ${goalType['label']} Goal', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        const Text('Required Monthly SIP', style: TextStyle(color: Colors.white60, fontSize: 12)),
        Text(
          formatRupee(result.monthlySip),
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _Pill('Inflation-Adjusted Target', formatRupee(result.inflatedTarget), AppColors.warning.withOpacity(0.3))),
          const SizedBox(width: 8),
          Expanded(child: _Pill('Lump Sum Today', formatRupee(result.lumpSumToday), Colors.white.withOpacity(0.15))),
        ]),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  const _Pill(this.label, this.value, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ─── Premium Banner ───────────────────────────
class _PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFED8936)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(children: [
          Text('✨', style: TextStyle(fontSize: 20)),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Upgrade for Unlimited Goals', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            Text('Track all your financial goals in one place', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          Icon(Icons.chevron_right_rounded, color: Colors.white),
        ]),
      ),
    );
  }
}

// ─── Projection Table (Premium) ──────────────
class _ProjectionTable extends StatelessWidget {
  final _GoalResult result;
  const _ProjectionTable({required this.result});

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
        const Text('Year-wise Growth Projection', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Expanded(flex: 1, child: Text('Year', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
            Expanded(flex: 2, child: Text('Invested', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            Expanded(flex: 2, child: Text('Corpus', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          ]),
        ),
        ...result.projection.asMap().entries.map((e) {
          final row = e.value;
          final even = e.key % 2 == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            color: even ? AppColors.bg : Colors.white,
            child: Row(children: [
              Expanded(flex: 1, child: Text('${row.year}', style: const TextStyle(fontSize: 12, color: AppColors.textMed))),
              Expanded(flex: 2, child: Text(formatShortIndian(row.invested), style: const TextStyle(fontSize: 12, color: AppColors.text), textAlign: TextAlign.right)),
              Expanded(flex: 2, child: Text(formatShortIndian(row.corpus), style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            ]),
          );
        }),
      ]),
    );
  }
}

// ─── Data models ──────────────────────────────
class _GoalResult {
  final double inflatedTarget;
  final double monthlySip;
  final double lumpSumToday;
  final List<_YearRow> projection;
  _GoalResult({required this.inflatedTarget, required this.monthlySip, required this.lumpSumToday, required this.projection});
}

class _YearRow {
  final int year;
  final double invested;
  final double corpus;
  _YearRow(this.year, this.invested, this.corpus);
}
