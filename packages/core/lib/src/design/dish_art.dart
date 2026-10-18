import 'package:flutter/material.dart';

/// Plats illustrés vus de dessus. Illustration provisoire, affichée tant qu'aucune
/// photo réelle n'est disponible (validée dans la maquette `docs/design/maquette.html`).
/// Comme une photo, ses couleurs ne changent pas avec le thème.
enum Dish {
  attieke(
    Color(0xFFF1E6C6),
    Color(0xFFB4642B),
    Color(0xFFD8452F),
    Color(0xFF3E8E4A),
  ),
  poulet(
    Color(0xFFE7AE55),
    Color(0xFF8C3B1C),
    Color(0xFFC9372C),
    Color(0xFF5BA34B),
  ),
  garba(
    Color(0xFFEFE4C4),
    Color(0xFFA86B2D),
    Color(0xFFE5552E),
    Color(0xFFF2C443),
  ),
  kedjenou(
    Color(0xFFC4572A),
    Color(0xFF8A3618),
    Color(0xFFF0D9A8),
    Color(0xFF4E8D3C),
  ),
  foutou(
    Color(0xFFF4EFDF),
    Color(0xFF8A3B1E),
    Color(0xFFB83A1F),
    Color(0xFF3C7A3A),
  );

  const Dish(this.base, this.main, this.accent, this.herb);

  final Color base;
  final Color main;
  final Color accent;
  final Color herb;
}

/// Fonds de table derrière le plat.
enum TableTone {
  green([Color(0xFF2C5E45), Color(0xFF0F3324)]),
  wood([Color(0xFF8A5532), Color(0xFF57301A)]),
  terra([Color(0xFFC9693F), Color(0xFF8E3F22)]),
  sand([Color(0xFFEDE2CB), Color(0xFFD8C8A7)]);

  const TableTone(this.colors);

  final List<Color> colors;
}

/// Texte et dégradé posés sur une photo ou une illustration, identiques dans les deux thèmes.
abstract final class PhotoOverlay {
  static const foreground = Color(0xFFFFFFFF);
  static const scrim = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xD1050E09), Color(0x26050E09), Color(0x59050E09)],
    stops: [0, 0.62, 1],
  );
}

class DishArt extends StatelessWidget {
  const DishArt({
    super.key,
    required this.dish,
    this.table = TableTone.green,
    this.plateAlignment = Alignment.center,
    this.plateScale = 0.8,
  });

  final Dish dish;
  final TableTone table;

  /// Position du plat ; au-delà de ±1 le plat déborde et se trouve rogné.
  final Alignment plateAlignment;

  /// Diamètre du plat relatif au plus grand côté de la zone.
  final double plateScale;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: table.colors,
          ),
        ),
        child: CustomPaint(
          painter: _PlatePainter(dish, plateAlignment, plateScale),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _PlatePainter extends CustomPainter {
  _PlatePainter(this.dish, this.alignment, this.scale);

  final Dish dish;
  final Alignment alignment;
  final double scale;

  static const _plateInner = Color(0xFFFBFAF6);
  static const _plateRim = Color(0xFFE9E4D9);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.longestSide * scale / 2;
    final center = alignment.alongSize(size);
    Offset at(double dx, double dy) =>
        center + Offset(dx * radius, dy * radius);
    Paint fill(Color color) => Paint()..color = color;

    canvas
      ..drawCircle(
        center.translate(0, radius * 0.08),
        radius,
        Paint()
          ..color = const Color(0x59000000)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.12),
      )
      ..drawCircle(center, radius, fill(_plateRim))
      ..drawCircle(center, radius * 0.86, fill(_plateInner))
      ..drawCircle(at(-0.2, -0.16), radius * 0.5, fill(dish.base))
      ..drawOval(
        Rect.fromCenter(
          center: at(0.22, 0.04),
          width: radius * 0.84,
          height: radius * 0.6,
        ),
        fill(dish.main),
      )
      ..drawCircle(at(-0.28, 0.4), radius * 0.15, fill(dish.accent))
      ..drawCircle(at(0.4, 0.28), radius * 0.11, fill(dish.accent))
      ..drawCircle(at(0.28, -0.32), radius * 0.13, fill(dish.herb))
      // Reflet limité au disque du plat.
      ..drawCircle(
        center,
        radius,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.45, -0.5),
            radius: 0.55,
            colors: [Color(0x52FFFFFF), Color(0x00FFFFFF)],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
  }

  @override
  bool shouldRepaint(_PlatePainter old) =>
      old.dish != dish || old.alignment != alignment || old.scale != scale;
}
