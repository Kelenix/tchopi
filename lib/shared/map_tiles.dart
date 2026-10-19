import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart' as vector;

part 'map_tiles.g.dart';

/// Style du fond de carte, clair ou sombre selon le thème, lu une fois pour toutes les cartes. Chaque style reçoit
/// son propre identifiant : sans « id », la bibliothèque les confond dans son cache (tuiles sombres en clair).
@Riverpod(keepAlive: true)
Future<vector.Style> mapStyle(Ref ref, {required bool dark}) async {
  final style = await vector.StyleReader(
    uri: dark ? Env.mapStyleDarkUrl : Env.mapStyleUrl,
  ).read();
  return vector.Style(
    name: style.name,
    theme: style.theme.copyWith(id: dark ? 'tchopi-dark' : 'tchopi-light'),
    providers: style.providers,
    sprites: style.sprites,
  );
}

/// Fond de carte moderne (tuiles vectorielles) ; si le style ne se charge pas, tuiles OpenStreetMap classiques :
/// la carte n'est jamais vide.
class MapTiles extends ConsumerWidget {
  const MapTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (ref.watch(
    mapStyleProvider(dark: Theme.of(context).brightness == Brightness.dark),
  )) {
    AsyncData(value: final style) => vector.VectorTileLayer(
      theme: style.theme,
      sprites: style.sprites,
      tileProviders: style.providers,
      maximumZoom: 22,
    ),
    AsyncError() => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.tchopi.mobile',
    ),
    _ => const SizedBox.shrink(),
  };
}

/// Mention des fournisseurs du fond de carte, discrète, sur une ligne ; en haut à droite par défaut (le bas des
/// cartes plein écran peut être recouvert).
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key, this.alignment = Alignment.topRight});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Align(
      alignment: alignment,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.sm),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(Radii.chip),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.sm,
                vertical: 2,
              ),
              child: Text(
                Env.mapAttribution,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: tokens.muted,
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
