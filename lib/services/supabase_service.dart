import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:goat_tracker/models/expense_summary.dart';
import 'package:goat_tracker/models/expense_summary.dart';

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

  // For notification methods, use NotificationService from notification_service.dart

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

  // Get expense summary by month
  static Stream<List<ExpenseSummary>> expenseSummary() {
    return _client.from('expenses')
      .select('date, amount')
      .order('date')
      .asStream()
      .map((data) {
        final Map<String, double> monthlySummary = {};
        
        for (var expense in data) {
          final date = DateTime.parse(expense['date']);
          final month = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          final amount = expense['amount'].toDouble();
          
          monthlySummary[month] = (monthlySummary[month] ?? 0) + amount;
        }
        
        return monthlySummary.entries.map((e) {
          return ExpenseSummary(month: e.key, amount: e.value);
        }).toList();

      });
  }

  // Get goat count by status
  static Stream<Map<String, int>> goatCount() {
    return _client.from('goats')
      .select('status')
      .asStream()
      .map((rows) {
        final counts = <String, int>{
          'total': rows.length,
          'active': 0,
          'sold': 0,
          'deceased': 0,
        };
        for (final row in rows) {
          final status = row['status'] as String? ?? 'active';
          counts[status] = (counts[status] ?? 0) + 1;
        }
        return counts;
      });
  }

  // Get caretaker summary with their goats and profit share
  static Stream<List<Map<String, dynamic>>> caretakerSummary() {
    return _client.from('v_caretaker_summary')
      .select()
      .asStream()
      .map((rows) {
        final summaries = <Map<String, dynamic>>[];
        for (final row in rows) {
          summaries.add({
            'id': row['id'] as String,
            'name': row['name'] as String,
            'goat_count': row['goat_count'] as int,
            'total_investment': (row['total_investment'] as num?)?.toDouble() ?? 0,
            'total_expenses': (row['total_expenses'] as num?)?.toDouble() ?? 0,
            'total_sales': (row['total_sales'] as num?)?.toDouble() ?? 0,
            'profit_share': (row['profit_share'] as num?)?.toDouble() ?? 0,
          });
        }
        return summaries;
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

          final currentPrice = price != null ? (price as num).toDouble() : 0;
          final currentSale = salePrice != null ? (salePrice as num).toDouble() : 0;
          final currentExpense = totalExpense != null ? (totalExpense as num).toDouble() : 0;
          
          invested += currentPrice;
          sales += currentSale;
          exp += currentExpense;
          
          // Calculate profit: Sale Price - (Purchase Price + Expenses)
          if (currentSale > 0) { // Only calculate profit for sold goats
            profit += currentSale - (currentPrice + currentExpense);
          }
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
  static Future<void> sellGoat(String id, double price, {String? buyerInfo}) async {
    try {
      final record = await _client.from('sales').insert({
        'goat_id': id,
        'sale_price': price,
        'sale_date': DateTime.now().toIso8601String(),
        'buyer_info': buyerInfo,
      }).select().single();

      await _client.from('goats').update({'status': 'sold'}).eq('id', id);

      // Calculate profit and update caretaker's share
      final goat = await _client.from('v_goat_financials')
        .select()
        .eq('id', id)
        .single();
      
      final purchasePrice = (goat['price'] as num).toDouble();
      final totalExpense = (goat['total_expense'] as num?)?.toDouble() ?? 0;
      final profit = price - (purchasePrice + totalExpense);
      
      if (profit > 0) {
        final caretaker = await _client.from('caretakers')
          .select()
          .eq('id', goat['caretaker_id'])
          .single();
        
        final profitShare = (caretaker['profit_share'] as num).toDouble();
        final caretakerAmount = profit * (profitShare / 100);
        
        await _client.from('caretaker_payments').insert({
          'caretaker_id': goat['caretaker_id'],
          'goat_id': id,
          'amount': caretakerAmount,
          'sale_id': record['id'],
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      await _client.from('notifications').insert({
        'message': 'Goat $id was sold for ₹$price with profit of ₹${profit.toStringAsFixed(2)}',
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

  // Sync data by refreshing all tables
  static Future<void> syncData() async {
    await Future.wait([
      _client.from('expenses').select().limit(1),
      _client.from('goats').select().limit(1),
      _client.from('caretakers').select().limit(1),
    ]);
  }

  // Export data for CSV
  static Future<List<List<dynamic>>> exportData() async {
    final finance = await getFinanceData();
    final expenses = await _client.from('expenses').select();
    final goats = await _client.from('goats').select();
    final caretakers = await _client.from('caretakers').select();

    // Convert data to CSV format
    return [
      // Headers
      ['Type', 'Date', 'Amount', 'Description'],
      
      // Finance data
      ...finance.map((f) => [
        'Finance',
        f['date'],
        f['amount'],
        f['description'] ?? '',
      ]),

      // Expenses data
      ...expenses.map((e) => [
        'Expense',
        e['date'],
        e['amount'],
        e['description'] ?? '',
      ]),

      // Goats data
      ...goats.map((g) => [
        'Goat',
        g['purchased_at'],
        g['purchase_price'],
        'Tag: ${g['tag_id']}',
      ]),

      // Caretakers data
      ...caretakers.map((c) => [
        'Caretaker',
        c['joined_at'],
        c['salary'],
        c['name'],
      ]),
    ];
  }
}