import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mona_interior/models/crm_models.dart';
import 'package:mona_interior/models/finance_models.dart';
import 'package:mona_interior/models/site_models.dart';

class PdfGenerator {
  static Future<void> generateAndShareQuotation(Quotation quotation) async {
    final pdf = pw.Document();

    final subtotal = quotation.total / 1.18; // assuming total includes 18% tax
    final tax = quotation.total - subtotal;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Mona Interior Studio', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Professional Interior Design Services', style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('QUOTATION', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('No: \${quotation.quoteNo}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: \${quotation.date}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Addresses
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('From:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Mona Interior Studio\nNo 378, Kagidhapuram, 4th Cross St,\nChennai, Tamil Nadu 600117\nPh: +91 91 76093 482'),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(quotation.clientName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(quotation.projectTitle),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Items Table
              pw.Table.fromTextArray(
                headers: ['Description', 'Qty/Area', 'Unit', 'Rate', 'Amount'],
                data: quotation.items.map((item) {
                  return [
                    item['description'] ?? '',
                    item['area'] ?? '',
                    item['unit'] ?? '',
                    item['rate'] ?? '',
                    item['amount'] ?? '',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
                cellAlignment: pw.Alignment.centerRight,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                },
              ),
              pw.SizedBox(height: 20),
              
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: ₹\${subtotal.toStringAsFixed(2)}'),
                      pw.Text('GST (18%): ₹\${tax.toStringAsFixed(2)}'),
                      pw.Divider(),
                      pw.Text('Total: ₹\${quotation.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              // Terms
              pw.Text('Terms & Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('1. This is an estimate/quotation and not a final bill.\n2. Payment Terms: 50% advance, 40% during work, 10% on completion.\n3. Validity: This quotation is valid for 30 days.', style: const pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'Quotation_\${quotation.quoteNo}.pdf');
  }

  static Future<void> generateAndShareInvoice(Invoice invoice) async {
    final pdf = pw.Document();

    final isNonGST = invoice.billType == 'Non-GST';
    final subtotal = isNonGST ? invoice.total : invoice.total / 1.18;
    final tax = isNonGST ? 0.0 : invoice.total - subtotal;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Mona Interior Studio', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Professional Interior Design Services', style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('No: \${invoice.invoiceNo}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: \${invoice.invoiceDate}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Addresses
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('From:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Mona Interior Studio\nNo 378, Kagidhapuram, 4th Cross St,\nChennai, Tamil Nadu 600117\nPh: +91 91 76093 482'),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.clientName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.projectTitle),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Items Table
              pw.Table.fromTextArray(
                headers: ['Description', 'Qty/Area', 'Unit', 'Rate', 'Amount'],
                data: invoice.items.map((item) {
                  return [
                    item['description'] ?? '',
                    item['area'] ?? '',
                    item['unit'] ?? '',
                    item['rate'] ?? '',
                    item['amount'] ?? '',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
                cellAlignment: pw.Alignment.centerRight,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                },
              ),
              pw.SizedBox(height: 20),
              
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: ₹\${subtotal.toStringAsFixed(2)}'),
                      if (!isNonGST) pw.Text('GST (18%): ₹\${tax.toStringAsFixed(2)}'),
                      pw.Divider(),
                      pw.Text('Total: ₹\${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              // Signature / Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('For Mona Interior Studio'),
                      pw.SizedBox(height: 40),
                      pw.Text('Authorized Signatory', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  )
                ],
              ),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'Invoice_\${invoice.invoiceNo}.pdf');
  }

  static Future<void> printCompletionCertificate(Site site) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Mona Interior Studio', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Professional Interior Design Services', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                      pw.Text('Phone: +91 91 76093 482', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.Text('Address: No 378, Kagidhapuram, 4th Cross St, Shakti Nagar,', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('S.Kolathur, Madipakkam, Chennai, Tamil Nadu 600117', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: \${DateTime.now().toIso8601String().split("T")[0]}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Ref WO: \${site.id}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.Divider(color: PdfColors.black, thickness: 2),
              pw.SizedBox(height: 40),
              
              // Title
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 4),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 2)),
                ),
                child: pw.Text('COMPLETION CERTIFICATE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
              ),
              pw.SizedBox(height: 60),
              
              // Body
              pw.Text('To Whom It May Concern', style: pw.TextStyle(fontSize: 22, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 30),
              pw.Text(
                'This is to officially certify that the interior design and execution project titled:',
                style: const pw.TextStyle(fontSize: 14),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 2)),
                ),
                child: pw.Text('"\${site.name}"', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 30),
              pw.Text('undertaken for our esteemed client:', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Text(site.clientName.isNotEmpty ? site.clientName : '________________________', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              if (site.organizationName.isNotEmpty)
                pw.Text('(\${site.organizationName})', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
              
              pw.SizedBox(height: 60),
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('DECLARATION OF COMPLETION', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800, letterSpacing: 1)),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'All contracted works are finished according to the agreed specifications, and there are no pending works remaining for this project.',
                      style: const pw.TextStyle(fontSize: 12),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              pw.Spacer(),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Text(
                'This is a computer generated document and does not require a physical signature.',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'Completion_Certificate_WO_\${site.id}.pdf');
  }

  static Future<void> printFinalSettlement(Site site, double billed, double paid, double spent) async {
    final pdf = pw.Document();
    final balance = (site.budget > 0 ? site.budget : billed) - paid;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Mona Interior Studio', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Professional Interior Design Services', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                      pw.Text('Phone: +91 91 76093 482', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('FINAL SETTLEMENT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: \${DateTime.now().toIso8601String().split("T")[0]}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Ref WO: \${site.id}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.Divider(color: PdfColors.black, thickness: 2),
              pw.SizedBox(height: 20),
              
              // Project Details
              pw.Text('PROJECT DETAILS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                child: pw.Column(
                  children: [
                    _buildTableRow('Project Name', site.name),
                    _buildTableRow('Client Name', site.clientName),
                    _buildTableRow('Organization', site.organizationName),
                    _buildTableRow('Site Address', site.address),
                    _buildTableRow('Status', site.status),
                  ]
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Financial Summary
              pw.Text('FINANCIAL SUMMARY', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                child: pw.Column(
                  children: [
                    _buildTableRow('Total Budget', 'Rs. \${site.budget.toStringAsFixed(2)}'),
                    _buildTableRow('Total Invoiced', 'Rs. \${billed.toStringAsFixed(2)}'),
                    _buildTableRow('Total Receipts', 'Rs. \${paid.toStringAsFixed(2)}'),
                    pw.Divider(color: PdfColors.grey300),
                    _buildTableRow(
                      balance > 0 ? 'Balance Due' : 'Fully Paid',
                      'Rs. \${balance.abs().toStringAsFixed(2)}',
                      isBold: true,
                      color: balance > 0 ? PdfColors.red : PdfColors.green,
                    ),
                  ]
                ),
              ),
              
              pw.SizedBox(height: 30),
              pw.Text('This document represents the final settlement summary for the above project.', style: const pw.TextStyle(fontSize: 12)),
              
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 150, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)))),
                      pw.SizedBox(height: 5),
                      pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 150, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)))),
                      pw.SizedBox(height: 5),
                      pw.Text('Client Signature', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'Final_Settlement_WO_\${site.id}.pdf');
  }

  static pw.Widget _buildTableRow(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value.isNotEmpty ? value : 'N/A', style: pw.TextStyle(fontSize: 12, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color ?? PdfColors.black)),
        ],
      ),
    );
  }
}
