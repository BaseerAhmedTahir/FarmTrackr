import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'purchase.freezed.dart';
part 'purchase.g.dart';

@freezed
class Purchase with _$Purchase {
  const factory Purchase({
    required String id,
    required String goatId,
    required DateTime purchaseDate,
    required double purchasePrice,
    String? vendorName,
    String? vendorContact,
    String? notes,
    required DateTime createdAt,
    required String userId,
  }) = _Purchase;

  factory Purchase.fromJson(Map<String, dynamic> json) => _$PurchaseFromJson(json);

  factory Purchase.create({
    required String goatId,
    required DateTime purchaseDate,
    required double purchasePrice,
    String? vendorName,
    String? vendorContact,
    String? notes,
    required String userId,
  }) {
    final now = DateTime.now();
    return Purchase(
      id: const Uuid().v4(),
      goatId: goatId,
      purchaseDate: purchaseDate,
      purchasePrice: purchasePrice,
      vendorName: vendorName,
      vendorContact: vendorContact,
      notes: notes,
      createdAt: now,
      userId: userId,
    );
  }
}
