import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Profil livreur du compte connecté et sa photo (bucket privé « couriers »).
class CourierRepository {
  CourierRepository(this._client);

  final SupabaseClient _client;

  static const _bucket = 'couriers';

  Future<Courier?> fetchMine(String userId) => guardCall(() async {
    final row = await _client
        .from('couriers')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return row == null ? null : Courier.fromJson(row);
  });

  /// Dépose la nouvelle photo (si fournie) puis soumet le profil à validation (COU-01, COU-02).
  Future<Courier> submit({
    required String userId,
    required String zoneId,
    required VehicleType vehicle,
    String? plate,
    String? idType,
    String? idNumber,
    String? residence,
    Uint8List? newPhoto,
    String? currentPhotoPath,
  }) => guardCall(() async {
    var photoPath = currentPhotoPath;
    if (newPhoto != null) {
      photoPath = '$userId/photo-${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage
          .from(_bucket)
          .uploadBinary(
            photoPath,
            newPhoto,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
    }
    final row = await _client.rpc<Map<String, dynamic>>(
      'submit_courier_profile',
      params: {
        'p_zone_id': zoneId,
        'p_vehicle_type': vehicle.wireName,
        'p_plate_number': vehicle.needsPlate ? plate : null,
        'p_photo_path': photoPath,
        'p_id_type': vehicle.needsPlate ? null : idType,
        'p_id_number': vehicle.needsPlate ? null : idNumber,
        'p_residence': residence,
      },
    );
    return Courier.fromJson(row);
  });

  /// Lien temporaire (1 h) vers une photo privée.
  Future<String> photoUrl(String path) => guardCall(
    () => _client.storage.from(_bucket).createSignedUrl(path, 3600),
  );

  /// Pièce d'identité et adresse enregistrées (hors du modèle partagé `Courier`).
  Future<CourierIdentity?> fetchIdentity(String userId) => guardCall(() async {
    final row = await _client
        .from('couriers')
        .select('id_type, id_number, residence')
        .eq('user_id', userId)
        .maybeSingle();
    return row == null
        ? null
        : (
            idType: row['id_type'] as String?,
            idNumber: row['id_number'] as String?,
            residence: row['residence'] as String?,
          );
  });

  /// Formats officiels (pièces d'identité, plaques) vérifiés aussi par le serveur.
  Future<List<IdentityFormat>> identityFormats() => guardCall(() async {
    final rows = await _client
        .from('identity_formats')
        .select('code, kind, label, pattern, example')
        .eq('is_active', true)
        .order('label');
    return [
      for (final r in rows)
        (
          code: r['code'] as String,
          kind: r['kind'] as String,
          label: r['label'] as String,
          pattern: RegExp(r['pattern'] as String),
          example: r['example'] as String,
        ),
    ];
  });

  /// Suppression du profil livreur (le compte reste) ; refusée avec une mission en cours ou des espèces dues.
  Future<void> deleteProfile() =>
      guardCall(() => _client.rpc<void>('delete_courier_profile'));
}

typedef CourierIdentity = ({
  String? idType,
  String? idNumber,
  String? residence,
});
typedef IdentityFormat = ({
  String code,
  String kind,
  String label,
  RegExp pattern,
  String example,
});

/// Même normalisation que le serveur : majuscules, sans espaces, points, tirets ni barres.
String normalizeIdentity(String value) =>
    value.toUpperCase().replaceAll(RegExp(r'[\s.\-/]'), '');
