import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> setupTestSuite() async {
  // Load env variables
  await dotenv.load(fileName: '.env.test');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'http://localhost:54321',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'test-key',
  );
}
