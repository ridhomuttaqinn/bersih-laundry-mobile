import 'package:bersih_laundry_app/data/datasources/layanan_remote_datasource.dart';
import 'package:bersih_laundry_app/data/models/layanan_model.dart';
import 'package:bersih_laundry_app/data/repositories/layanan_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLayananRemoteDatasource extends LayananRemoteDatasource {
  @override
  Future<List<LayananModel>> getAll({bool onlyActive = false}) async {
    return const [
      LayananModel(
        id: 1,
        namaLayanan: 'Cuci Kering',
        hargaPerUnit: 6000,
        satuan: 'kg',
      ),
    ];
  }
}

void main() {
  test('LayananModel maps primary key and price columns', () {
    final model = LayananModel.fromMap(const {
      'id_layanan': 7,
      'nama_layanan': 'Cuci Kering',
      'harga_per_unit': 6000.0,
      'satuan': 'kg',
      'is_active': 1,
    });

    expect(model.id, 7);
    expect(model.hargaPerUnit, 6000);
    expect(model.isActive, isTrue);
  });

  test('LayananModel serializes fields expected by Laravel API', () {
    const model = LayananModel(
      namaLayanan: 'Cuci Kering',
      hargaPerUnit: 6000,
      satuan: 'kg',
    );

    expect(model.toJson(), const {
      'nama_layanan': 'Cuci Kering',
      'harga_per_unit': 6000,
      'satuan': 'kg',
      'is_active': true,
    });
  });

  test('getAllLayanan loads services from remote datasource', () async {
    final repository = LayananRepositoryImpl(
      FakeLayananRemoteDatasource(),
    );

    final result = await repository.getAllLayanan();

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, isNotEmpty);
    expect(result.dataOrNull!.first.namaLayanan, 'Cuci Kering');
  });
}
