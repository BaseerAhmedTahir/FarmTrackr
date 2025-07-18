import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);
  static DateTime? _lastAttempt;

  static Future<bool> canAttemptAuth() async {
    if (_lastAttempt != null) {
      final difference = DateTime.now().difference(_lastAttempt!);
      if (difference.inSeconds < 30) {
        return false;
      }
    }
    _lastAttempt = DateTime.now();
    return true;
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Disable email confirmation
      );
      
      if (response.user != null) {
        // Automatically sign in after signup
        return await signIn(email: email, password: password);
      }
      return response;
    } catch (e) {
      throw AuthException(
        e.toString().contains('429') 
          ? 'Please try again in a few moments' 
          : 'Failed to create account: ${e.toString()}'
      );
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (!await canAttemptAuth()) {
      throw const AuthException(
        'Please wait before trying again',
      );
    }

    AuthException? lastError;
    for (int i = 0; i < _maxRetries; i++) {
      try {
        return await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } on AuthException catch (e) {
        lastError = e;
        if (e.statusCode == 429) {
          // Rate limited, wait before retrying
          await Future.delayed(_retryDelay * (i + 1));
          continue;
        }
        rethrow;
      }
    }
    throw lastError ?? const AuthException('Failed to sign in after multiple attempts');
  }
}
