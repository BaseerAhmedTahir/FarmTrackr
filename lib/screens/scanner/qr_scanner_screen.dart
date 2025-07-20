import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat_tracker/services/qr_service.dart';
import 'package:goat_tracker/providers.dart';
import 'package:goat_tracker/widgets/app_bar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onDetect(String data) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final qrData = await QRService.parseQRData(data);
      if (qrData != null && qrData['type'] == 'goat') {
        final goatId = qrData['id'] as String;
        if (!mounted) return;
        
        // Navigate to goat details
        Navigator.of(context).pushReplacementNamed(
          '/goat',
          arguments: {'id': goatId},
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR code format'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning QR code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Scan QR Code'),
      body: Stack(
        children: [
          QRService.buildQRScanner(
            onDetect: _onDetect,
            controller: _controller,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: const Text(
                'Point the camera at a goat\'s QR code to scan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller?.toggleTorch();
        },
        child: ValueListenableBuilder(
          valueListenable: _controller?.torchState ?? ValueNotifier(false),
          builder: (context, state, child) {
            switch (state as TorchState) {
              case TorchState.off:
                return const Icon(Icons.flash_off, color: Colors.grey);
              case TorchState.on:
                return const Icon(Icons.flash_on, color: Colors.yellow);
            }
          },
        ),
      ),
    );
  }
}
