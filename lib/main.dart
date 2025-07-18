import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load();      // loads .env

  // await Supabase.initialize(
  //   url: dotenv.env['SUPABASE_URL']!,
  //   anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  // );
  await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goat Tracker',
      theme: ThemeData.dark(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) return const GoatList();

    return Scaffold(
      appBar: AppBar(title: const Text('Login (Magic Link)')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signInWithOtp(email: _emailCtrl.text);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Link sent! Check your email.')));
              },
              child: const Text('Send Link'),
            ),
          ],
        ),
      ),
    );
  }
}

class GoatList extends StatelessWidget {
  const GoatList({super.key});
  @override
  Widget build(BuildContext context) {
    final stream = Supabase.instance.client
        .from('goats')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .limit(20);

    return Scaffold(
      appBar: AppBar(title: const Text('My Goats')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final goats = snapshot.data!;
          if (goats.isEmpty) return const Center(child: Text('No goats yet 🐐'));
          return ListView(
            children: goats.map((g) => ListTile(title: Text(g['tag_id'] ?? 'no-tag'))).toList(),
          );
        },
      ),
    );
  }
}