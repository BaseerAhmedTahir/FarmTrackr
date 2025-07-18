import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:gotrue_flutter/gotrue_flutter.dart'; // for EmptyLocalStorage

import 'package:goat_tracker/services/supabase_service.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.';
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    PathProviderPlatform.instance = FakePathProviderPlatform();

    await Supabase.initialize(
      url: 'https://your-project.supabase.co',
      anonKey: 'your-anon-key'
    );
  });

  test('image upload helper works', () async {
    final bytes = Uint8List(10);
    await Svc.addGoat(
      tagId: 'test-tag',
      price: 0,
      date: DateTime.now(),
      caretakerId: 'uuid-placeholder', // <-- Replace with valid ID
      photoBytes: bytes,
      ext: 'jpg',
    );
    expect(true, isTrue); // passes if no exceptions
  });
}
