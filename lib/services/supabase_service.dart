import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:goat_tracker/models/expense_summary.dart';
import 'package:goat_tracker/models/financial_summary.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/caretaker.dart';
import 'package:goat_tracker/models/weight.dart';
import 'package:goat_tracker/models/sale.dart';
import 'package:goat_tracker/models/goat_birth.dart';
import 'package:goat_tracker/services/supabase_error.dart';

class SupabaseService {
  static final _instance = SupabaseService._();
  final _client = Supabase.instance.client;
  final _bucket = Supabase.instance.client.storage.from('goat-photos');

  SupabaseService._();

  factory SupabaseService() {
    return _instance;
  }



  // Add a new goat with photo upload
  Future<void> addGoat({
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



  // Get expenses summary for a date range
  Future<ExpenseSummary> getExpensesSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw SupabaseError('User not authenticated');
    }

    try {
      final response = await _client.rpc(
        'calculate_expenses_summary',
        params: {
          'p_user_id': userId,
          'p_start_date': startDate?.toIso8601String(),
          'p_end_date': endDate?.toIso8601String(),
        },
      );

      return ExpenseSummary.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw SupabaseError('Failed to get expenses summary', e);
    }
  }

  // Get goat count by status
  Stream<Map<String, int>> goatCount() {
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
  Stream<List<Map<String, dynamic>>> caretakerSummary() {
    return _client.from('v_caretaker_summary')
      .select()
      .asStream()
      .map((rows) {
        final summaries = <Map<String, dynamic>>[];
        for (final row in rows) {
          summaries.add({
            'id': row['id'] as String,
            'name': row['name'] as String,
            'phone': row['phone'] as String?,
            'location': row['location'] as String?,
            'profit_share': (row['profit_share'] as num?)?.toDouble() ?? 0,
            'total_goats': (row['total_goats'] as int?) ?? 0,
            'total_investment': (row['total_investment'] as num?)?.toDouble() ?? 0,
            'total_expenses': (row['total_expenses'] as num?)?.toDouble() ?? 0,
            'profit_share_amount': (row['profit_share_amount'] as num?)?.toDouble() ?? 0,
          });
        }
        return summaries;
      });
  }

  // Generate QR Code URL for a goat
  String generateGoatQrUrl(String goatId) {
    final baseUrl = const String.fromEnvironment('GOAT_TRACKER_URL', 
      defaultValue: 'https://goat-tracker.app');
    return '$baseUrl/goat/$goatId';
  }
  
  // Record goat weight
  Future<void> recordGoatWeight(String goatId, double weightKg) async {
    try {
      await _client.from('weights').insert({
        'goat_id': goatId,
        'weight_kg': weightKg,
        'recorded_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw SupabaseError('Failed to record goat weight', e);
    }
  }

  // Get weight history for a goat
  Future<List<Weight>> getGoatWeightHistory(String goatId) async {
    try {
      final response = await _client.from('weights')
          .select()
          .eq('goat_id', goatId)
          .order('recorded_at', ascending: false);
      
      return (response as List)
          .map((json) => Weight.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw SupabaseError('Failed to get goat weight history', e);
    }
  }

  // Transfer goat to new caretaker
  Future<void> transferGoat(String goatId, String newCaretakerId) async {
    try {
      await _client.from('goats')
          .update({'caretaker_id': newCaretakerId})
          .eq('id', goatId);
    } catch (e) {
      throw SupabaseError('Failed to transfer goat', e);
    }
  }

  // Get caretaker's current goats
  Future<List<Goat>> getCaretakerGoats(String caretakerId) async {
    try {
      final response = await _client.from('goats')
          .select()
          .eq('caretaker_id', caretakerId)
          .eq('status', 'active');
      
      return (response as List)
          .map((json) => Goat.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw SupabaseError('Failed to get caretaker goats', e);
    }
  }

  // Calculate caretaker earnings
  Future<Map<String, dynamic>> calculateCaretakerEarnings(String caretakerId) async {
    try {
      final response = await _client.rpc(
        'calculate_caretaker_payment',
        params: {'p_caretaker_id': caretakerId}
      );
      
      return response as Map<String, dynamic>;
    } catch (e) {
      throw SupabaseError('Failed to calculate caretaker earnings', e);
    }
  }

  // Financial summary stream
  Stream<FinancialSummary> financeSummary() async* {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw SupabaseError('User not authenticated');
    }
    
    try {
      while (true) {
        final response = await _client.rpc(
          'calculate_financial_summary',
          params: {'p_user_id': userId}
        );
        
        if (response == null) {
          throw SupabaseError('Failed to get financial summary: null response');
        }
        
        final summary = FinancialSummary.fromJson(response as Map<String, dynamic>);
        yield summary;
        
        // Wait before next update
        await Future.delayed(const Duration(seconds: 30));
      }
    } catch (e) {
      throw SupabaseError('Failed to stream financial summary', e);
    }
  }

  // Add a caretaker
  Future<void> addCaretaker({
    required String name,
    String? phone,
    String? location,
    required String paymentType,
    double? profitSharePct,
    double? monthlyFee,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw SupabaseError('User not authenticated');
    }

    try {
      if (paymentType != 'fixed' && paymentType != 'share') {
        throw SupabaseError('Invalid payment type. Must be either "fixed" or "share"');
      }

      if (paymentType == 'share' && profitSharePct == null) {
        throw SupabaseError('Profit share percentage is required for share-based payment');
      }

      if (paymentType == 'fixed' && monthlyFee == null) {
        throw SupabaseError('Monthly fee is required for fixed payment');
      }

      await _client.from('caretakers').insert({
        'name': name,
        'phone': phone,
        'location': location,
        'payment_type': paymentType,
        'profit_share_pct': profitSharePct,
        'monthly_fee': monthlyFee,
        'notes': notes,
        'user_id': userId,
      });
    } catch (e) {
      throw SupabaseError('Failed to add caretaker', e);
    }
  }

  // Add an expense
  Future<void> addExpense({
    String? goatId,
    required double amount,
    required String type,
    String? notes,
    DateTime? date,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw SupabaseError('User not authenticated');
    }

    try {
      if (!['feed', 'medicine', 'transport', 'other'].contains(type)) {
        throw SupabaseError('Invalid expense type');
      }

      final record = await _client.from('expenses').insert({
        'goat_id': goatId,
        'amount': amount,
        'type': type,
        'notes': notes,
        'date': (date ?? DateTime.now()).toIso8601String(),
        'user_id': userId,
      }).select().single();
    
      // Create notification
      await _client.from('notifications').insert({
        'message': 'New expense of ₹$amount added ${goatId != null ? 'for goat $goatId' : ''}',
        'type': 'expense',
        'record_id': record['id'],
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
        'user_id': userId
      });
    } catch (e) {
      throw SupabaseError('Failed to add expense', e);
    }
  }
  // Record a sale
  Future<void> sellGoat(String id, double salePrice, {String? buyerName, String? notes}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw SupabaseError('User not authenticated');
    }

    try {
      await _client.rpc('record_goat_sale', params: {
        'p_goat_id': id,
        'p_sale_price': salePrice,
        'p_buyer_name': buyerName,
        'p_payment_mode': 'cash', // Default to cash, can be parameterized later
        'p_notes': notes,
        'p_user_id': userId,
      });
    } catch (e) {
      throw SupabaseError('Failed to record sale', e);
    }
  }

  // Record goat weight
  Future<void> recordWeight(String goatId, double weightKg) async {
    try {
      await _client.from('weights').insert({
        'goat_id': goatId,
        'weight_kg': weightKg,
        'recorded_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw SupabaseError('Failed to record weight', e);
    }
  }

  // Get weight history for a goat
  Future<List<Weight>> getWeightHistory(String goatId) async {
    try {
      final response = await _client.from('weights')
          .select()
          .eq('goat_id', goatId)
          .order('recorded_at', ascending: false);
      
      return (response as List)
          .map((json) => Weight.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw SupabaseError('Failed to get weight history', e);
    }
  }

  // Helper method to get a signed URL for a photo
  Future<String> getSignedUrl(String? fileName) async {
    if (fileName == null) return '';
    try {
      final signedUrl = await _bucket.createSignedUrl(fileName, 3600); // 1 hour expiry
      return signedUrl;
    } catch (e) {
      throw SupabaseError('Failed to get signed URL', e);
    }
  }
  
  // Stream of goats as typed objects
  Stream<List<Goat>> streamGoats() async* {
    try {
      await for (final data in _client.from('goats')
          .select('''
            *,
            caretakers(*)
          ''')
          .order('created_at', ascending: false)
          .asStream()) {
        yield data.map((json) => Goat.fromJson(json)).toList();
      }
    } catch (e) {
      throw SupabaseError('Failed to stream goats', e);
    }
  }

  // Stream of caretakers as typed objects
  Stream<List<Caretaker>> streamCaretakers() async* {
    try {
      await for (final data in _client.from('caretakers')
          .select()
          .order('name')
          .asStream()) {
        yield data.map((json) => Caretaker.fromJson(json)).toList();
      }
    } catch (e) {
      throw SupabaseError('Failed to stream caretakers', e);
    }
  }

  // Get goat details by ID
  Future<Goat> getGoatById(String id) async {
    try {
      final response = await _client.from('goats')
          .select('''
            *,
            caretakers(*)
          ''')
          .eq('id', id)
          .single();
          
      return Goat.fromJson(response);
    } catch (e) {
      throw SupabaseError('Failed to get goat details', e);
    }
  }

  // Get caretaker details by ID
  Future<Caretaker> getCaretakerById(String id) async {
    try {
      final response = await _client.from('caretakers')
          .select()
          .eq('id', id)
          .single();
          
      return Caretaker.fromJson(response);
    } catch (e) {
      throw SupabaseError('Failed to get caretaker details', e);
    }
  }
}