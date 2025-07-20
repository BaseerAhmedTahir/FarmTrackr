import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/weight_record.dart';
import 'package:goat_tracker/models/financial_summary.dart';
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
      String? photoUrl;
      String qrUrl;

      if (photo != null) {
        photoUrl = await uploadGoatPhoto(photo, goat.id);
      }

      // Generate QR code URL
      qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=goat:${goat.tagNumber}';

      // Create goat record with URLs
      final response = await supabase.from(_tableName).insert({
        ...goat.toJson(),
        'qr_url': qrUrl,
        'photo_url': photoUrl,
      }).select().single();

      return Goat.fromJson(response);
    }, 'creating goat');
  }

  Future<Goat> updateGoat(Goat goat, {File? newPhoto}) async {
    return handleResponse(() async {
      String? photoUrl = goat.photoUrl;
      
      if (newPhoto != null) {
        photoUrl = await uploadGoatPhoto(newPhoto, goat.id);
      }

      final response = await supabase
          .from(_tableName)
          .update({
            ...goat.toJson(),
            'photo_url': photoUrl,
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
      
      // Delete photo if exists
      final filePath = goat.photoUrl.split('/').last;
      await supabase.storage.from(_storageBucket).remove(['photos/$filePath']);

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

  Future<void> addWeight(String goatId, double weight) async {
    return handleResponse(() async {
      final goat = await getGoatById(goatId);
      final weightRecord = WeightRecord(
        weight: weight,
        date: DateTime.now(),
        goatId: goatId,
      );
      final updatedHistory = [...goat.weightHistory, weightRecord];
      
      await supabase
          .from(_tableName)
          .update({'weight_history': updatedHistory.map((w) => w.toJson()).toList()})
          .eq('id', goatId);
    }, 'adding weight record');
  }

  Future<void> markAsSold(String goatId, double salePrice, String? buyerInfo) async {
    return handleResponse(() async {
      final now = DateTime.now();
      await supabase
          .from(_tableName)
          .update({
            'status': GoatStatus.sold.name,
            'sale_price': salePrice,
            'sale_date': now.toIso8601String(),
            'buyer_info': buyerInfo,
          })
          .eq('id', goatId);
    }, 'marking goat as sold');
  }

  Future<void> markAsDead(String goatId) async {
    return handleResponse(() async {
      await supabase
          .from(_tableName)
          .update({'status': GoatStatus.dead.name})
          .eq('id', goatId);
    }, 'marking goat as dead');
  }
}
