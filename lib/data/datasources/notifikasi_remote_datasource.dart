import '../../domain/entities/notifikasi.dart';
import 'api_client.dart';

class NotifikasiRemoteDatasource {
  Future<List<Notifikasi>> getByPelanggan(int idPelanggan) async {
    final data = await ApiClient.get('/notifikasi', queryParameters: {
      'id_pelanggan': '$idPelanggan',
    }) as List;
    return data.map((item) {
      final row = Map<String, dynamic>.from(item as Map);
      return Notifikasi(
        id: (row['id_notifikasi'] as num?)?.toInt(),
        idPelanggan: (row['id_pelanggan'] as num).toInt(),
        idPesanan: (row['id_pesanan'] as num).toInt(),
        pesan: row['pesan'] as String,
        dibaca: row['dibaca'] == true || row['dibaca'] == 1,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }

  Future<void> markAsRead(int id) async {
    await ApiClient.post('/notifikasi/$id/read');
  }

  Future<int> countUnread(int idPelanggan) async {
    final data =
        await ApiClient.get('/notifikasi/unread-count', queryParameters: {
      'id_pelanggan': '$idPelanggan',
    });
    return (data as num).toInt();
  }
}
