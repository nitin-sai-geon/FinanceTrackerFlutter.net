import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> printReport({
  required String title,
  required double totalIncome,
  required double totalExpenses,
  required List<MapEntry<String, double>> entries,
  required String generatedOn,
}) async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Finance Tracker — Report',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated $generatedOn',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
          pw.Divider(height: 24),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _summaryBox('Income', totalIncome, PdfColors.green700),
              _summaryBox('Expenses', totalExpenses, PdfColors.red700),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Expenses by Category',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('Category', bold: true),
                  _cell('Amount', bold: true),
                  _cell('% of Total', bold: true),
                ],
              ),
              ...entries.map((e) {
                final pct = totalExpenses > 0
                    ? (e.value / totalExpenses * 100).toStringAsFixed(1)
                    : '0.0';
                return pw.TableRow(children: [
                  _cell(e.key),
                  _cell('₹${e.value.toStringAsFixed(2)}'),
                  _cell('$pct%'),
                ]);
              }),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _cell('Total', bold: true),
                  _cell('₹${totalExpenses.toStringAsFixed(2)}', bold: true),
                  _cell('100%', bold: true),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (_) => doc.save());
}

pw.Widget _summaryBox(String label, double amount, PdfColor color) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: const pw.TextStyle(
                  fontSize: 11, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(
            '₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: color),
          ),
        ],
      ),
    );

pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
