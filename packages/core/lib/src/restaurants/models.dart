import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

/// Restaurant partenaire (RES-01, RES-02). `isOpen` est calculé par le serveur (horaires, fermeture temporaire).
@freezed
abstract class Restaurant with _$Restaurant {
  const factory Restaurant({
    required String id,
    required String zoneId,
    required String name,
    String? description,
    String? category,
    String? coverPath,
    required String phone,
    required double latitude,
    required double longitude,
    required String district,
    required String landmark,
    @Default(15) double commissionRate,
    @Default(20) int prepTimeMin,
    @Default(true) bool isActive,
    @Default(false) bool isTemporarilyClosed,
    @Default(false) bool isOpen,
  }) = _Restaurant;

  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);
}

/// Plage d'ouverture, heure locale de la zone ; jour ISO (1 = lundi … 7 = dimanche).
@freezed
abstract class OpeningHour with _$OpeningHour {
  const factory OpeningHour({
    required int weekday,
    required String opensAt,
    required String closesAt,
  }) = _OpeningHour;

  factory OpeningHour.fromJson(Map<String, dynamic> json) =>
      _$OpeningHourFromJson(json);
}

@freezed
abstract class MenuCategory with _$MenuCategory {
  const factory MenuCategory({
    required String id,
    required String name,
    @Default(0) int position,
  }) = _MenuCategory;

  factory MenuCategory.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryFromJson(json);
}

@freezed
abstract class Product with _$Product {
  const factory Product({
    String? id,
    required String restaurantId,
    String? categoryId,
    required String name,
    String? description,
    required int price,
    String? photoPath,
    @Default(true) bool isAvailable,
    DateTime? archivedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
