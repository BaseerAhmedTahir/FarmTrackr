import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goat_tracker/services/supabase_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:goat_tracker/widgets/platform_image.dart';

import '../../providers.dart'; // Adjust the path as needed to where caretakerProvider is defined

class AddGoatScreen extends ConsumerStatefulWidget {
  const AddGoatScreen({super.key});
  @override
  ConsumerState<AddGoatScreen> createState() => _AddGoatScreenState();
}

class _AddGoatScreenState extends ConsumerState<AddGoatScreen> {
  final _tag = TextEditingController();
  final _price = TextEditingController();
  DateTime _date = DateTime.now();
  String? _caretakerId;

  XFile? _picked;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final caretakers = ref.watch(caretakerProvider);   // riverpod provider stream
    return Scaffold(
      appBar: AppBar(title: const Text('New Goat')),
      body: caretakers.when(
        data: (list) => _body(list),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Err $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_picked == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pick photo first')));
            return;
          }
          // Compress the image before upload
          final bytes = await _picked!.readAsBytes();
          final compressedBytes = kIsWeb ? bytes : await FlutterImageCompress.compressWithList(
            bytes,
            quality: 70, // 70% quality
            minHeight: 800,
            minWidth: 600,
          );

          await Svc.addGoat(
            tagId: _tag.text,
            price: double.parse(_price.text),
            date: _date,
            caretakerId: _caretakerId!,
            photoBytes: compressedBytes,
            ext: 'jpg', // Always convert to jpg for better compression
          );
          if (!mounted) return;
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _body(List<Map> caretakers) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          GestureDetector(
            onTap: () async {
              _picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
              setState(() {});
            },
            child: _picked == null
                ? Container(
                    height: 150,
                    color: Colors.grey[700],
                    child: const Center(child: Text('Tap to pick photo')),
                  )
                : PlatformImage(imageFile: _picked!, height: 150, fit: BoxFit.cover),
          ),
          TextField(controller: _tag, decoration: const InputDecoration(labelText: 'Tag ID')),
          TextField(
              controller: _price,
              decoration: const InputDecoration(labelText: 'Purchase Price'),
              keyboardType: TextInputType.number),
          DropdownButtonFormField<String>(
            value: _caretakerId,
            items: [
              for (var c in caretakers)
                DropdownMenuItem(value: c['id'], child: Text(c['name']))
            ],
            onChanged: (v) => setState(() => _caretakerId = v),
            decoration: const InputDecoration(labelText: 'Caretaker'),
          ),
          ListTile(
            title: const Text('Purchase Date'),
            subtitle: Text(DateFormat.yMMMd().format(_date)),
            onTap: () async {
              final pick = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDate: _date,
              );
              if (pick != null) setState(() => _date = pick);
            },
          ),
        ]),
      );
}