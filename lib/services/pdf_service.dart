import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';

/// Brand colors for PDF
const _navy = PdfColor.fromInt(0xFF1A365D);
const _accent = PdfColor.fromInt(0xFF3182CE);
const _success = PdfColor.fromInt(0xFF38A169);
const _danger = PdfColor.fromInt(0xFFE53E3E);
const _textMed = PdfColor.fromInt(0xFF4A5568);
const _textLight = PdfColor.fromInt(0xFF718096);
const _bg = PdfColor.fromInt(0xFFF7FAFC);
const _border = PdfColor.fromInt(0xFFE2E8F0);
const _white = PdfColor.fromInt(0xFFFFFFFF);

class PdfService {
  /// Builds a branded PDF document with header, content, and footer
  static pw.Document buildDocument({
    required String title,
    required String subtitle,
    required List<pw.Widget> content,
  }) {
    final pdf = pw.Document(
      author: 'FinCalc Pro',
      title: title,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(title, subtitle),
        footer: (context) => _buildFooter(context),
        build: (context) => content,
      ),
    );

    return pdf;
  }

  /// Branded header with gradient-style bar
  static pw.Widget _buildHeader(String title, String subtitle) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      margin: const pw.EdgeInsets.only(bottom: 20),
      decoration: pw.BoxDecoration(
        color: _navy,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(
                      color: _white,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(subtitle,
                  style: const pw.TextStyle(color: _textLight, fontSize: 10)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('FinCalc Pro',
                  style: pw.TextStyle(
                      color: _accent,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text(
                'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(color: _textLight, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Footer with branding and page number
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _border, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'This is an estimate for informational purposes only. Consult a tax professional.',
            style: const pw.TextStyle(color: _textLight, fontSize: 7),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(color: _textLight, fontSize: 8),
          ),
        ],
      ),
    );
  }

  // ─── REUSABLE TABLE COMPONENTS ─────────────────────────────

  /// Section title
  static pw.Widget sectionTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8, top: 16),
      child: pw.Text(text,
          style: pw.TextStyle(
              color: _navy, fontSize: 13, fontWeight: pw.FontWeight.bold)),
    );
  }

  /// Key-value row for breakdowns
  static pw.Widget dataRow(String label, String value,
      {bool bold = false, PdfColor? valueColor}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  color: bold ? _navy : _textMed,
                  fontSize: bold ? 11 : 10,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value,
              style: pw.TextStyle(
                  color: valueColor ?? (bold ? _navy : _textMed),
                  fontSize: bold ? 11 : 10,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  /// Alternating row for tables
  static pw.Widget tableRow(String label, String value, int index,
      {bool bold = false, PdfColor? valueColor}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: index % 2 == 0 ? _white : _bg,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  color: bold ? _navy : _textMed,
                  fontSize: bold ? 11 : 10,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value,
              style: pw.TextStyle(
                  color: valueColor ?? (bold ? _navy : _textMed),
                  fontSize: bold ? 11 : 10,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  /// Highlighted result box
  static pw.Widget resultBox(String label, String value,
      {PdfColor color = _success}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        color: _bg,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: color, width: 1.5),
      ),
      child: pw.Column(
        children: [
          pw.Text(label,
              style: const pw.TextStyle(color: _textLight, fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text(value,
              style: pw.TextStyle(
                  color: color, fontSize: 22, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  /// Two-column result boxes side by side
  static pw.Widget resultBoxRow(
      String label1, String value1, PdfColor color1,
      String label2, String value2, PdfColor color2) {
    return pw.Row(
      children: [
        pw.Expanded(child: resultBox(label1, value1, color: color1)),
        pw.SizedBox(width: 12),
        pw.Expanded(child: resultBox(label2, value2, color: color2)),
      ],
    );
  }

  /// Divider line
  static pw.Widget divider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _border, width: 0.5)),
      ),
    );
  }

  /// Card container
  static pw.Widget card({required List<pw.Widget> children}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      margin: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _border),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ─── SAVE & SHARE ──────────────────────────────────────────

  /// Save PDF to temp directory and return File
  static Future<File> savePdf(pw.Document pdf, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Share PDF via system share sheet
  static Future<void> sharePdf(File file, {String? text}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: text ?? 'Generated by FinCalc Pro',
    );
  }

  /// Preview PDF using printing package
  static Future<void> previewPdf(BuildContext context, pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// One-shot: generate, save, and share
  static Future<void> generateAndShare(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String filename,
    required List<pw.Widget> content,
  }) async {
    final pdf = buildDocument(title: title, subtitle: subtitle, content: content);
    final file = await savePdf(pdf, filename);
    await sharePdf(file, text: '$title - Generated by FinCalc Pro');
  }
}
