import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:goat_tracker/widgets/app_bar.dart';

class PDFViewerScreen extends StatelessWidget {
  final File pdfFile;
  final String title;
  final VoidCallback? onShare;

  const PDFViewerScreen({
    super.key,
    required this.pdfFile,
    required this.title,
    this.onShare,
  });

  Future<void> _sharePDF() async {
    try {
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: title,
      );
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        actions: [
          IconButton(
            onPressed: _sharePDF,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: const Center(
        child: Text('TODO: Implement PDF viewer'),
      ),
    );
  }
}
