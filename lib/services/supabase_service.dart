import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class Svc {
  static final _client = Supabase.instance.client;
  static final _bucket = _client.storage.from('goat-photos');

  // Add a new goat with photo upload
  static Future<void> addGoat({
    required String tagId,
    required double price,
    required DateTime date,
    required String caretakerId,
    required Uint8List photoBytes,
    required String ext,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final fileName = '$userId/${const Uuid().v4()}.$ext';
    
    try {
      await _bucket.uploadBinary(
        fileName,
        photoBytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: false,
        ),
      );
      
      // Store just the file path, not the full URL
      final Map<String, dynamic> goatData = {
        'tag_number': tagId,
        'price': price,
        'birth_date': date.toIso8601String(),
        'photo_url': fileName, // Store only the file path
        'caretaker_id': caretakerId,
        'user_id': userId,
        'name': 'Goat #$tagId',
        'gender': 'unknown',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await _client.from('goats').insert(goatData);
    } on StorageException catch (e) {
      throw Exception('Failed to upload photo: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add goat: $e');
    }
  }

  // Stream caretakers table
  static Stream<List<Map<String, dynamic>>> caretakers() {
    return _client.from('caretakers')
      .select()
      .order('name')
      .asStream();
  }

  // Stream goats table
  static Stream<List<Map<String, dynamic>>> goats() {
    return _client.from('goats')
      .select('''
        *,
        caretakers (
          name,
          phone,
          location,
          payment_terms
        )
      ''')
      .order('birth_date', ascending: false)
      .asStream();
  }

  // Get finance data for CSV export
  static Future<List<Map<String, dynamic>>> getFinanceData() {
    return _client.from('v_goat_financials').select();
  }

  // Get expense summary by category
  static Stream<List<Map<String, dynamic>>> expenseSummary() {
    return _client.from('expenses')
      .select('type, amount')
      .asStream()
      .map((data) {
        final Map<String, Map<String, dynamic>> summary = {};
        for (final expense in data) {
          final type = expense['type'] as String? ?? 'Other';
          final amount = expense['amount'] != null ? (expense['amount'] as num).toDouble() : 0.0;
          if (!summary.containsKey(type)) {
            summary[type] = {'total': 0.0, 'count': 0};
          }
          summary[type]!['total'] = (summary[type]!['total'] as double) + amount;
          summary[type]!['count'] = (summary[type]!['count'] as int) + 1;
        }
        return summary.entries.map((e) => {
          'type': e.key,
          'total': e.value['total'],
          'count': e.value['count']
        }).toList();
      });
  }

  // Financial summary stream
  static Stream<Map<String, dynamic>> financeSummary() {
    return _client.from('v_goat_financials')
      .select()
      .asStream()
      .map((rows) {
        double invested = 0, sales = 0, exp = 0, profit = 0;
        for (var r in rows) {
          final price = r['price'];
          final salePrice = r['sale_price'];
          final totalExpense = r['total_expense'];

          invested += price != null ? (price as num).toDouble() : 0;
          sales += salePrice != null ? (salePrice as num).toDouble() : 0;
          exp += totalExpense != null ? (totalExpense as num).toDouble() : 0;
          profit = sales - (invested + exp);
        }
        return {
          'invested': invested,
          'sales': sales,
          'expense': exp,
          'profit': profit,
          'count': rows.length
        };
      });
  }

  // Add a caretaker
  static Future<void> addCaretaker({
    required String name,
    String? phone,
    String? loc,
    String? payment,
  }) async {
    await _client.from('caretakers').insert({
      'name': name,
      'phone': phone,
      'location': loc,
      'payment_terms': payment,
      'user_id': _client.auth.currentUser!.id,
    });
  }

  // Add an expense
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

  // Sell a goat
  static Future<void> sellGoat(String id, double price) async {
    try {
      final record = await _client.from('sales').insert({
        'goat_id': id,
        'sale_price': price,
        'sale_date': DateTime.now().toIso8601String(),
      }).select().single();

      await _client.from('goats').update({'status': 'sold'}).eq('id', id);

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

  // Weight tracking methods
  static Future<void> addWeight(String goatId, double kg) async {
    await _client.from('weight_logs').insert({
      'goat_id': goatId,
      'weight': kg,
      'date': DateTime.now().toIso8601String(),
    });
  }

  static Stream<List<Map<String, dynamic>>> weightStream(String goatId) {
    return _client.from('weight_logs')
      .select()
      .eq('goat_id', goatId)
      .order('date')
      .asStream();
  }

  // QR/NFC scan methods
  static Future<void> addScan({
    required String goatId,
    required String scanType,
    required String location,
    String? notes
  }) async {
    await _client.from('scans').insert({
      'goat_id': goatId,
      'scan_type': scanType,
      'location': location,
      'notes': notes,
      'scanned_at': DateTime.now().toIso8601String()
    });
  }

  static Stream<List<Map<String, dynamic>>> scanHistory(String goatId) {
    return _client.from('scans')
      .select()
      .eq('goat_id', goatId)
      .order('scanned_at', ascending: false)
      .asStream();
  }

  // Helper method to get a signed URL for a photo
  static Future<String> getSignedUrl(String? fileName) async {
    if (fileName == null) return '';
    try {
      final signedUrl = await _bucket.createSignedUrl(fileName, 3600); // 1 hour expiry
      return signedUrl;
    } catch (e) {
      print('Error getting signed URL: $e');
      return '';
    }
  }
}