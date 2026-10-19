import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Photos publiques des restaurants (bucket « media », chemins `restaurants/<id>/…`).
class MediaRepository {
  MediaRepository(this._client);

  final SupabaseClient _client;

  static const _bucket = 'media';

  Future<String> uploadRestaurantImage(
    String restaurantId,
    Uint8List bytes,
    String kind,
  ) => guardCall(() async {
    final path =
        'restaurants/$restaurantId/$kind-${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return path;
  });

  String publicUrl(String path) =>
      _client.storage.from(_bucket).getPublicUrl(path);
}

/// Photo prise ou choisie, réduite à 800 px avant l'envoi (données mobiles, stockage).
Future<Uint8List?> pickPhoto(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.photoTake),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.photoChoose),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return null;
  final file = await ImagePicker().pickImage(
    source: source,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 80,
  );
  return file?.readAsBytes();
}
