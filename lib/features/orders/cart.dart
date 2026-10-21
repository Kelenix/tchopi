import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cart.g.dart';

/// Option choisie pour un produit (taille, supplément…).
typedef ChosenOption = ({String id, String name, int priceDelta});

@immutable
class CartLine {
  const CartLine({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.photoPath,
    this.optionIds = const [],
  });

  /// [options] : choix faits (taille, suppléments) ; ajoutés au nom et au prix affichés.
  CartLine.of(Product product, {List<ChosenOption> options = const []})
    : this(
        productId: product.id!,
        name: options.isEmpty
            ? product.name
            : '${product.name} (${options.map((o) => o.name).join(', ')})',
        unitPrice:
            product.price +
            options.fold<int>(0, (sum, o) => sum + o.priceDelta),
        quantity: 1,
        photoPath: product.photoPath,
        optionIds: [for (final o in options) o.id]..sort(),
      );

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    productId: json['product_id'] as String,
    name: json['name'] as String,
    unitPrice: json['unit_price'] as int,
    quantity: json['quantity'] as int,
    photoPath: json['photo_path'] as String?,
    optionIds: [
      for (final id in json['options'] as List? ?? const []) id as String,
    ],
  );

  final String productId;
  final String name;

  /// Prix affiché au moment de l'ajout ; le serveur recalcule tout au devis.
  final int unitPrice;
  final int quantity;
  final String? photoPath;

  /// Options choisies (identifiants triés), envoyées au serveur qui recalcule le prix.
  final List<String> optionIds;

  /// Une ligne par produit et par combinaison d'options.
  String get key => [productId, ...optionIds].join('+');

  int get lineTotal => unitPrice * quantity;

  CartLine withQuantity(int value) => CartLine(
    productId: productId,
    name: name,
    unitPrice: unitPrice,
    quantity: value,
    photoPath: photoPath,
    optionIds: optionIds,
  );

  Map<String, Object?> toJson() => {
    'product_id': productId,
    'name': name,
    'unit_price': unitPrice,
    'quantity': quantity,
    'photo_path': photoPath,
    'options': optionIds,
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

  /// Quantité d'un produit, toutes options confondues.
  int quantityOf(String productId) => lines
      .where((l) => l.productId == productId)
      .fold(0, (sum, l) => sum + l.quantity);

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
  bool add(
    Restaurant restaurant,
    Product product, {
    List<ChosenOption> options = const [],
  }) {
    final cart = state.value;
    if (cart != null && cart.restaurantId != restaurant.id) return false;
    final line = CartLine.of(product, options: options);
    final existing = cart?.lines.where((l) => l.key == line.key).firstOrNull;
    if (existing == null) {
      _save(
        Cart(
          restaurantId: restaurant.id,
          restaurantName: restaurant.name,
          lines: [...?cart?.lines, line],
        ),
      );
    } else {
      setQuantity(line.key, existing.quantity + 1);
    }
    return true;
  }

  void replaceWith(
    Restaurant restaurant,
    Product product, {
    List<ChosenOption> options = const [],
  }) => _save(
    Cart(
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      lines: [CartLine.of(product, options: options)],
    ),
  );

  /// [key] : clé de la ligne ([CartLine.key]) ; 0 retire la ligne, un panier vide disparaît.
  void setQuantity(String key, int quantity) {
    final cart = state.value;
    if (cart == null) return;
    final value = quantity.clamp(0, maxQuantity);
    _save(
      Cart(
        restaurantId: cart.restaurantId,
        restaurantName: cart.restaurantName,
        lines: [
          for (final line in cart.lines)
            if (line.key != key)
              line
            else if (value > 0)
              line.withQuantity(value),
        ],
      ),
    );
  }

  /// Demande rendue après l'annulation d'une commande non payée (changement de moyen de paiement).
  Future<void> restore(Cart cart) => _save(cart);

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
