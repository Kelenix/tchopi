import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';

/// Animation de démarrage (ADR-053) : le logo (livreur à moto) arrive en roulant depuis la gauche avec des traits de
/// vitesse, freine en léger rebond, puis le slogan apparaît. Pendant ce temps la session est relue (stockage sécurisé)
/// et la navigation se décide en dessous : à la fin, l'accueil (session valide) ou l'écran d'accès. Une fois par
/// lancement ; réduite à un fondu si l'appareil limite les animations.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _done) return;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.duration = const Duration(milliseconds: 600);
    }
    _controller.forward().whenComplete(() {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            // 0–50 % : arrivée (rebond à l'arrêt) ; 30–50 % : traits de vitesse qui s'effacent ;
            // 45–70 % : slogan ; 88–100 % : fondu vers l'app.
            final ride = Curves.easeOutBack.transform((t / 0.5).clamp(0, 1));
            final lines = 1 - ((t - 0.3) / 0.2).clamp(0.0, 1.0);
            final tagline = Curves.easeOut.transform(
              ((t - 0.45) / 0.25).clamp(0, 1),
            );
            final fade =
                1 - Curves.easeIn.transform(((t - 0.88) / 0.12).clamp(0, 1));
            // Petit tressautement de la moto pendant l'arrivée.
            final bump = t < 0.5 ? math.sin(t * 60) * 2.5 * (1 - t / 0.5) : 0.0;
            return Opacity(
              opacity: fade,
              // Fond aux couleurs du logo (dégradé orange chaud), logo en grand.
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.2),
                    radius: 1.1,
                    colors: [
                      Color(0xFFFFB347),
                      Color(0xFFF26B0F),
                      Color(0xFF8A2E06),
                    ],
                    stops: [0, 0.55, 1],
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final width = math.min(box.maxWidth * 0.92, 460.0);
                    final x =
                        (box.maxWidth - width) / 2 - (1 - ride) * box.maxWidth;
                    final top = box.maxHeight * 0.3;
                    return Stack(
                      children: [
                        for (final (dy, len) in const [
                          (0.18, 0.9),
                          (0.3, 0.6),
                          (0.42, 1.0),
                          (0.54, 0.7),
                        ])
                          Positioned(
                            left: x - width * 0.55 * len,
                            top: top + width * 0.66 * dy,
                            width: width * 0.55 * len,
                            height: 6,
                            child: Opacity(
                              opacity: lines,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0),
                                      Colors.white.withValues(alpha: 0.9),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: x,
                          top: top + bump,
                          child: BrandLogo(width: width),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: top + width * 0.7 + Space.xl,
                          child: Opacity(
                            opacity: tagline,
                            child: Transform.translate(
                              offset: Offset(0, 12 * (1 - tagline)),
                              child: Text(
                                AppLocalizations.of(context).splashTagline,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
