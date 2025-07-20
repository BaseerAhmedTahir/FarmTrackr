import 'package:flutter/material.dart';
import 'package:goat_tracker/services/service.dart';
import 'package:goat_tracker/services/supabase_service.dart';

class SellGoatScreen extends StatefulWidget {
  final Map goat;
  const SellGoatScreen(this.goat, {super.key});
  @override
  State<SellGoatScreen> createState() => _SellGoatScreenState();
}

class _SellGoatScreenState extends State<SellGoatScreen> {
  final _price = TextEditingController();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Record Sale')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text('Selling: ${widget.goat['tag_id']}'),
            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sale Price'),
            ),
            const Spacer(),
            ElevatedButton(
                onPressed: () async {
                  await Svc.sellGoat(
                      widget.goat['id'], double.parse(_price.text));
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save Sale'))
          ]),
        ),
      );
}
