class NullPointException implements Exception {
  final String? message;
  NullPointException([this.message]);

  @override
  String toString() => 'NullPointException($message)';
}

class UnsupportedOperationException implements Exception {
  final String? message;
  UnsupportedOperationException([this.message]);

  @override
  String toString() => 'UnsupportedOperationException($message)';
}
