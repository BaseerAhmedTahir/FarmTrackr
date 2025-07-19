import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockStorageClient extends Mock implements StorageClient {}

Future<void> setupSupabaseMocks() async {
  final mockClient = MockSupabaseClient();
  final mockStorage = MockStorageClient();

  // Mock storage behavior
  when(mockClient.storage).thenReturn(mockStorage);
  when(mockStorage.from(any)).thenReturn(any);

  // Mock Supabase instance
  final instance = Supabase.instance;
  when(instance.client).thenReturn(mockClient);
}
