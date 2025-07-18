import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'add_scan_dialog.dart';

class NfcScannerScreen extends StatefulWidget {
  final String goatId;

  const NfcScannerScreen({super.key, required this.goatId});

  @override
  State<NfcScannerScreen> createState() => _NfcScannerScreenState();
}

class _NfcScannerScreenState extends State<NfcScannerScreen> {
  bool _isScanning = false;

  Future<void> _startScan() async {
    setState(() => _isScanning = true);

    try {
      // Check NFC availability
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NFC is not available on this device')),
        );
        return;
      }

      // Start NFC session
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          // Stop the session when a tag is found
          await NfcManager.instance.stopSession();
          if (!mounted) return;

          // Show the add scan dialog
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AddScanDialog(
                goatId: widget.goatId,
                scanType: 'nfc',
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan NFC Tag'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isScanning) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Scanning for NFC tags...'),
              const SizedBox(height: 8),
              const Text('Hold your phone near the tag'),
            ] else ...[
              const Icon(Icons.nfc, size: 48),
              const SizedBox(height: 16),
              const Text('Tap to start scanning'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _startScan,
                child: const Text('Start Scan'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
