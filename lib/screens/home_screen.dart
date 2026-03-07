import 'package:flutter/material.dart';
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
                      Text('Good ${_getGreeting()}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      const SizedBox(height: 2),
                      const Text('FinCalc Pro', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    ]),
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

        // Business & GST
        _sectionHeader('Business & GST'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _ListTile(icon: Icons.receipt_rounded, label: 'GST Calculator', desc: 'CGST / SGST / IGST Breakdown', color: AppColors.danger,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GstCalculatorScreen()))),
          ])),
        ),
      ],
    );
  }

  static SliverPadding _sectionHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
      ),
    );
  }

  static String _getGreeting() {
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
  const _ListTile({required this.icon, required this.label, required this.desc, required this.color, required this.onTap});

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
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
        ]),
      ),
    );
  }
}
