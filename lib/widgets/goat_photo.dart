import 'package:flutter/material.dart';
import 'package:goat_tracker/services/service.dart';
import '../services/supabase_service.dart';

class GoatPhoto extends StatefulWidget {
  final String? photoPath;
  final BoxFit fit;
  
  const GoatPhoto({
    super.key,
    required this.photoPath,
    this.fit = BoxFit.cover,
  });

  @override
  State<GoatPhoto> createState() => _GoatPhotoState();
}

class _GoatPhotoState extends State<GoatPhoto> {
  Future<String>? _signedUrlFuture;

  @override
  void initState() {
    super.initState();
    if (widget.photoPath != null) {
      _signedUrlFuture = Svc.getSignedUrl(widget.photoPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photoPath == null) {
      return const Icon(Icons.image_not_supported, size: 48);
    }

    return FutureBuilder<String>(
      future: _signedUrlFuture ?? Future.value(''),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Icon(Icons.image_not_supported, size: 48);
        }

        return Image.network(
          snapshot.data!,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 48);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
