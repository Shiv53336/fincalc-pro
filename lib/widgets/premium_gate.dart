import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/premium_manager.dart';
import '../services/purchase_service.dart';

class PremiumGate extends StatefulWidget {
  final Widget child;
  final String featureName;
  final bool showPreview;

  const PremiumGate({
    Key? key,
    required this.child,
    required this.featureName,
    this.showPreview = true,
  }) : super(key: key);

  @override
  State<PremiumGate> createState() => _PremiumGateState();
}

class _PremiumGateState extends State<PremiumGate> {
  bool _loading = false;

  Future<void> _buy(BuildContext ctx) async {
    Navigator.pop(ctx);
    setState(() => _loading = true);
    await PurchaseService().buyPremium(ctx);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (PremiumManager.isPremium) return widget.child;

    return Stack(
      children: [
        if (widget.showPreview)
          Opacity(opacity: 0.25, child: IgnorePointer(child: widget.child)),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.85),
                  Colors.white,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, Color(0xFFED8936)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lock_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.featureName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Unlock Premium for Rs.99 — one-time',
                  style: TextStyle(fontSize: 13, color: AppColors.textMed),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loading ? null : () => _showPremiumDialog(context),
                  icon: const Text('✨', style: TextStyle(fontSize: 16)),
                  label: const Text('Unlock Premium — Rs.99'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(color: AppColors.textLight, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Text('✨ ', style: TextStyle(fontSize: 22)),
          Text('Go Premium', style: TextStyle(fontWeight: FontWeight.w700)),
        ]),
        content: const Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Unlock all premium features for just Rs.99 — one-time payment, no subscription.', style: TextStyle(fontSize: 14, height: 1.5)),
          SizedBox(height: 12),
          _BulletItem('Loan Prepayment Simulator'),
          _BulletItem('Goal-Based Financial Planner (unlimited goals)'),
          _BulletItem('Financial Health Score (detailed breakdown)'),
          _BulletItem('Save & Compare unlimited scenarios'),
          _BulletItem('Unlimited PDF exports'),
          _BulletItem('No ads'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Later')),
          ElevatedButton(
            onPressed: _loading ? null : () => _buy(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Buy — Rs.99'),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }
}
