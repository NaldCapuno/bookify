import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';

class PdfExportService {
  static Future<void> exportIncomeStatement(IncomeStatement data) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: 'P');
    final dateFormat = DateFormat('MMMM dd, yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      data.businessName,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      "INCOME STATEMENT",
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    pw.Text(
                      "For the Period: ${dateFormat.format(data.periodStart)} - ${dateFormat.format(data.periodEnd)}",
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Revenue Section
              _buildSectionHeader("REVENUE"),
              ...data.revenues.map(
                (item) => _buildLineItem(
                  item.name,
                  currencyFormat.format(item.amount),
                ),
              ),
              pw.Divider(),
              _buildLineItem(
                "Total Revenue",
                currencyFormat.format(data.totalRevenue),
                isBold: true,
              ),
              pw.SizedBox(height: 20),

              // Expenses Section
              _buildSectionHeader("EXPENSES"),
              if (data.costOfSales.isNotEmpty) ...[
                pw.Text(
                  "Cost of Sales",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                ...data.costOfSales.map(
                  (item) => _buildLineItem(
                    item.name,
                    currencyFormat.format(item.amount),
                  ),
                ),
              ],
              if (data.operatingExpenses.isNotEmpty) ...[
                pw.Text(
                  "Operating Expenses",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                ...data.operatingExpenses.map(
                  (item) => _buildLineItem(
                    item.name,
                    currencyFormat.format(item.amount),
                  ),
                ),
              ],
              pw.Divider(),
              _buildLineItem(
                "Total Expenses",
                currencyFormat.format(data.totalExpenses),
                isBold: true,
              ),
              pw.SizedBox(height: 20),

              // Net Income
              pw.Divider(thickness: 2),
              _buildLineItem(
                data.netIncomeLabel,
                currencyFormat.format(data.netIncome),
                isBold: true,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildLineItem(
    String label,
    String amount, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            amount,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
