import 'package:goat_tracker/models/breeding_record.dart';
import 'package:goat_tracker/services/base_service.dart';

class BreedingRecordService extends BaseService {
  static const String _tableName = 'breeding_records';

  Stream<List<BreedingRecord>> watchBreedingRecords(String goatId) {
    return supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('dam_id', goatId)
        .order('mating_date', ascending: false)
        .map((response) => response
            .map((json) => BreedingRecord.fromJson(json))
            .toList());
  }

  Future<List<BreedingRecord>> getBreedingRecords(String goatId) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select()
          .eq('dam_id', goatId)
          .order('mating_date', ascending: false);
      
      return (response as List)
          .map((json) => BreedingRecord.fromJson(json))
          .toList();
    }, 'fetching breeding records');
  }

  Future<BreedingRecord> addBreedingRecord({
    required String damId,
    required String sireId,
    required DateTime matingDate,
    String? notes,
  }) async {
    return handleResponse(() async {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User must be authenticated to add a breeding record');

      // Calculate expected birth date (approximately 150 days after mating)
      final expectedBirthDate = matingDate.add(const Duration(days: 150));

      final breedingRecord = {
        'dam_id': damId,
        'sire_id': sireId,
        'mating_date': matingDate.toIso8601String(),
        'expected_birth_date': expectedBirthDate.toIso8601String(),
        'notes': notes,
        'user_id': user.id,
      };

      // Create a notification for the expected birth date
      final notification = {
        'goat_id': damId,
        'type': 'breeding',
        'title': 'Expected Birth Date',
        'description': 'Goat is expected to give birth',
        'due_date': expectedBirthDate.toIso8601String(),
        'user_id': user.id,
      };

      await supabase
          .from('notifications')
          .insert(notification);

      final response = await supabase
          .from(_tableName)
          .insert(breedingRecord)
          .select()
          .single();
      
      return BreedingRecord.fromJson(response);
    }, 'adding breeding record');
  }

  Future<BreedingRecord> updateBreedingRecord(
    String id, {
    DateTime? actualBirthDate,
    int? numberOfKids,
    Map<String, dynamic>? kidsDetail,
    String? notes,
  }) async {
    return handleResponse(() async {
      final updates = {
        if (actualBirthDate != null) 'actual_birth_date': actualBirthDate.toIso8601String(),
        if (numberOfKids != null) 'number_of_kids': numberOfKids,
        if (kidsDetail != null) 'kids_detail': kidsDetail,
        if (notes != null) 'notes': notes,
      };

      final response = await supabase
          .from(_tableName)
          .update(updates)
          .eq('id', id)
          .select()
          .single();
      
      return BreedingRecord.fromJson(response);
    }, 'updating breeding record');
  }

  Future<void> deleteBreedingRecord(String id) async {
    return handleResponse(() async {
      await supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    }, 'deleting breeding record');
  }
}
