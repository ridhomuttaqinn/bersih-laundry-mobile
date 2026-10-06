import '../errors/failures.dart';

/// Tipe hasil operasi ala "Either" yang ringan, tanpa dependensi tambahan.
/// Dipakai oleh seluruh usecase & repository agar lapisan presentasi
/// tidak pernah menangani exception mentah secara langsung.
sealed class Result<T> {
  const Result();

  /// Membungkus nilai sukses.
  const factory Result.success(T data) = Success<T>;

  /// Membungkus kegagalan.
  const factory Result.failure(Failure failure) = Failed<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failed<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(data: final d) => d,
        Failed<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Failed<T>(failure: final f) => f,
      };

  /// Pattern-matching helper agar UI mudah menangani kedua kasus.
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is Failed<T>) return failure(self.failure);
    throw StateError('Unreachable');
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failed<T> extends Result<T> {
  final Failure failure;
  const Failed(this.failure);
}
