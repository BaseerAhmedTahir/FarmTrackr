import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:goat_tracker/models/goat.dart';
import 'dart:convert';

class QRService {
  static String generateQRData(Goat goat) {
    final Map<String, dynamic> qrData = {
      'id': goat.id,
      'tag': goat.tagNumber,
      'type': 'goat',
      'timestamp': DateTime.now().toIso8601String(),
    };
    return jsonEncode(qrData);
  }

  static Widget generateQRCode(String data, {double size = 200.0}) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }

  static Widget buildQRScanner({
    required Function(String) onDetect,
    MobileScannerController? controller,
  }) {
    return MobileScanner(
      controller: controller ?? MobileScannerController(),
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          if (barcode.rawValue != null) {
            onDetect(barcode.rawValue!);
          }
        }
      },
    );
  }

  static Future<Map<String, dynamic>?> parseQRData(String rawData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(rawData);
      if (data['type'] == 'goat' && data['id'] != null) {
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
