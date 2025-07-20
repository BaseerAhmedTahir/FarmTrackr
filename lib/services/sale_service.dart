import 'package:goat_tracker/models/sale.dart';
import 'package:goat_tracker/services/base_service.dart';

class SaleService extends BaseService {
  static const String _tableName = 'sales';

  Stream<List<Sale>> watchSales() {
    return supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('sale_date', ascending: false)
        .map((response) => response
            .map((json) => Sale.fromJson(json))
            .toList());
  }

  Future<List<Sale>> getAllSales() async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select('*, goats(*)')
          .order('sale_date', ascending: false);
      
      return (response as List)
          .map((json) => Sale.fromJson(json))
          .toList();
    }, 'fetching all sales');
  }

  Future<Sale> getSaleById(String id) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select('*, goats(*)')
          .eq('id', id)
          .single();
      
      return Sale.fromJson(response);
    }, 'fetching sale by ID');
  }

  Future<Sale> createSale({
    required String goatId,
    required double salePrice,
    required DateTime saleDate,
    String? buyerName,
    String? buyerContact,
    String? notes,
  }) async {
    return handleResponse(() async {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User must be authenticated to create a sale');

      final sale = {
        'goat_id': goatId,
        'user_id': user.id,
        'sale_price': salePrice,
        'sale_date': saleDate.toIso8601String(),
        'buyer_name': buyerName,
        'buyer_contact': buyerContact,
        'notes': notes,
      };

      final response = await supabase
          .from(_tableName)
          .insert(sale)
          .select()
          .single();
      
      // Update goat status to sold
      await supabase
          .from('goats')
          .update({
            'status': 'sold',
          })
          .eq('id', goatId);
      
      return Sale.fromJson(response);
    }, 'creating sale');
  }

  Future<Sale> updateSale(Sale sale) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .update(sale.toJson())
          .eq('id', sale.id)
          .select()
          .single();
      
      // Update goat status to sold
      await supabase
          .from('goats')
          .update({
            'status': 'sold',
            'buyer_info': sale.buyerName,
          })
          .eq('id', sale.goatId);
      
      return Sale.fromJson(response);
    }, 'updating sale');
  }

  Future<void> deleteSale(String id) async {
    return handleResponse(() async {
      final sale = await getSaleById(id);
      
      await supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
      
      // Update goat status back to unsold
      await supabase
          .from('goats')
          .update({
            'status': 'unsold',
            'sale_price': null,
            'sale_date': null,
            'buyer_info': null,
          })
          .eq('id', sale.goatId);
    }, 'deleting sale');
  }

  Future<Map<String, dynamic>> getSalesSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select('sale_price, goats!inner(purchase_price, total_expense)')
          .gte('sale_date', startDate.toIso8601String())
          .lte('sale_date', endDate.toIso8601String());
      
      final sales = response as List;
      double totalRevenue = 0;
      double totalCost = 0;
      double totalProfit = 0;
      
      for (final sale in sales) {
        final price = (sale['sale_price'] as num).toDouble();
        final goat = sale['goats'] as Map<String, dynamic>;
        final purchasePrice = (goat['purchase_price'] as num).toDouble();
        final totalExpense = (goat['total_expense'] as num?)?.toDouble() ?? 0;
        
        totalRevenue += price;
        totalCost += (purchasePrice + totalExpense);
        totalProfit += (price - (purchasePrice + totalExpense));
      }
      
      return {
        'totalSales': sales.length,
        'totalRevenue': totalRevenue,
        'totalCost': totalCost,
        'totalProfit': totalProfit,
      };
    }, 'fetching sales summary');
  }
}
