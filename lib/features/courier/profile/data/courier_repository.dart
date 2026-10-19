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
      },
    );
    return Courier.fromJson(row);
  });

  /// Lien temporaire (1 h) vers une photo privée.
  Future<String> photoUrl(String path) => guardCall(
    () => _client.storage.from(_bucket).createSignedUrl(path, 3600),
  );
}
