import 'breeding_record.dart';
import 'health_record.dart';
import 'notification.dart' as goat_notification;
import 'weight_log.dart';

enum GoatStatus {
  active,
  sold,
  dead
}

enum GoatGender {
  male,
  female,
  unknown
}

class Goat {
  final String id;
  final String tagNumber;
  final double price;
  final DateTime birthDate;
  final List<String> photoUrls;
  final String caretakerId;
  final String userId;
  final String name;
  final GoatGender gender;
  final GoatStatus status;
  final DateTime createdAt;
  final double? salePrice;
  final DateTime? saleDate;
  final String? buyerName;
  final String? buyerContact;
  final String? reasonForSale;
  final double? totalExpense;
  final double? profit;
  final String breed;
  final String? color;
  final String? markings;
  final String qrCode;
  final DateTime? purchaseDate;
  final String? vendorName;
  final String? vendorContact;
  final String? parentSireId;
  final String? parentDamId;
  final List<Map<String, dynamic>> statusLog;
  final double? lastWeightKg;
  final List<WeightLog> weightLogs;
  final List<HealthRecord> healthRecords;
  final List<BreedingRecord> breedingRecords;
  final List<goat_notification.Notification> notifications;

  const Goat({
    required this.id,
    required this.tagNumber,
    required this.price,
    required this.birthDate,
    required this.photoUrls,
    required this.caretakerId,
    required this.userId,
    required this.name,
    this.gender = GoatGender.unknown,
    this.status = GoatStatus.active,
    required this.createdAt,
    this.salePrice,
    this.saleDate,
    this.buyerName,
    this.buyerContact,
    this.reasonForSale,
    this.totalExpense,
    this.profit,
    required this.breed,
    this.color,
    this.markings,
    required this.qrCode,
    this.purchaseDate,
    this.vendorName,
    this.vendorContact,
    this.parentSireId,
    this.parentDamId,
    required this.statusLog,
    this.lastWeightKg,
    this.weightLogs = const [],
    this.healthRecords = const [],
    this.breedingRecords = const [],
    this.notifications = const [],
  });

  factory Goat.fromJson(Map<String, dynamic> json) {
    return Goat(
      id: json['id'] as String,
      tagNumber: json['tag_number'] as String,
      price: (json['price'] as num).toDouble(),
      birthDate: DateTime.parse(json['birth_date'] as String),
      photoUrls: (json['photo_urls'] as List?)?.cast<String>() ?? const [],
      caretakerId: json['caretaker_id'] as String? ?? '',
      userId: json['user_id'] as String,
      name: json['name'] as String,
      gender: GoatGender.values.firstWhere(
        (e) => e.name.toLowerCase() == ((json['gender'] as String?)?.toLowerCase() ?? 'unknown'),
        orElse: () => GoatGender.unknown,
      ),
      status: GoatStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == ((json['status'] as String?)?.toLowerCase() ?? 'active'),
        orElse: () => GoatStatus.active,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      salePrice: json['sale_price'] == null ? null : (json['sale_price'] as num).toDouble(),
      saleDate: json['sale_date'] == null ? null : DateTime.parse(json['sale_date'] as String),
      buyerName: json['buyer_name'] as String?,
      buyerContact: json['buyer_contact'] as String?,
      reasonForSale: json['reason_for_sale'] as String?,
      totalExpense: json['total_expense'] == null ? null : (json['total_expense'] as num).toDouble(),
      profit: json['profit'] == null ? null : (json['profit'] as num).toDouble(),
      breed: json['breed'] as String? ?? 'Unknown',
      color: json['color'] as String?,
      markings: json['markings'] as String?,
      qrCode: json['qr_code'] as String? ?? '',
      purchaseDate: json['purchase_date'] == null ? null : DateTime.parse(json['purchase_date'] as String),
      vendorName: json['vendor_name'] as String?,
      vendorContact: json['vendor_contact'] as String?,
      parentSireId: json['parent_sire_id'] as String?,
      parentDamId: json['parent_dam_id'] as String?,
      statusLog: (json['status_log'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? const [],
      lastWeightKg: json['last_weight_kg'] == null ? null : (json['last_weight_kg'] as num).toDouble(),
      weightLogs: (json['weight_logs'] as List?)
          ?.map((e) => WeightLog.fromJson(e as Map<String, dynamic>))
          .toList() ?? const [],
      healthRecords: (json['health_records'] as List?)
          ?.map((e) => HealthRecord.fromJson(e as Map<String, dynamic>))
          .toList() ?? const [],
      breedingRecords: (json['breeding_records'] as List?)
          ?.map((e) => BreedingRecord.fromJson(e as Map<String, dynamic>))
          .toList() ?? const [],
      notifications: (json['notifications'] as List?)
          ?.map((e) => goat_notification.Notification.fromJson(e as Map<String, dynamic>))
          .toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tag_number': tagNumber,
    'price': price,
    'birth_date': birthDate.toIso8601String(),
    'photo_urls': photoUrls,
    'caretaker_id': caretakerId,
    'user_id': userId,
    'name': name,
    'gender': gender.name,
    'status': status.name,
    'created_at': createdAt.toIso8601String(),
    'sale_price': salePrice,
    'sale_date': saleDate?.toIso8601String(),
    'buyer_name': buyerName,
    'buyer_contact': buyerContact,
    'reason_for_sale': reasonForSale,
    'total_expense': totalExpense,
    'profit': profit,
    'breed': breed,
    'color': color,
    'markings': markings,
    'qr_code': qrCode,
    'purchase_date': purchaseDate?.toIso8601String(),
    'vendor_name': vendorName,
    'vendor_contact': vendorContact,
    'parent_sire_id': parentSireId,
    'parent_dam_id': parentDamId,
    'status_log': statusLog,
    'last_weight_kg': lastWeightKg,
    'weight_logs': weightLogs.map((e) => e.toJson()).toList(),
    'health_records': healthRecords.map((e) => e.toJson()).toList(),
    'breeding_records': breedingRecords.map((e) => e.toJson()).toList(),
    'notifications': notifications.map((e) => e.toJson()).toList(),
  };
}
