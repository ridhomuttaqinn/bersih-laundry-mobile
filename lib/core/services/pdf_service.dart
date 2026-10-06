import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/pembayaran.dart';
import '../../domain/entities/pesanan.dart';
import '../constants/app_strings.dart';
import '../utils/formatters.dart';

/// FR-7: mencetak/menampilkan nota transaksi dalam bentuk PDF yang bisa
/// dibagikan (share) atau dicetak langsung ke printer thermal/biasa.
class PdfService {
  PdfService._();

  static Future<Uint8List> generateNota({
    required Pesanan pesanan,
    required Pembayaran pembayaran,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  AppStrings.appName,
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                  child: pw.Text('Nota Transaksi Laundry',
                      style: const pw.TextStyle(fontSize: 12))),
              pw.SizedBox(height: 12),
              pw.Divider(),
              _row('No. Pesanan', '#${pesanan.id}'),
              _row('Nama Pelanggan', pesanan.namaPelanggan ?? '-'),
              _row('Tanggal Masuk',
                  AppFormatters.dateTime(pesanan.tanggalMasuk)),
              _row('Alamat Jemput', pesanan.alamatJemput),
              _row('Jadwal Jemput', pesanan.jadwalJemput),
              pw.Divider(),
              pw.Text('Rincian Layanan',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1.4),
                  2: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _cell('Layanan', bold: true),
                      _cell('Qty', bold: true),
                      _cell('Subtotal', bold: true),
                    ],
                  ),
                  for (final item in pesanan.items)
                    pw.TableRow(children: [
                      _cell(item.layanan.namaLayanan),
                      _cell('${item.beratQty} ${item.layanan.satuan}'),
                      _cell(AppFormatters.currency(item.subtotal)),
                    ]),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: ${AppFormatters.currency(pesanan.totalBayar)}',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Divider(),
              _row('Metode Bayar', pembayaran.metodeBayar.toUpperCase()),
              _row('Tanggal Bayar',
                  AppFormatters.dateTime(pembayaran.tanggalBayar)),
              _row('Jumlah Dibayar',
                  AppFormatters.currency(pembayaran.jumlahBayar)),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Terima kasih telah menggunakan Bersih Laundry!',
                  style: pw.TextStyle(
                      fontSize: 10, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static Future<void> printOrShare(Uint8List bytes,
      {required String fileName}) async {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  static Future<void> printDirectly(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style:
                  const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            fontSize: 9,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }
}
