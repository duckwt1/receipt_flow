sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class OcrException extends AppException {
  const OcrException(super.message, {super.cause});
}
