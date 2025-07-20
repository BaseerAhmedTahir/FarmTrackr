import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'add_scan_dialog.dart';

class QrScannerScreen extends StatefulWidget {
  final String goatId;

  const QrScannerScreen({super.key, required this.goatId});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => controller.switchCamera(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final code = capture.barcodes.first.rawValue;
          if (code != null && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AddScanDialog(
                  goatId: widget.goatId,
                  scanType: 'qr',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
