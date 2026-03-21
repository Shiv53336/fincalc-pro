import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/formatters.dart';
import '../screens/prepayment_calculator.dart';
import 'pdf_service.dart';

class PrepaymentPdfGenerator {
  static const _success = PdfColor.fromInt(0xFF38A169);
  static const _danger = PdfColor.fromInt(0xFFE53E3E);
  static const _navy = PdfColor.fromInt(0xFF1A365D);

  static Future<void> generateAndShare(
    BuildContext context, {
    required double loanAmount,
    required double interestRate,
    required int tenureYears,
    required double prepaymentAmount,
    required String prepaymentType,
    required PrepaymentResult result,
  }) async {
    final typeLabel = prepaymentType == 'one_time'
        ? 'One-Time'
        : prepaymentType == 'yearly'
            ? 'Yearly'
            : 'Monthly';

    await PdfService.generateAndShare(
      context,
      title: 'Loan Prepayment Simulator',
      subtitle: '${formatRupee(loanAmount)} @ ${interestRate.toStringAsFixed(1)}% for $tenureYears years',
      filename: 'prepayment_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      content: [
        PdfService.resultBox('Interest Saved', formatRupee(result.interestSaved), color: _success),
        pw.SizedBox(height: 4),
        PdfService.resultBoxRow(
          'Without Prepayment', formatRupee(result.totalInterestWithout), _danger,
          'With Prepayment', formatRupee(result.totalInterestWith), _success,
        ),
        pw.SizedBox(height: 16),
        PdfService.sectionTitle('Loan Details'),
        PdfService.card(children: [
          PdfService.tableRow('Loan Amount', formatRupee(loanAmount), 0),
          PdfService.tableRow('Interest Rate', '${interestRate.toStringAsFixed(1)}% p.a.', 1),
          PdfService.tableRow('Loan Tenure', '$tenureYears years', 2),
          PdfService.tableRow('Monthly EMI', formatRupee(result.emi), 3, bold: true),
        ]),
        PdfService.sectionTitle('Prepayment Details'),
        PdfService.card(children: [
          PdfService.tableRow('Type', typeLabel, 0),
          PdfService.tableRow('Amount', formatRupee(prepaymentAmount), 1),
          PdfService.tableRow('Original Tenure', '${result.originalMonths} months', 2),
          PdfService.tableRow('New Tenure', '${result.newMonths} months', 3, bold: true),
          PdfService.tableRow(
            'Tenure Reduced',
            '${result.yearsSaved > 0 ? "${result.yearsSaved} yr " : ""}${result.monthsSaved > 0 ? "${result.monthsSaved} mo" : ""}',
            4,
            bold: true,
            valueColor: _success,
          ),
        ]),
        if (result.table.isNotEmpty) ...[
          PdfService.sectionTitle('Amortization Summary'),
          PdfService.card(children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: const pw.BoxDecoration(color: _navy),
              child: pw.Row(children: [
                _cell('Month', 50, isHeader: true),
                _cell('Payment (Rs.)', 110, isHeader: true),
                _cell('Interest (Rs.)', 110, isHeader: true),
                _cell('Balance (Rs.)', 110, isHeader: true),
              ]),
            ),
            ...result.table.asMap().entries.map((e) {
              final row = e.value;
              final even = e.key % 2 == 0;
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                decoration: pw.BoxDecoration(
                  color: even ? const PdfColor.fromInt(0xFFF7FAFC) : PdfColors.white,
                ),
                child: pw.Row(children: [
                  _cell('${row.month}', 50),
                  _cell(formatIndian(row.payment), 110),
                  _cell(formatIndian(row.interest), 110, color: _danger),
                  _cell(formatIndian(row.balance), 110, color: _navy),
                ]),
              );
            }),
          ]),
        ],
      ],
    );
  }

  static pw.Widget _cell(String text, double width, {bool isHeader = false, PdfColor? color}) {
    return pw.SizedBox(
      width: width,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : (color ?? const PdfColor.fromInt(0xFF4A5568)),
        ),
      ),
    );
  }
}
