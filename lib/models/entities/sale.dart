import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'sale.freezed.dart';
part 'sale.g.dart';

@freezed
class Sale with _$Sale {
  const factory Sale({
    required String id,
    required String goatId,
    required DateTime saleDate,
    required double salePrice,
    String? buyerName,
    String? buyerContact,
    String? notes,
    required DateTime createdAt,
    required String userId,
  }) = _Sale;

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);

  factory Sale.create({
    required String goatId,
    required DateTime saleDate,
    required double salePrice,
    String? buyerName,
    String? buyerContact,
    String? notes,
    required String userId,
  }) {
    final now = DateTime.now();
    return Sale(
      id: const Uuid().v4(),
      goatId: goatId,
      saleDate: saleDate,
      salePrice: salePrice,
      buyerName: buyerName,
      buyerContact: buyerContact,
      notes: notes,
      createdAt: now,
      userId: userId,
    );
  }
}
