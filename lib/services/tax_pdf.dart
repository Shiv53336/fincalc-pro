import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import '../engine/tax_engine.dart';
import '../utils/formatters.dart';
import 'pdf_service.dart';

class TaxPdfGenerator {
  static const _success = PdfColor.fromInt(0xFF38A169);
  static const _danger = PdfColor.fromInt(0xFFE53E3E);
  static const _navy = PdfColor.fromInt(0xFF1A365D);
  static const _accent = PdfColor.fromInt(0xFF3182CE);
  static const _textMed = PdfColor.fromInt(0xFF4A5568);

  static Future<void> generateAndShare(
    BuildContext context, {
    required TaxResult newResult,
    required TaxResult oldResult,
  }) async {
    final bool newBetter = newResult.totalTax <= oldResult.totalTax;
    final double savings = (newResult.totalTax - oldResult.totalTax).abs();

    await PdfService.generateAndShare(
      context,
      title: 'Income Tax Comparison',
      subtitle: 'FY 2025-26 | Old vs New Regime',
      filename: 'tax_comparison_${DateTime.now().millisecondsSinceEpoch}.pdf',
      content: [
        // Recommendation banner
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFF0FFF4),
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: _success),
          ),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(
              '${newBetter ? "New" : "Old"} Regime saves you ${formatRupee(savings)}',
              style: pw.TextStyle(color: _success, fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Based on gross income of ${formatRupee(newResult.grossIncome)} for FY 2025-26',
              style: const pw.TextStyle(color: _textMed, fontSize: 9),
            ),
          ]),
        ),
        pw.SizedBox(height: 16),

        // Side by side results
        PdfService.resultBoxRow(
          'New Regime Tax', formatRupee(newResult.totalTax),
          newBetter ? _success : _danger,
          'Old Regime Tax', formatRupee(oldResult.totalTax),
          !newBetter ? _success : _danger,
        ),
        pw.SizedBox(height: 8),

        // New Regime Breakdown
        PdfService.sectionTitle('New Regime Breakdown'),
        PdfService.card(children: [_breakdown(newResult)]),

        // Old Regime Breakdown
        PdfService.sectionTitle('Old Regime Breakdown'),
        PdfService.card(children: [_breakdown(oldResult)]),

        // Tax Slabs Reference
        PdfService.sectionTitle('FY 2025-26 Tax Slabs'),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: _slabCard('New Regime', [
            ['Up to 4L', '0%'], ['4L - 8L', '5%'], ['8L - 12L', '10%'],
            ['12L - 16L', '15%'], ['16L - 20L', '20%'], ['20L - 24L', '25%'], ['Above 24L', '30%'],
          ])),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _slabCard('Old Regime', [
            ['Up to 2.5L', '0%'], ['2.5L - 5L', '5%'], ['5L - 10L', '20%'], ['Above 10L', '30%'],
          ])),
        ]),
        pw.SizedBox(height: 16),

        // Key Notes
        PdfService.card(children: [
          pw.Text('Key Notes', style: pw.TextStyle(color: _navy, fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _note('New Regime: Std deduction Rs.75,000. Section 87A rebate up to Rs.60,000 (taxable income up to Rs.12L).'),
          _note('Old Regime: Std deduction Rs.50,000. Section 87A rebate up to Rs.12,500 (taxable income up to Rs.5L).'),
          _note('Health & Education Cess: 4% on tax + surcharge in both regimes.'),
          _note('Surcharge applicable on income above Rs.50L (10-37% based on income level).'),
        ]),
      ],
    );
  }

  static pw.Widget _breakdown(TaxResult r) {
    int i = 0;
    List<pw.Widget> rows = [
      PdfService.tableRow('Gross Income', formatRupee(r.grossIncome), i++),
      PdfService.tableRow('Standard Deduction', '- ${formatRupee(r.standardDeduction)}', i++),
    ];
    if (r.totalDeductions > r.standardDeduction) {
      rows.add(PdfService.tableRow('Other Deductions (80C/D/CCD/24b)',
          '- ${formatRupee(r.totalDeductions - r.standardDeduction)}', i++));
    }
    rows.addAll([
      PdfService.divider(),
      PdfService.tableRow('Taxable Income', formatRupee(r.taxableIncome), i++, bold: true),
      PdfService.tableRow('Tax on Income (slabs)', formatRupee(r.taxBeforeRebate), i++),
    ]);
    if (r.rebate87A > 0) {
      rows.add(PdfService.tableRow('Section 87A Rebate', '- ${formatRupee(r.rebate87A)}', i++, valueColor: _success));
    }
    if (r.surcharge > 0) {
      rows.add(PdfService.tableRow('Surcharge', formatRupee(r.surcharge), i++));
    }
    if (r.cess > 0) {
      rows.add(PdfService.tableRow('Cess (4%)', formatRupee(r.cess), i++));
    }
    rows.addAll([
      PdfService.divider(),
      PdfService.tableRow('Total Tax Payable', formatRupee(r.totalTax), i++,
          bold: true, valueColor: r.totalTax == 0 ? _success : _danger),
    ]);
    return pw.Column(children: rows);
  }

  static pw.Widget _slabCard(String title, List<List<String>> slabs) {
    return PdfService.card(children: [
      pw.Text(title, style: pw.TextStyle(color: _accent, fontSize: 10, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 6),
      ...slabs.asMap().entries.map((e) => PdfService.tableRow(e.value[0], e.value[1], e.key)),
    ]);
  }

  static pw.Widget _note(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('  -  ', style: const pw.TextStyle(color: _textMed, fontSize: 8)),
        pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(color: _textMed, fontSize: 8))),
      ]),
    );
  }
}
