import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cart.g.dart';

@immutable
class CartLine {
  const CartLine({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.photoPath,
  });

  CartLine.of(Product product)
    : this(
        productId: product.id!,
        name: product.name,
        unitPrice: product.price,
        quantity: 1,
        photoPath: product.photoPath,
      );

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    productId: json['product_id'] as String,
    name: json['name'] as String,
    unitPrice: json['unit_price'] as int,
    quantity: json['quantity'] as int,
    photoPath: json['photo_path'] as String?,
  );

  final String productId;
  final String name;

  /// Prix affiché au moment de l'ajout ; le serveur recalcule tout au devis.
  final int unitPrice;
  final int quantity;
  final String? photoPath;

  int get lineTotal => unitPrice * quantity;

  CartLine withQuantity(int value) => CartLine(
    productId: productId,
    name: name,
    unitPrice: unitPrice,
    quantity: value,
    photoPath: photoPath,
  );

  Map<String, Object?> toJson() => {
    'product_id': productId,
    'name': name,
    'unit_price': unitPrice,
    'quantity': quantity,
    'photo_path': photoPath,
  };
}

/// Panier : un seul restaurant à la fois (ORD-05).
@immutable
class Cart {
  const Cart({
    required this.restaurantId,
    required this.restaurantName,
    required this.lines,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    restaurantId: json['restaurant_id'] as String,
    restaurantName: json['restaurant_name'] as String,
    lines: [
      for (final line in json['lines'] as List)
        CartLine.fromJson(line as Map<String, dynamic>),
    ],
  );

  final String restaurantId;
  final String restaurantName;
  final List<CartLine> lines;

  int get count => lines.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => lines.fold(0, (sum, line) => sum + line.lineTotal);

  int quantityOf(String productId) =>
      lines.where((l) => l.productId == productId).firstOrNull?.quantity ?? 0;

  Map<String, Object?> toJson() => {
    'restaurant_id': restaurantId,
    'restaurant_name': restaurantName,
    'lines': [for (final line in lines) line.toJson()],
  };
}

/// Panier conservé sur le téléphone entre deux ouvertures de l'app (ORD-05).
@Riverpod(keepAlive: true)
class CartController extends _$CartController {
  static const _key = 'cart';
  static const maxQuantity = 50;

  @override
  Future<Cart?> build() async {
    try {
      final saved = await SharedPreferencesAsync().getString(_key);
      return saved == null
          ? null
          : Cart.fromJson(jsonDecode(saved) as Map<String, dynamic>);
    } on Object {
      // Panier illisible (ancienne version) : on repart d'un panier vide.
      return null;
    }
  }

  Future<void> _save(Cart? cart) async {
    final value = cart == null || cart.lines.isEmpty ? null : cart;
    state = AsyncData(value);
    final prefs = SharedPreferencesAsync();
    await (value == null
        ? prefs.remove(_key)
        : prefs.setString(_key, jsonEncode(value.toJson())));
  }

  /// Faux si le panier contient déjà un autre restaurant : l'interface demande alors de le vider ([replaceWith]).
  bool add(Restaurant restaurant, Product product) {
    final cart = state.value;
    if (cart != null && cart.restaurantId != restaurant.id) return false;
    final current = cart?.quantityOf(product.id!) ?? 0;
    if (current == 0) {
      _save(
        Cart(
          restaurantId: restaurant.id,
          restaurantName: restaurant.name,
          lines: [...?cart?.lines, CartLine.of(product)],
        ),
      );
    } else {
      setQuantity(product.id!, current + 1);
    }
    return true;
  }

  void replaceWith(Restaurant restaurant, Product product) => _save(
    Cart(
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      lines: [CartLine.of(product)],
    ),
  );

  /// 0 retire le produit ; un panier vide disparaît.
  void setQuantity(String productId, int quantity) {
    final cart = state.value;
    if (cart == null) return;
    final value = quantity.clamp(0, maxQuantity);
    _save(
      Cart(
        restaurantId: cart.restaurantId,
        restaurantName: cart.restaurantName,
        lines: [
          for (final line in cart.lines)
            if (line.productId != productId)
              line
            else if (value > 0)
              line.withQuantity(value),
        ],
      ),
    );
  }

  void remove(Iterable<String> productIds) {
    final cart = state.value;
    if (cart == null) return;
    final ids = productIds.toSet();
    _save(
      Cart(
        restaurantId: cart.restaurantId,
        restaurantName: cart.restaurantName,
        lines: [
          for (final line in cart.lines)
            if (!ids.contains(line.productId)) line,
        ],
      ),
    );
  }

  void clear() => _save(null);
}
