import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/premium_manager.dart';
import '../services/purchase_service.dart';
import '../services/analytics_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _loading = false;

  Future<void> _buy() async {
    setState(() => _loading = true);
    await AnalyticsService.logPremiumPromptShown('premium_screen');
    await PurchaseService().buyPremium(context);
    setState(() => _loading = false);
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    await PurchaseService().restorePurchases(context);
    setState(() => _loading = false);
    if (PremiumManager.isPremium && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Premium restored successfully!'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPremium = PremiumManager.isPremium;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('FinCalc Pro Premium'),
        actions: [
          TextButton(
            onPressed: _restore,
            child: const Text('Restore', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Hero header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
            ),
            child: Column(children: [
              const Text('✨', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              if (isPremium) ...[
                const Text('You\'re Premium!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Enjoy all features with no restrictions.', style: TextStyle(color: Colors.white70, fontSize: 15)),
              ] else ...[
                const Text('Unlock Everything', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('One-time payment · No subscription · Forever yours', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFED8936)]),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 6))],
                  ),
                  child: const Text('Rs. 99', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                ),
              ],
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              // Feature list
              _FeatureCard(
                icon: Icons.currency_rupee_rounded,
                color: AppColors.gold,
                title: 'Loan Prepayment Simulator',
                desc: 'Full amortization breakdown, interest saved, tenure reduced',
              ),
              _FeatureCard(
                icon: Icons.flag_rounded,
                color: AppColors.accent,
                title: 'Goal-Based Planner (Unlimited)',
                desc: 'Track every financial goal with detailed projections',
              ),
              _FeatureCard(
                icon: Icons.favorite_rounded,
                color: AppColors.success,
                title: 'Financial Health Score',
                desc: 'Full 6-parameter breakdown with personalised tips',
              ),
              _FeatureCard(
                icon: Icons.compare_arrows_rounded,
                color: AppColors.purple,
                title: 'Save & Compare (Unlimited)',
                desc: 'Save unlimited scenarios and compare side-by-side',
              ),
              _FeatureCard(
                icon: Icons.picture_as_pdf_rounded,
                color: AppColors.accent,
                title: 'Unlimited PDF Exports',
                desc: 'No monthly cap — export and share as much as you need',
              ),
              _FeatureCard(
                icon: Icons.block_rounded,
                color: AppColors.danger,
                title: 'Ad-Free Experience',
                desc: 'Zero ads across all 21 calculators, forever',
              ),
              const SizedBox(height: 8),

              // Guarantee
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.verified_rounded, color: AppColors.success, size: 22),
                  SizedBox(width: 12),
                  Expanded(child: Text('One-time purchase. No recurring charges. Works offline.', style: TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w500))),
                ]),
              ),
              const SizedBox(height: 24),

              if (!isPremium) ...[
                // Buy button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _buy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Buy Premium — Rs.99', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading ? null : _restore,
                  child: const Text('Restore Previous Purchase', style: TextStyle(color: AppColors.textMed, fontSize: 13)),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFED8936)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text('Premium Active', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ],

              const SizedBox(height: 16),
              const Text(
                'Price in INR. One-time purchase. Applies to this Google account on all devices. By purchasing you agree to Google Play Terms of Service.',
                style: TextStyle(fontSize: 10, color: AppColors.textLight, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _FeatureCard({required this.icon, required this.color, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.3)),
        ])),
        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
      ]),
    );
  }
}
