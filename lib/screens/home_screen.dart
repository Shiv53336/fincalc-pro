import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import 'income_tax_screen.dart';
import 'sip_calculator.dart';
import 'emi_calculator.dart';
import 'hra_calculator.dart';
import 'fd_calculator.dart';
import 'lump_sum_calculator.dart';
import 'ppf_calculator.dart';
import 'nps_calculator.dart';
import 'epf_calculator.dart';
import 'gratuity_calculator.dart';
import 'gst_calculator.dart';
import 'salary_calculator.dart';
import 'smart_optimizer_screen.dart';
import 'prepayment_calculator.dart';
import 'goal_planner.dart';
import 'health_score.dart';
import 'compare_screen.dart';
import 'ssy_calculator.dart';
import 'inflation_calculator.dart';
import 'elss_calculator.dart';
import 'swp_calculator.dart';
import 'rd_calculator.dart';
import 'fd_vs_sip.dart';
import 'cost_of_delay.dart';
import 'affordability_calculator.dart';
import 'premium_screen.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/premium_manager.dart';
import '../services/nudge_service.dart';
import '../widgets/premium_nudge_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    // Nudge #5: 14+ days of app usage
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!PremiumManager.isPremium) {
        final days = await NudgeService.daysSinceInstall();
        if (days >= 14) {
          await PremiumNudgeSheet.showIfEligible(
            context,
            nudgeId: 'long_time_user',
            headline: 'You\'re a Power User!',
            body: 'You\'ve been using FinCalc Pro for $days days 🎉\nReward yourself with lifetime Premium — just Rs.99.',
            ctaLabel: 'Upgrade to Premium',
          );
        }
      }
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    if (mounted && name.isNotEmpty) setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Gradient Header
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryLight]),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        _userName.isNotEmpty ? 'Good ${_getGreeting()}, $_userName!' : 'Good ${_getGreeting()}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Text('FinCalc Pro', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                        if (PremiumManager.isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFED8936)]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ]),
                    ]),
                    if (!PremiumManager.isPremium)
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFED8936)]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('✨ Rs.99', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                        ),
                      )
                    else
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                      ),
                  ]),
                  const SizedBox(height: 16),
                  // Smart Tax Optimizer CTA
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartTaxOptimizerScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF6E05E), Color(0xFFED8936)]), borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Text('✨', style: TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Smart Tax Optimizer', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('Find out how to save more on taxes', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                        ])),
                        Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.7)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),

        // Quick Calculate
        _sectionHeader('Quick Calculate'),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid.count(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.15,
            children: [
              _QuickCard(icon: Icons.receipt_long_rounded, label: 'Income Tax', sub: 'Old vs New Regime', color: AppColors.accent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomeTaxInputScreen()))),
              _QuickCard(icon: Icons.show_chart_rounded, label: 'SIP Calculator', sub: 'Mutual Fund Returns', color: AppColors.success,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SipCalculatorScreen()))),
              _QuickCard(icon: Icons.home_work_rounded, label: 'EMI Calculator', sub: 'Home / Car / Personal', color: AppColors.warning,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmiCalculatorScreen()))),
              _QuickCard(icon: Icons.apartment_rounded, label: 'HRA Exemption', sub: 'Tax Benefit on Rent', color: AppColors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HraCalculatorScreen()))),
            ],
          ),
        ),

        // Investment Planning
        _sectionHeader('Investment Planning'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _ListTile(icon: Icons.savings_rounded, label: 'FD Calculator', desc: 'Fixed Deposit Returns', color: AppColors.accent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FdCalculatorScreen()))),
            _ListTile(icon: Icons.trending_up_rounded, label: 'Lump Sum', desc: 'One-time Investment', color: AppColors.success,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LumpSumCalculatorScreen()))),
            _ListTile(icon: Icons.account_balance_rounded, label: 'PPF Calculator', desc: '15-Year Tax-Free Returns', color: AppColors.purple,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PpfCalculatorScreen()))),
            _ListTile(icon: Icons.elderly_rounded, label: 'NPS Calculator', desc: 'Retirement Pension Planning', color: AppColors.warning,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NpsCalculatorScreen()))),
          ])),
        ),

        // Employment & Salary
        _sectionHeader('Employment & Salary'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _ListTile(icon: Icons.work_rounded, label: 'Salary Calculator', desc: 'CTC to Take-Home Breakdown', color: AppColors.accent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalaryCalculatorScreen()))),
            _ListTile(icon: Icons.account_balance_wallet_rounded, label: 'EPF Calculator', desc: 'Provident Fund Growth', color: AppColors.success,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EpfCalculatorScreen()))),
            _ListTile(icon: Icons.card_giftcard_rounded, label: 'Gratuity Calculator', desc: 'Service Benefit Estimate', color: AppColors.gold,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GratuityCalculatorScreen()))),
          ])),
        ),

        // Tax-Saving & Govt Schemes
        _sectionHeader('Tax-Saving & Govt Schemes'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _ListTile(icon: Icons.child_care_rounded, label: 'SSY Calculator', desc: 'Sukanya Samriddhi — EEE Tax-Free', color: AppColors.purple,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SsyCalculatorScreen()))),
            _ListTile(icon: Icons.lock_clock_rounded, label: 'ELSS Calculator', desc: '3-yr Lock-in · 80C Tax Saving', color: AppColors.success,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ElssCalculatorScreen()))),
          ])),
        ),

        // Smart Investment Tools
        _sectionHeader('Smart Investment Tools'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _ListTile(icon: Icons.compare_rounded, label: 'FD vs SIP', desc: 'See which gives better returns', color: AppColors.accent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FdVsSipScreen()))),
            _ListTile(icon: Icons.timer_off_rounded, label: 'Cost of Delay', desc: 'Opportunity cost of delaying SIP', color: AppColors.danger,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CostOfDelayScreen()))),
            _ListTile(icon: Icons.trending_down_rounded, label: 'SWP Calculator', desc: 'Systematic Withdrawal Planning', color: AppColors.warning,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SwpCalculatorScreen()))),
            _ListTile(icon: Icons.currency_rupee_rounded, label: 'RD Calculator', desc: 'Recurring Deposit Returns', color: AppColors.gold,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RdCalculatorScreen()))),
          ])),
        ),

        // Financial Awareness
        _sectionHeader('Financial Awareness'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _ListTile(icon: Icons.price_change_rounded, label: 'Inflation Calculator', desc: 'Future cost & purchasing power', color: AppColors.danger,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InflationCalculatorScreen()))),
            _ListTile(icon: Icons.account_balance_wallet_rounded, label: 'EMI Affordability', desc: 'How much loan can you afford?', color: AppColors.accent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AffordabilityCalculatorScreen()))),
          ])),
        ),

        // Business & GST
        _sectionHeader('Business & GST'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _ListTile(icon: Icons.receipt_rounded, label: 'GST Calculator', desc: 'CGST / SGST / IGST Breakdown', color: AppColors.danger,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GstCalculatorScreen()))),
          ])),
        ),

        // Bottom ad banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: const BannerAdWidget(),
          ),
        ),

        // Planning Tools (Premium)
        _sectionHeader('✨ Planning Tools'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _ListTile(icon: Icons.currency_rupee_rounded, label: 'Loan Prepayment Simulator', desc: 'See how prepaying saves interest & tenure', color: AppColors.gold,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrepaymentCalculatorScreen())),
                isPremium: true),
            _ListTile(icon: Icons.flag_rounded, label: 'Goal-Based Planner', desc: 'Monthly SIP needed for life goals', color: AppColors.accent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalPlannerScreen())),
                isPremium: true),
            _ListTile(icon: Icons.favorite_rounded, label: 'Financial Health Score', desc: 'Your financial fitness score 0–100', color: AppColors.success,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialHealthScoreScreen())),
                isPremium: true),
            _ListTile(icon: Icons.compare_arrows_rounded, label: 'Save & Compare', desc: 'Compare two saved calculations', color: AppColors.purple,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompareScenariosScreen())),
                isPremium: true),
          ])),
        ),
      ],
    );
  }

  SliverPadding _sectionHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard({required this.icon, required this.label, required this.sub, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ]),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;
  final bool isPremium;
  const _ListTile({required this.icon, required this.label, required this.desc, required this.color, required this.onTap, this.isPremium = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
        child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
              if (isPremium) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFED8936)]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ],
            ]),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
        ]),
      ),
    );
  }
}
