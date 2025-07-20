import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> handleError(Object error, String operation) async {
    if (error is PostgrestException) {
      // Handle Postgrest errors
      switch (error.code) {
        case '23505': // Unique violation
          throw 'A record with the same unique identifier already exists.';
        case '23503': // Foreign key violation
          throw 'Referenced record does not exist.';
        default:
          throw 'Database error: ${error.message}';
      }
    } else if (error is StorageException) {
      // Handle Storage errors
      throw 'Storage error: ${error.message}';
    } else {
      // Handle other errors
      throw 'Error during $operation: $error';
    }
  }

  Future<T> handleResponse<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      return await operation();
    } catch (e) {
      await handleError(e, operationName);
      rethrow;
    }
  }
}
