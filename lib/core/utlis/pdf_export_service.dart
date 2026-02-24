import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfExportService {
  static Future<void> exportIncomeStatement(IncomeStatement data) async {
    final pdf = pw.Document();
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: 'P');
    final dateFormat = DateFormat('MMMM dd, yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              pw.Center(
                child: pw.Text(
                  data.businessName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  "INCOME STATEMENT",
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  "For the Period: ${dateFormat.format(data.periodStart)} - ${dateFormat.format(data.periodEnd)}",
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // --- INCOME ---
              pw.Text(
                "INCOME",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "Sales Revenue",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              ...data.revenues.map(
                (item) => _pdfRow(
                  item.name,
                  currency.format(item.amount),
                  indent: 15,
                ),
              ),

              pw.SizedBox(height: 10),
              pw.Divider(thickness: 0.5),
              _pdfRow(
                "Total Revenue",
                currency.format(data.totalRevenue),
                bold: true,
              ),
              _pdfRow(
                "Less Cost of Sales",
                currency.format(data.totalCostOfSales),
              ),
              _pdfRow(
                "Gross Profit",
                currency.format(data.grossProfit),
                bold: true,
                isDoubleUnderline: true,
              ),

              pw.SizedBox(height: 30),

              // --- EXPENSES ---
              pw.Text(
                "EXPENSES",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(height: 4),

              if (data.costOfSales.isNotEmpty) ...[
                pw.Text(
                  "Cost of Sales",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                ...data.costOfSales.map(
                  (item) => _pdfRow(
                    item.name,
                    currency.format(item.amount),
                    indent: 15,
                  ),
                ),
                pw.SizedBox(height: 8),
              ],

              if (data.operatingExpenses.isNotEmpty) ...[
                pw.Text(
                  "Operating Expense",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                ...data.operatingExpenses.map(
                  (item) => _pdfRow(
                    item.name,
                    currency.format(item.amount),
                    indent: 15,
                  ),
                ),
                pw.SizedBox(height: 8),
              ],

              pw.Divider(thickness: 1),
              _pdfRow(
                "TOTAL EXPENSE",
                currency.format(data.totalExpenses),
                bold: true,
              ),

              pw.SizedBox(height: 40),

              // --- SUMMARY BLOCK ---
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  children: [
                    _pdfRow(
                      "Total Revenue",
                      currency.format(data.totalRevenue),
                    ),
                    _pdfRow(
                      "Less Total Expenses",
                      currency.format(data.totalExpenses),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Divider(thickness: 1.5, color: PdfColors.black),
                    ),
                    _pdfRow(
                      data.netIncomeLabel,
                      currency.format(data.netIncome),
                      bold: true,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Income_Statement_${data.businessName}.pdf',
    );
  }

  static pw.Widget _pdfRow(
    String label,
    String amount, {
    double indent = 0,
    bool bold = false,
    double fontSize = 10,
    bool isDoubleUnderline = false,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(left: indent, top: 2, bottom: 2),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  fontSize: fontSize,
                ),
              ),
              pw.Text(
                amount,
                style: pw.TextStyle(
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
          if (isDoubleUnderline)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 2),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 1, style: pw.BorderStyle.solid),
                ),
              ),
              height: 2,
            ),
        ],
      ),
    );
  }
}
