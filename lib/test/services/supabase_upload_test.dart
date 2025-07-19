import 'package:flutter_test/flutter_test.dart';
import 'package:goat_tracker/services/supabase_service.dart';
import 'dart:typed_data';
import '../../test_helper.dart';

void main() {
  setUpAll(() async {
    await setupTestSuite();
  });

  test('image upload helper works', () async {
    final bytes = Uint8List(10);
    await Svc.addGoat(
      tagId: 'test-tag',
      price: 0,
      date: DateTime.now(),
      caretakerId: 'uuid-placeholder',
      photoBytes: bytes,
      ext: 'jpg',
    );
    expect(true, true);  // just checking for no exceptions
  });
}
