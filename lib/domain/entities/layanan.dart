import 'package:equatable/equatable.dart';

/// Entity murni untuk jenis layanan laundry (tabel `layanan` pada ERD proposal).
class Layanan extends Equatable {
  final int? id;
  final String namaLayanan;
  final double hargaPerUnit;
  final String satuan; // contoh: 'kg', 'pasang'
  final bool isActive;

  const Layanan({
    this.id,
    required this.namaLayanan,
    required this.hargaPerUnit,
    required this.satuan,
    this.isActive = true,
  });

  Layanan copyWith({
    int? id,
    String? namaLayanan,
    double? hargaPerUnit,
    String? satuan,
    bool? isActive,
  }) {
    return Layanan(
      id: id ?? this.id,
      namaLayanan: namaLayanan ?? this.namaLayanan,
      hargaPerUnit: hargaPerUnit ?? this.hargaPerUnit,
      satuan: satuan ?? this.satuan,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, namaLayanan, hargaPerUnit, satuan, isActive];
}
