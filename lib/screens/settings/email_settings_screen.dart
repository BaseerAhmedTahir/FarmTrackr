import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat_tracker/widgets/app_bar.dart';
import 'package:goat_tracker/providers.dart';

class EmailSettingsScreen extends ConsumerStatefulWidget {
  const EmailSettingsScreen({super.key});

  @override
  ConsumerState<EmailSettingsScreen> createState() => _EmailSettingsScreenState();
}

class _EmailSettingsScreenState extends ConsumerState<EmailSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _senderEmailController;
  bool _useSSL = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController();
    _portController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _senderEmailController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _senderEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await ref.read(supabaseClientProvider)
          .from('email_settings')
          .select()
          .single();

      setState(() {
        _hostController.text = settings['host'] as String;
        _portController.text = (settings['port'] as int).toString();
        _usernameController.text = settings['username'] as String;
        _passwordController.text = settings['password'] as String;
        _senderEmailController.text = settings['sender_email'] as String;
        _useSSL = settings['use_ssl'] as bool? ?? true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(supabaseClientProvider).from('email_settings').upsert({
        'host': _hostController.text,
        'port': int.parse(_portController.text),
        'username': _usernameController.text,
        'password': _passwordController.text,
        'sender_email': _senderEmailController.text,
        'use_ssl': _useSSL,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Email Settings'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        labelText: 'SMTP Host',
                        hintText: 'e.g., smtp.gmail.com',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter SMTP host';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _portController,
                      decoration: const InputDecoration(
                        labelText: 'SMTP Port',
                        hintText: 'e.g., 587',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter SMTP port';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Please enter a valid port number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'Your email username',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Your email password or app password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senderEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Sender Email',
                        hintText: 'The email address to send from',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter sender email';
                        }
                        if (!value!.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Use SSL'),
                      subtitle: const Text(
                        'Enable for secure connection (recommended)',
                      ),
                      value: _useSSL,
                      onChanged: (value) {
                        setState(() => _useSSL = value);
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveSettings,
                      child: const Text('Save Settings'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
