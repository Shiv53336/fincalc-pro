import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../engine/tax_engine.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/tax_pdf.dart';
import '../services/premium_manager.dart';
import '../widgets/premium_nudge_sheet.dart';
import 'smart_optimizer_screen.dart';

class TaxResultsScreen extends StatefulWidget {
  final TaxResult newResult;
  final TaxResult oldResult;
  const TaxResultsScreen({Key? key, required this.newResult, required this.oldResult}) : super(key: key);

  @override
  State<TaxResultsScreen> createState() => _TaxResultsScreenState();
}

class _TaxResultsScreenState extends State<TaxResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Nudge #1: tax savings found — push Smart Optimizer
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final savings = (widget.newResult.totalTax - widget.oldResult.totalTax).abs();
      if (!PremiumManager.isPremium && savings > 0) {
        await PremiumNudgeSheet.showIfEligible(
          context,
          nudgeId: 'tax_savings_optimizer',
          headline: 'Save Even More on Tax!',
          body: 'You could save ${formatRupee(savings)} by switching regime.\nUnlock Smart Tax Optimizer for a personalised deduction plan.',
          ctaLabel: 'Unlock Smart Optimizer',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool newBetter = widget.newResult.totalTax <= widget.oldResult.totalTax;
    final double savings = (widget.newResult.totalTax - widget.oldResult.totalTax).abs();

    return Scaffold(
      appBar: AppBar(title: const Text('Tax Comparison'), actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf_rounded),
          tooltip: 'Export PDF',
          onPressed: () => _exportPdf(context),
        ),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Recommendation Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF0FFF4), Color(0xFFE6FFFA)]),
              borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.successBg)),
            child: Row(children: [
              const Text('✅', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${newBetter ? "New" : "Old"} Regime saves you more!',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success)),
                const SizedBox(height: 2),
                RichText(text: TextSpan(style: const TextStyle(fontSize: 12, color: AppColors.textMed), children: [
                  const TextSpan(text: 'You save '),
                  TextSpan(text: formatRupee(savings), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success)),
                  const TextSpan(text: ' with this regime'),
                ])),
              ])),
            ]),
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: _RegimeCard(result: widget.newResult, isRecommended: newBetter)),
            const SizedBox(width: 10),
            Expanded(child: _RegimeCard(result: widget.oldResult, isRecommended: !newBetter)),
          ]),
          const SizedBox(height: 16),

          // Smart Optimizer CTA
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => SmartTaxOptimizerScreen(salary: widget.newResult.grossIncome))),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFFFF0), Color(0xFFFEFCBF)]),
                borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF6E05E))),
              child: Row(children: [
                const Text('✨', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Want to save even more?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
                  const Text('Get personalized tax-saving strategies', style: TextStyle(fontSize: 11, color: AppColors.textMed)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Open', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(children: [
            Expanded(child: ActionButton(
              icon: Icons.picture_as_pdf_rounded,
              label: 'Save PDF',
              onTap: () => _exportPdf(context),
            )),
            const SizedBox(width: 10),
            Expanded(child: ActionButton(
              icon: Icons.share_rounded,
              label: 'Share',
              onTap: () => _exportPdf(context),
            )),
          ]),
          const SizedBox(height: 16),
          const BannerAdWidget(),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _exportPdf(BuildContext context) {
    TaxPdfGenerator.generateAndShare(
      context,
      newResult: widget.newResult,
      oldResult: widget.oldResult,
    );
  }
}

class _RegimeCard extends StatelessWidget {
  final TaxResult result;
  final bool isRecommended;
  const _RegimeCard({required this.result, required this.isRecommended});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isRecommended ? AppColors.success : AppColors.border, width: isRecommended ? 2 : 1)),
      child: Column(children: [
        if (isRecommended) Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(10)),
          child: const Text('RECOMMENDED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
        ),
        Text('${result.regime.toUpperCase()} REGIME', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMed)),
        const SizedBox(height: 8),
        const Text('Tax Payable', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
        Text(formatRupee(result.totalTax),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: result.totalTax == 0 ? AppColors.success : AppColors.danger)),
        if (result.totalTax == 0) const Text('Zero Tax!', style: TextStyle(fontSize: 10, color: AppColors.success)),
        const SizedBox(height: 10), const Divider(height: 1), const SizedBox(height: 8),
        DetailRow(label: 'Gross Income', value: formatRupee(result.grossIncome)),
        DetailRow(label: 'Std Deduction', value: '- ${formatRupee(result.standardDeduction)}'),
        if (result.totalDeductions > result.standardDeduction)
          DetailRow(label: 'Other Ded.', value: '- ${formatRupee(result.totalDeductions - result.standardDeduction)}'),
        DetailRow(label: 'Taxable', value: formatRupee(result.taxableIncome)),
        DetailRow(label: 'Tax (slabs)', value: formatRupee(result.taxBeforeRebate)),
        if (result.rebate87A > 0) DetailRow(label: 'Rebate 87A', value: '- ${formatRupee(result.rebate87A)}'),
        if (result.cess > 0) DetailRow(label: 'Cess (4%)', value: formatRupee(result.cess)),
        if (result.surcharge > 0) DetailRow(label: 'Surcharge', value: formatRupee(result.surcharge)),
      ]),
    );
  }
}
