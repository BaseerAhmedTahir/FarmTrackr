import 'package:flutter_test/flutter_test.dart';

void main() {
  test('net profit formula', () {
    final r = {
      'purchase_price': 100.0,
      'total_expense': 20.0,
      'sale_price': 180.0
    };
    final purchasePrice = (r['purchase_price'] as num).toDouble();
    final totalExpense = (r['total_expense'] as num).toDouble();
    final salePrice = ((r['sale_price'] ?? 0) as num).toDouble();
    final profit = salePrice - purchasePrice - totalExpense;
    expect(profit, 60.0);
  });
}
