import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/financial_summary.dart';
import 'package:goat_tracker/models/weight_log.dart';
import 'package:goat_tracker/services/base_service.dart';

class GoatService extends BaseService {
  static const String _tableName = 'goats';
  static const String _storageBucket = 'goat-photos';
  final _uuid = const Uuid();

  Stream<List<Goat>> watchGoats() {
    return supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('tag_number')
        .map((response) => response
            .map((json) => Goat.fromJson(json))
            .toList());
  }

  Future<List<Goat>> getAllGoats() async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select()
          .order('tag_number');
      
      return (response as List)
          .map((json) => Goat.fromJson(json))
          .toList();
    }, 'fetching all goats');
  }

  Stream<FinancialSummary> watchFinancialSummary() {
    return supabase
        .from('financial_summary')
        .stream(primaryKey: ['id'])
        .map((response) => response.isNotEmpty
            ? FinancialSummary.fromJson(response.first)
            : FinancialSummary.empty());
  }

  Stream<Goat> watchGoat(String id) {
    return supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((response) => response.isNotEmpty
            ? Goat.fromJson(response.first)
            : throw Exception('Goat not found'));
  }

  Future<Goat> getGoatById(String id) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return Goat.fromJson(response);
    }, 'fetching goat by ID');
  }

  Future<Goat> createGoat(Goat goat, File? photo) async {
    return handleResponse(() async {
      List<String> photoUrls = [];

      if (photo != null) {
        final photoUrl = await uploadGoatPhoto(photo, goat.id);
        photoUrls.add(photoUrl);
      }

      // Create goat record with URLs
      final response = await supabase.from(_tableName).insert({
        ...goat.toJson(),
        'photo_urls': photoUrls,
      }).select().single();

      return Goat.fromJson(response);
    }, 'creating goat');
  }

  Future<Goat> updateGoat(Goat goat, {File? newPhoto}) async {
    return handleResponse(() async {
      List<String> photoUrls = List.from(goat.photoUrls);
      
      if (newPhoto != null) {
        final newPhotoUrl = await uploadGoatPhoto(newPhoto, goat.id);
        photoUrls.add(newPhotoUrl);
      }

      final response = await supabase
          .from(_tableName)
          .update({
            ...goat.toJson(),
            'photo_urls': photoUrls,
          })
          .eq('id', goat.id)
          .select()
          .single();
      
      return Goat.fromJson(response);
    }, 'updating goat');
  }

  Future<void> deleteGoat(String id) async {
    return handleResponse(() async {
      final goat = await getGoatById(id);
      
      // Delete photos if they exist
      for (final photoUrl in goat.photoUrls) {
        final filePath = photoUrl.split('/').last;
        await supabase.storage.from(_storageBucket).remove(['photos/$filePath']);
      }

      await supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    }, 'deleting goat');
  }

  Future<String> uploadGoatPhoto(File photo, String goatId) async {
    return handleResponse(() async {
      final fileExt = photo.path.split('.').last;
      final fileName = '${_uuid.v4()}.$fileExt';
      final filePath = 'photos/$fileName';

      await supabase.storage.from(_storageBucket)
          .upload(filePath, photo);

      return supabase.storage
          .from(_storageBucket)
          .getPublicUrl(filePath);
    }, 'uploading goat photo');
  }

  Future<void> addWeight(String goatId, double weightKg) async {
    return handleResponse(() async {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User must be authenticated to add weight');

      final weightLog = {
        'goat_id': goatId,
        'weight_kg': weightKg,
        'measurement_date': DateTime.now().toIso8601String(),
        'user_id': user.id,
      };
      
      await supabase.from('weight_logs').insert(weightLog);
      await supabase
          .from(_tableName)
          .update({'last_weight_kg': weightKg})
          .eq('id', goatId);
    }, 'adding weight record');
  }

  Future<void> markAsSold(String goatId, double salePrice, String? buyerName, String? buyerContact, String? reasonForSale) async {
    return handleResponse(() async {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User must be authenticated to mark goat as sold');

      final now = DateTime.now();
      
      // Create sale record
      final sale = {
        'goat_id': goatId,
        'sale_price': salePrice,
        'sale_date': now.toIso8601String(),
        'buyer_name': buyerName,
        'buyer_contact': buyerContact,
        'notes': reasonForSale,
        'user_id': user.id,
      };

      await supabase.from('sales').insert(sale);

      // Update goat status
      await supabase
          .from(_tableName)
          .update({
            'status': GoatStatus.sold.name,
            'reason_for_sale': reasonForSale,
          })
          .eq('id', goatId);
    }, 'marking goat as sold');
  }

  Future<void> markAsDead(String goatId, {String? reason}) async {
    return handleResponse(() async {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User must be authenticated to update goat status');

      await supabase.rpc(
        'update_goat_status',
        params: {
          'goat_id': goatId,
          'new_status': GoatStatus.dead.name,
          'reason': reason,
        },
      );
    }, 'marking goat as dead');
  }
}
