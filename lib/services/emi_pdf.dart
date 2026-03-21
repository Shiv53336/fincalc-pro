import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import 'pdf_service.dart';

class EmiPdfGenerator {
  static const _success = PdfColor.fromInt(0xFF38A169);
  static const _danger = PdfColor.fromInt(0xFFE53E3E);
  static const _navy = PdfColor.fromInt(0xFF1A365D);

  static Future<void> generateAndShare(
    BuildContext context, {
    required double loanAmount,
    required double rate,
    required double tenure,
    required String loanType,
  }) async {
    double mr = rate / 100 / 12;
    int months = (tenure * 12).round();
    double factor = pow(1 + mr, months).toDouble();
    double emi = mr > 0 ? loanAmount * mr * factor / (factor - 1) : loanAmount / months;
    double totalPayment = emi * months;
    double totalInterest = totalPayment - loanAmount;

    await PdfService.generateAndShare(
      context,
      title: '$loanType Loan EMI Report',
      subtitle: '${formatRupee(loanAmount)} @ ${rate.toStringAsFixed(1)}% for ${tenure.round()} years',
      filename: 'emi_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      content: [
        // Summary
        PdfService.resultBox('Monthly EMI', formatRupee(emi), color: _navy),
        pw.SizedBox(height: 4),
        PdfService.resultBoxRow(
          'Total Payment', formatRupee(totalPayment), _navy,
          'Total Interest', formatRupee(totalInterest), _danger,
        ),
        pw.SizedBox(height: 16),

        // Loan Details
        PdfService.sectionTitle('Loan Details'),
        PdfService.card(children: [
          PdfService.tableRow('Loan Type', loanType, 0),
          PdfService.tableRow('Loan Amount', formatRupee(loanAmount), 1),
          PdfService.tableRow('Interest Rate', '${rate.toStringAsFixed(1)}% p.a.', 2),
          PdfService.tableRow('Tenure', '${tenure.round()} years (${months} months)', 3),
          PdfService.divider(),
          PdfService.tableRow('Monthly EMI', formatRupee(emi), 4, bold: true),
          PdfService.tableRow('Principal', formatRupee(loanAmount), 5, valueColor: _success),
          PdfService.tableRow('Interest', formatRupee(totalInterest), 6, valueColor: _danger),
          PdfService.tableRow('Total Repayment', formatRupee(totalPayment), 7, bold: true),
        ]),

        // Amortization Schedule (yearly)
        PdfService.sectionTitle('Yearly Amortization Schedule'),
        PdfService.card(children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEDF2F7)),
            child: pw.Row(children: [
              _headerCell('Year', 40),
              _headerCell('Principal', 90),
              _headerCell('Interest', 90),
              _headerCell('Balance', 90),
            ]),
          ),
          ..._buildAmortization(loanAmount, mr, emi, tenure.round()),
        ]),
      ],
    );
  }

  static pw.Widget _headerCell(String text, double width) {
    return pw.SizedBox(
      width: width,
      child: pw.Text(text, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _navy)),
    );
  }

  static List<pw.Widget> _buildAmortization(double principal, double mr, double emi, int years) {
    List<pw.Widget> rows = [];
    double balance = principal;

    for (int y = 1; y <= years; y++) {
      double yearPrincipal = 0;
      double yearInterest = 0;

      for (int m = 0; m < 12 && balance > 0; m++) {
        double interest = balance * mr;
        double prinPart = min(emi - interest, balance);
        yearInterest += interest;
        yearPrincipal += prinPart;
        balance -= prinPart;
      }
      if (balance < 0) balance = 0;

      rows.add(pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        decoration: pw.BoxDecoration(
          color: y % 2 == 0 ? const PdfColor.fromInt(0xFFF7FAFC) : const PdfColor.fromInt(0xFFFFFFFF)),
        child: pw.Row(children: [
          pw.SizedBox(width: 40, child: pw.Text('$y', style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF4A5568)))),
          pw.SizedBox(width: 90, child: pw.Text(formatRupee(yearPrincipal), style: pw.TextStyle(fontSize: 9, color: _success))),
          pw.SizedBox(width: 90, child: pw.Text(formatRupee(yearInterest), style: pw.TextStyle(fontSize: 9, color: _danger))),
          pw.SizedBox(width: 90, child: pw.Text(formatRupee(balance), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _navy))),
        ]),
      ));
    }
    return rows;
  }
}
