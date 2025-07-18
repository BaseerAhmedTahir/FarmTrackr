import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class Svc {
  // EXPENSE
  static Future<void> addExpense({
    required String goatId,
    required double amt,
    required String type,
    String? notes,
    DateTime? date,
  }) async {
    try {
      final record = await _client.from('expenses').insert({
        'goat_id': goatId,
        'amount': amt,
        'type': type,
        'notes': notes,
        'expense_date': (date ?? DateTime.now()).toIso8601String(),
      }).select().single();
    
      // Create notification directly in the notifications table
      await _client.from('notifications').insert({
        'message': 'New expense of ₹$amt added for goat $goatId',
        'type': 'expense',
        'record_id': record['id'],
        'read': false,
        'created_at': DateTime.now().toIso8601String()
      });
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // SALE
  static Future<void> sellGoat(String id, double price) async {
    try {
      final record = await _client.from('sales').insert({
        'goat_id': id,
        'sale_price': price,
        'sale_date': DateTime.now().toIso8601String(),
        'payment_mode': 'cash'
      }).select().single();

      await _client.from('goats').update({'is_sold': true}).eq('id', id);

      // Create notification directly in the notifications table
      await _client.from('notifications').insert({
        'message': 'Goat $id was sold for ₹$price',
        'type': 'sale',
        'record_id': record['id'],
        'read': false,
        'created_at': DateTime.now().toIso8601String()
      });
    } catch (e) {
      throw Exception('Failed to record sale: $e');
    }
  }

  // FINANCIAL SUMMARY STREAM
  static Stream<Map<String, dynamic>> financeSummary() => _client
      .from('v_goat_financials')
      .select()
      .asStream()
      .map((rows) {
        double invested = 0, sales = 0, exp = 0, profit = 0;
        for (var r in rows) {
          invested += (r['purchase_price'] as num).toDouble();
          sales    += (r['sale_price'] ?? 0) as double;
          exp      += (r['total_expense'] as num).toDouble();
          profit   += (r['net_profit'] as num).toDouble();
        }
        return {
          'invested': invested,
          'sales': sales,
          'expense': exp,
          'profit': profit,
          'count': rows.length
        };
      });
  static final _client = Supabase.instance.client;
  static final _bucket = _client.storage.from('goat-photos');

  // Add a new caretaker
  static Future<void> addCaretaker({
    required String name,
    String? phone,
    String? loc,
    String? payment,
  }) =>
    _client.from('caretakers').insert({
      'name': name,
      'phone': phone,
      'location': loc,
      'payment_terms': payment,
    });

  // Add a new goat with photo upload
  static Future<void> addGoat({
    required String tagId,
    required double price,
    required DateTime date,
    required String caretakerId,
    required Uint8List photoBytes,
    required String ext,
  }) async {
    final fileName = '${const Uuid().v4()}.$ext';
    await _bucket.uploadBinary(
      fileName,
      photoBytes,
      fileOptions: FileOptions(contentType: 'image/$ext'),
    );
    final publicUrl = _bucket.getPublicUrl(fileName);

    await _client.from('goats').insert({
      'tag_id': tagId,
      'purchase_price': price,
      'purchase_date': date.toIso8601String(),
      'photo_url': publicUrl,
      'caretaker_id': caretakerId,
    });
  }

  // Stream caretakers table
  static Stream<List<Map<String, dynamic>>> caretakers() =>
    _client.from('caretakers')
      .select()
      .order('name')
      .asStream();

  // Stream goats table
  static Stream<List<Map<String, dynamic>>> goats() =>
    _client.from('goats')
      .select('*, caretakers!inner(name)')
      .order('created_at')
      .asStream();

  // Get finance data for CSV export
  static Future<List<Map<String, dynamic>>> getFinanceData() =>
    _client.from('v_goat_financials').select();

  // Get expense summary by category
  static Stream<List<Map<String, dynamic>>> expenseSummary() =>
    _client.from('expenses')
      .select('type, amount')
      .asStream()
      .map((data) {
        final Map<String, dynamic> summary = {};
        for (final expense in data) {
          final type = expense['type'] as String;
          final amount = (expense['amount'] as num).toDouble();
          if (!summary.containsKey(type)) {
            summary[type] = {'total': 0.0, 'count': 0};
          }
          summary[type]['total'] += amount;
          summary[type]['count']++;
        }
        return summary.entries.map((e) => {
          'type': e.key,
          'total': e.value['total'],
          'count': e.value['count']
        }).toList();
      });

  // Notification methods
  static Stream<List<Map<String, dynamic>>> notificationStream() =>
    _client.from('notifications')
      .select()
      .order('created_at', ascending: false)
      .limit(50)
      .asStream();

  static Future<void> markNotificationAsRead(String id) =>
    _client.from('notifications')
      .update({'read': true})
      .eq('id', id);

  static Future<void> deleteNotification(String id) =>
    _client.from('notifications')
      .delete()
      .eq('id', id);

  // Weight tracking methods
  static Future<void> addWeight(String goatId, double kg) =>
    _client.from('weight_logs').insert({
      'goat_id': goatId,
      'weight_kg': kg,
      'recorded_at': DateTime.now().toIso8601String()
    });

  static Stream<List<Map<String, dynamic>>> weightStream(String goatId) =>
    _client.from('weight_logs')
      .select()
      .eq('goat_id', goatId)
      .order('recorded_at')
      .asStream();
      
  // QR/NFC scan methods
  static Future<void> addScan({
    required String goatId,
    required String scanType,
    required String location,
    String? notes
  }) =>
    _client.from('scans').insert({
      'goat_id': goatId,
      'scan_type': scanType,
      'location': location,
      'notes': notes,
      'scanned_at': DateTime.now().toIso8601String()
    });

  static Stream<List<Map<String, dynamic>>> scanHistory(String goatId) =>
    _client.from('scans')
      .select()
      .eq('goat_id', goatId)
      .order('scanned_at', ascending: false)
      .asStream();
}
