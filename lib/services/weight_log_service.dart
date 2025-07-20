import 'package:goat_tracker/models/weight_log.dart';
import 'package:goat_tracker/services/base_service.dart';

class WeightLogService extends BaseService {
  static const String _tableName = 'weight_logs';

  Stream<List<WeightLog>> watchWeightLogs(String goatId) {
    return supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('goat_id', goatId)
        .order('measurement_date', ascending: false)
        .map((response) => response
            .map((json) => WeightLog.fromJson(json))
            .toList());
  }

  Future<List<WeightLog>> getWeightLogs(String goatId) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select()
          .eq('goat_id', goatId)
          .order('measurement_date', ascending: false);
      
      return (response as List)
          .map((json) => WeightLog.fromJson(json))
          .toList();
    }, 'fetching weight logs');
  }

  Future<WeightLog> addWeightLog({
    required String goatId,
    required double weightKg,
    required DateTime measurementDate,
    String? notes,
  }) async {
    return handleResponse(() async {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User must be authenticated to add a weight log');

      final weightLog = {
        'goat_id': goatId,
        'weight_kg': weightKg,
        'measurement_date': measurementDate.toIso8601String(),
        'notes': notes,
        'user_id': user.id,
      };

      final response = await supabase
          .from(_tableName)
          .insert(weightLog)
          .select()
          .single();
      
      // Update the goat's last weight
      await supabase
          .from('goats')
          .update({'last_weight_kg': weightKg})
          .eq('id', goatId);
      
      return WeightLog.fromJson(response);
    }, 'adding weight log');
  }

  Future<void> deleteWeightLog(String id) async {
    return handleResponse(() async {
      await supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    }, 'deleting weight log');
  }
}
