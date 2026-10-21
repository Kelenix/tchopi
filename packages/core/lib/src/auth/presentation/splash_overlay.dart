import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';

/// Animation de démarrage (ADR-053) : le livreur à moto traverse l'écran en laissant une traînée, puis le nom
/// Tchopi apparaît. Pendant ce temps la session est relue (stockage sécurisé) et la navigation se décide en
/// dessous : à la fin, l'accueil (session valide) ou l'écran d'accès s'affiche directement. Une fois par lancement ;
/// réduite à un fondu si l'appareil limite les animations.
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
    duration: const Duration(milliseconds: 2400),
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
    final tokens = context.tokens;
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            // 0–55 % : la moto traverse ; 35–70 % : le nom apparaît ; 85–100 % : fondu vers l'app.
            final ride = Curves.easeInOutCubic.transform(
              (t / 0.55).clamp(0, 1),
            );
            final word = Curves.easeOut.transform(
              ((t - 0.35) / 0.35).clamp(0, 1),
            );
            final fade =
                1 - Curves.easeIn.transform(((t - 0.85) / 0.15).clamp(0, 1));
            return Opacity(
              opacity: fade,
              child: ColoredBox(
                color: tokens.primary,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final x = -120 + (box.maxWidth + 240) * ride;
                    return Stack(
                      children: [
                        // Traînée derrière la moto.
                        Positioned(
                          left: 0,
                          width: (x + 20).clamp(0, box.maxWidth),
                          top: box.maxHeight * 0.42 + 46,
                          height: 4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                colors: [
                                  tokens.onPrimary.withValues(alpha: 0),
                                  tokens.onPrimary.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: x,
                          top: box.maxHeight * 0.42 - 20,
                          child: Transform.rotate(
                            angle: -0.04 * (1 - ride),
                            child: Icon(
                              Icons.delivery_dining,
                              size: 88,
                              color: tokens.onPrimary,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: box.maxHeight * 0.42 + 80,
                          child: Opacity(
                            opacity: word,
                            child: Transform.translate(
                              offset: Offset(0, 16 * (1 - word)),
                              child: Column(
                                children: [
                                  BrandWordmark(
                                    size: 44,
                                    color: tokens.onPrimary,
                                  ),
                                  const SizedBox(height: Space.sm),
                                  Text(
                                    AppLocalizations.of(context).splashTagline,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: tokens.onPrimary.withValues(
                                            alpha: 0.85,
                                          ),
                                        ),
                                  ),
                                ],
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
