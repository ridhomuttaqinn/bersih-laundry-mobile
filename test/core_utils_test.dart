import 'package:flutter_test/flutter_test.dart';
import 'package:bersih_laundry_app/core/utils/result.dart';
import 'package:bersih_laundry_app/core/utils/password_hasher.dart';
import 'package:bersih_laundry_app/core/utils/validators.dart';
import 'package:bersih_laundry_app/core/errors/failures.dart';
import 'package:bersih_laundry_app/domain/entities/layanan.dart';
import 'package:bersih_laundry_app/domain/entities/detail_pesanan.dart';

void main() {
  group('Result<T>', () {
    test('success wraps data correctly', () {
      const result = Result<int>.success(42);
      expect(result.isSuccess, true);
      expect(result.dataOrNull, 42);
      expect(result.failureOrNull, null);
    });

    test('failure wraps Failure correctly', () {
      const result = Result<int>.failure(ValidationFailure('invalid'));
      expect(result.isFailure, true);
      expect(result.dataOrNull, null);
      expect(result.failureOrNull?.message, 'invalid');
    });

    test('when() dispatches to the correct branch', () {
      const success = Result<int>.success(1);
      const failure = Result<int>.failure(ValidationFailure('err'));

      expect(success.when(success: (d) => 'ok:$d', failure: (f) => 'fail'), 'ok:1');
      expect(failure.when(success: (d) => 'ok', failure: (f) => 'fail:${f.message}'), 'fail:err');
    });
  });

  group('PasswordHasher', () {
    test('same password produces same hash', () {
      final hash1 = PasswordHasher.hash('secret123');
      final hash2 = PasswordHasher.hash('secret123');
      expect(hash1, hash2);
    });

    test('different passwords produce different hashes', () {
      final hash1 = PasswordHasher.hash('secret123');
      final hash2 = PasswordHasher.hash('secret124');
      expect(hash1, isNot(hash2));
    });

    test('verify() correctly validates a matching password', () {
      final hash = PasswordHasher.hash('mypassword');
      expect(PasswordHasher.verify('mypassword', hash), true);
      expect(PasswordHasher.verify('wrongpassword', hash), false);
    });

    test('plain password is never stored as-is', () {
      final hash = PasswordHasher.hash('plaintext');
      expect(hash, isNot('plaintext'));
    });
  });

  group('Validators', () {
    test('email validator rejects invalid format', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('user@example.com'), isNull);
    });

    test('password validator enforces minimum length', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('positiveNumber validator rejects zero and negative values', () {
      expect(Validators.positiveNumber('0'), isNotNull);
      expect(Validators.positiveNumber('-5'), isNotNull);
      expect(Validators.positiveNumber('2.5'), isNull);
    });
  });

  group('DetailPesanan.fromLayanan (FR-6: kalkulasi otomatis)', () {
    test('subtotal dihitung otomatis dari harga x berat/qty', () {
      const layanan = Layanan(id: 1, namaLayanan: 'Cuci Kering', hargaPerUnit: 6000, satuan: 'kg');
      final detail = DetailPesanan.fromLayanan(layanan, 3);
      expect(detail.subtotal, 18000);
    });
  });
}
