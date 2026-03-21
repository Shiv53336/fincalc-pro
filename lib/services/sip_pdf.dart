import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import 'pdf_service.dart';

class SipPdfGenerator {
  static const _success = PdfColor.fromInt(0xFF38A169);
  static const _navy = PdfColor.fromInt(0xFF1A365D);

  static Future<void> generateAndShare(
    BuildContext context, {
    required double monthly,
    required double rate,
    required double years,
  }) async {
    double r = rate / 100 / 12;
    int n = (years * 12).round();
    double totalInvested = monthly * n;
    double futureValue = r > 0 ? monthly * (pow(1 + r, n) - 1) / r * (1 + r) : totalInvested;
    double returns = futureValue - totalInvested;

    await PdfService.generateAndShare(
      context,
      title: 'SIP Investment Report',
      subtitle: '${formatRupee(monthly)}/month @ ${rate.toStringAsFixed(1)}% for ${years.round()} years',
      filename: 'sip_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      content: [
        // Summary
        PdfService.resultBoxRow(
          'Total Value', formatRupee(futureValue), _navy,
          'Total Returns', '+${formatRupee(returns)}', _success,
        ),
        pw.SizedBox(height: 8),
        PdfService.resultBoxRow(
          'Total Invested', formatRupee(totalInvested), _navy,
          'Return %', '${(returns / totalInvested * 100).toStringAsFixed(1)}%', _success,
        ),
        pw.SizedBox(height: 16),

        // Parameters
        PdfService.sectionTitle('Investment Parameters'),
        PdfService.card(children: [
          PdfService.tableRow('Monthly SIP Amount', formatRupee(monthly), 0),
          PdfService.tableRow('Expected Return Rate', '${rate.toStringAsFixed(1)}% p.a.', 1),
          PdfService.tableRow('Investment Period', '${years.round()} years (${n} months)', 2),
        ]),

        // Year-wise table
        PdfService.sectionTitle('Year-wise Growth'),
        PdfService.card(children: [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEDF2F7)),
            child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Year', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _navy)),
              pw.Text('Invested', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _navy)),
              pw.Text('Returns', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _navy)),
              pw.Text('Total Value', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _navy)),
            ]),
          ),
          ...List.generate(years.round(), (i) {
            int y = i + 1;
            int nm = y * 12;
            double inv = monthly * nm;
            double fv = r > 0 ? monthly * (pow(1 + r, nm) - 1) / r * (1 + r) : inv;
            double ret = fv - inv;
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              decoration: pw.BoxDecoration(
                color: i % 2 == 0 ? const PdfColor.fromInt(0xFFFFFFFF) : const PdfColor.fromInt(0xFFF7FAFC)),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.SizedBox(width: 40, child: pw.Text('$y', style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF4A5568)))),
                pw.SizedBox(width: 80, child: pw.Text(formatRupee(inv), style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF4A5568)))),
                pw.SizedBox(width: 80, child: pw.Text(formatRupee(ret), style: pw.TextStyle(fontSize: 9, color: _success))),
                pw.SizedBox(width: 80, child: pw.Text(formatRupee(fv), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _navy))),
              ]),
            );
          }),
        ]),
      ],
    );
  }
}
