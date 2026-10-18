import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import 'secure_session_storage.dart';

part 'supabase_setup.g.dart';

Future<void> initSupabase() async {
  Env.ensureConfigured();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    // Supabase auto-hébergé : la clé « anon » sert de clé publique.
    publishableKey: Env.supabaseAnonKey,
    // Sur le web (back-office), le stockage par défaut du navigateur est conservé.
    authOptions: FlutterAuthClientOptions(
      localStorage: kIsWeb ? null : SecureSessionStorage(),
    ),
  );
}

@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;
