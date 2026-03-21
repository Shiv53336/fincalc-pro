import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/purchase_service.dart';
import '../services/nudge_service.dart';
import '../services/analytics_service.dart';

class PremiumNudgeSheet extends StatelessWidget {
  final String nudgeId;
  final String headline;
  final String body;
  final String ctaLabel;

  const PremiumNudgeSheet({
    Key? key,
    required this.nudgeId,
    required this.headline,
    required this.body,
    this.ctaLabel = 'Unlock Premium — Rs.99',
  }) : super(key: key);

  /// Show the nudge bottom sheet if cooldown allows.
  static Future<void> showIfEligible(
    BuildContext context, {
    required String nudgeId,
    required String headline,
    required String body,
    String ctaLabel = 'Unlock Premium — Rs.99',
  }) async {
    final ok = await NudgeService.shouldShowNudge(nudgeId);
    if (!ok) return;
    if (!context.mounted) return;
    await NudgeService.markNudgeShown(nudgeId);
    await AnalyticsService.logPremiumPromptShown(nudgeId);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PremiumNudgeSheet(
        nudgeId: nudgeId,
        headline: headline,
        body: body,
        ctaLabel: ctaLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),

        // Icon
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFED8936)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: Text('✨', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 16),

        Text(headline, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(body, style: const TextStyle(fontSize: 14, color: AppColors.textMed, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 20),

        // Feature pills
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: const [
          _FeaturePill('Loan Prepayment'),
          _FeaturePill('Unlimited Goals'),
          _FeaturePill('Health Score'),
          _FeaturePill('Save & Compare'),
          _FeaturePill('Unlimited PDFs'),
          _FeaturePill('No Ads'),
        ]),
        const SizedBox(height: 24),

        // CTA
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PurchaseService().buyPremium(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(ctaLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Maybe Later', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
        ),
      ]),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String label;
  const _FeaturePill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text)),
    );
  }
}
