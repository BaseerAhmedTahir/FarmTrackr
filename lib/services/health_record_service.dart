import 'package:goat_tracker/models/health_record.dart';
import 'package:goat_tracker/services/base_service.dart';

class HealthRecordService extends BaseService {
  static const String _tableName = 'health_records';

  Stream<List<HealthRecord>> watchHealthRecords(String goatId) {
    return supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('goat_id', goatId)
        .order('record_date', ascending: false)
        .map((response) => response
            .map((json) => HealthRecord.fromJson(json))
            .toList());
  }

  Future<List<HealthRecord>> getHealthRecords(String goatId) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select()
          .eq('goat_id', goatId)
          .order('record_date', ascending: false);
      
      return (response as List)
          .map((json) => HealthRecord.fromJson(json))
          .toList();
    }, 'fetching health records');
  }

  Future<HealthRecord> addHealthRecord({
    required String goatId,
    required String recordType,
    required DateTime recordDate,
    String? diagnosis,
    String? treatment,
    String? medicine,
    String? dosage,
    DateTime? nextDueDate,
    String? vetName,
    String? vetContact,
    List<String>? attachments,
    String? notes,
  }) async {
    return handleResponse(() async {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User must be authenticated to add a health record');

      final healthRecord = {
        'goat_id': goatId,
        'record_type': recordType,
        'record_date': recordDate.toIso8601String(),
        'diagnosis': diagnosis,
        'treatment': treatment,
        'medicine': medicine,
        'dosage': dosage,
        'next_due_date': nextDueDate?.toIso8601String(),
        'vet_name': vetName,
        'vet_contact': vetContact,
        'attachments': attachments,
        'notes': notes,
        'user_id': user.id,
      };

      // If there's a next due date, create a notification
      if (nextDueDate != null) {
        final notification = {
          'goat_id': goatId,
          'type': recordType,
          'title': 'Medical Follow-up Due',
          'description': 'Follow-up required for ${treatment ?? medicine ?? recordType}',
          'due_date': nextDueDate.toIso8601String(),
          'user_id': user.id,
        };

        await supabase
            .from('notifications')
            .insert(notification);
      }

      final response = await supabase
          .from(_tableName)
          .insert(healthRecord)
          .select()
          .single();
      
      return HealthRecord.fromJson(response);
    }, 'adding health record');
  }

  Future<void> deleteHealthRecord(String id) async {
    return handleResponse(() async {
      await supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    }, 'deleting health record');
  }
}
