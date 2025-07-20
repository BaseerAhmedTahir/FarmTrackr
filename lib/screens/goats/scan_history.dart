import 'package:flutter/material.dart';
import 'package:goat_tracker/services/service.dart';
import 'package:goat_tracker/services/supabase_service.dart';
import 'package:intl/intl.dart';

class ScanHistory extends StatelessWidget {
  final String goatId;

  const ScanHistory({super.key, required this.goatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Svc.scanHistory(goatId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final scans = snapshot.data!;
        if (scans.isEmpty) {
          return const Center(child: Text('No scan history'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: scans.length,
          itemBuilder: (context, index) {
            final scan = scans[index];
            final date = DateTime.parse(scan['scanned_at']).toLocal();
            final formattedDate = DateFormat.yMMMd().format(date);
            final formattedTime = DateFormat.jm().format(date);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        scan['scan_type'] == 'qr' ? Icons.qr_code : Icons.nfc,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scan['location'],
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (scan['notes']?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 4),
                            Text(
                              scan['notes'],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                formattedTime,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
