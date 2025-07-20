import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:goat_tracker/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      anonKey: 'test-key',
    );
  });

  test('image upload helper throws without auth', () async {
    final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    final testCaretakerId = 'test-caretaker-id';

    try {
      await SupabaseService().addGoat(
        tagId: 'TEST001',
        price: 100.0,
        date: DateTime.now(),
        caretakerId: testCaretakerId,
        photoBytes: bytes,
        ext: 'jpg',
      );
      fail('Should throw an error without auth');
    } catch (e) {
      expect(e, isA<TypeError>());
      expect(e.toString(), contains('Null check operator used on a null value'));
    }
  });
}
