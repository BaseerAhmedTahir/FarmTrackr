import 'package:flutter/material.dart';
import 'package:goat_tracker/services/supabase_service.dart';

class CaretakerList extends StatelessWidget {
  const CaretakerList({super.key});
  @override
  Widget build(BuildContext ctx) {
    return StreamBuilder(
      stream: Svc.caretakers(),
      builder: (ctx, AsyncSnapshot<List<Map>> snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final list = snap.data!;
        if (list.isEmpty) {
          return const Center(child: Text('No caretakers yet'));
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final c = list[i];
            return ListTile(
              title: Text(c['name']),
              subtitle: Text(c['phone'] ?? ''),
            );
          },
        );
      },
    );
  }
}