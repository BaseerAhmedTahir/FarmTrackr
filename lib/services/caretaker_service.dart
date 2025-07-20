import 'package:goat_tracker/models/caretaker.dart';
import 'package:goat_tracker/services/base_service.dart';

class CaretakerService extends BaseService {
  static const String _tableName = 'caretakers';

  Stream<List<Caretaker>> watchCaretakers() {
    return supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('name')
        .map((response) => response
            .map((json) => Caretaker.fromJson(json))
            .toList());
  }

  Future<List<Caretaker>> getAllCaretakers() async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select()
          .order('name');
      
      return (response as List)
          .map((json) => Caretaker.fromJson(json))
          .toList();
    }, 'fetching all caretakers');
  }

  Future<Caretaker> getCaretakerById(String id) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return Caretaker.fromJson(response);
    }, 'fetching caretaker by ID');
  }

  Future<Caretaker> createCaretaker(Caretaker caretaker) async {
    return handleResponse(() async {
      final data = caretaker.toJson();
      // Remove ID and created_at from insert data
      data.remove('id');
      data.remove('created_at');
      
      final response = await supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();
      
      return Caretaker.fromJson(response);
    }, 'creating caretaker');
  }

  Future<Caretaker> updateCaretaker(Caretaker caretaker) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .update(caretaker.toJson())
          .eq('id', caretaker.id)
          .select()
          .single();
      
      return Caretaker.fromJson(response);
    }, 'updating caretaker');
  }

  Future<void> deleteCaretaker(String id) async {
    return handleResponse(() async {
      await supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    }, 'deleting caretaker');
  }

  Future<List<Map<String, dynamic>>> getCaretakerGoats(String caretakerId) async {
    return handleResponse(() async {
      final response = await supabase
          .from('goats')
          .select()
          .eq('caretaker_id', caretakerId);
      
      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    }, 'fetching caretaker goats');
  }

  Future<double> calculateCaretakerEarnings(
    String caretakerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return handleResponse(() async {
      final caretaker = await getCaretakerById(caretakerId);
      
      if (caretaker.paymentType == 'fixed') {
        // For fixed payment, calculate total monthly fees
        final months = endDate.difference(startDate).inDays / 30;
        return (caretaker.monthlyFee ?? 0) * months;
      } else {
        // For profit share, calculate share from sold goats
        final response = await supabase
            .from('goats')
            .select('sale_price, purchase_price, total_expense')
            .eq('caretaker_id', caretakerId)
            .eq('status', 'sold')
            .gte('sale_date', startDate.toIso8601String())
            .lte('sale_date', endDate.toIso8601String());

        double totalProfit = 0;
        for (final goat in response as List) {
          final salePrice = (goat['sale_price'] as num).toDouble();
          final purchasePrice = (goat['purchase_price'] as num).toDouble();
          final totalExpense = (goat['total_expense'] as num?)?.toDouble() ?? 0;
          final profit = salePrice - (purchasePrice + totalExpense);
          totalProfit += profit;
        }

        return totalProfit * (caretaker.profitSharePct ?? 0) / 100;
      }
    }, 'calculating caretaker earnings');
  }
}
