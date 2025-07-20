class SupabaseError implements Exception {
  final String message;
  final dynamic originalError;

  SupabaseError(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'SupabaseError: $message (Original error: $originalError)';
    }
    return 'SupabaseError: $message';
  }
}
