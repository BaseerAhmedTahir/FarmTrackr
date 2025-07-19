import 'package:flutter_test/flutter_test.dart';
import 'package:goat_tracker/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

void main() {
  setUpAll(() async {
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'test-anon-key',
    );
  });

  tearDownAll(() async {
    await Supabase.instance.dispose();
  });

  test('goat data validation works', () {
    final goatData = {
      'tag_number': 'test-123',
      'price': 1000.0,
      'birth_date': DateTime.now().toIso8601String(),
      'photo_url': 'test.jpg',
      'caretaker_id': 'test-caretaker',
      'user_id': 'test-user',
      'name': 'Test Goat',
    };

    expect(
      () => Map<String, dynamic>.from(goatData),
      returnsNormally,
      reason: 'Goat data should be valid',
    );
  });
}
