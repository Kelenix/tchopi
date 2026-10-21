import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/app_theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../supabase/supabase_setup.dart';
import '../application/auth_controllers.dart';
import '../application/auth_providers.dart';
import '../domain/login_identifier.dart';
import '../domain/models.dart';
import 'widgets/auth_form_scaffold.dart';

/// Bannière et vérification WhatsApp, réglées par l'admin (`public_auth_config`, lisible sans compte).
final authEntryConfigProvider = FutureProvider.autoDispose<AuthEntryConfig>((
  ref,
) async {
  try {
    final data = await ref
        .watch(supabaseClientProvider)
        .rpc<Map<String, dynamic>>('public_auth_config');
    return (
      bannerTitle: data['banner_title'] as String?,
      bannerBody: data['banner_body'] as String?,
      whatsapp: data['whatsapp'] == true,
    );
  } on Object {
    return (bannerTitle: null, bannerBody: null, whatsapp: false);
  }
});

/// Indicatifs proposés ; la Côte d'Ivoire par défaut.
const _countries = [
  (IsoCode.CI, '🇨🇮', '+225'),
  (IsoCode.SN, '🇸🇳', '+221'),
  (IsoCode.ML, '🇲🇱', '+223'),
  (IsoCode.BF, '🇧🇫', '+226'),
  (IsoCode.GN, '🇬🇳', '+224'),
  (IsoCode.TG, '🇹🇬', '+228'),
  (IsoCode.BJ, '🇧🇯', '+229'),
  (IsoCode.GH, '🇬🇭', '+233'),
  (IsoCode.NG, '🇳🇬', '+234'),
  (IsoCode.CM, '🇨🇲', '+237'),
  (IsoCode.FR, '🇫🇷', '+33'),
];

/// Écran d'accès (ADR-053) : identité visuelle en haut, puis un parcours unique par téléphone (code par SMS ou
/// WhatsApp : connexion si le compte existe, sinon création puis profil à compléter), Google, et l'e-mail en
/// « Autres méthodes ».
class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key, required this.oauthRedirect});

  /// Lien profond de retour après Google (déclaré dans l'app, autorisé sur le serveur).
  final String oauthRedirect;

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  static const _form = 'phone-auth';
  final _phone = TextEditingController();
  var _country = _countries.first;
  bool _invalid = false;
  bool _others = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  String? _e164() {
    try {
      final number = PhoneNumber.parse(
        _phone.text,
        destinationCountry: _country.$1,
      );
      return number.isValid(type: PhoneNumberType.mobile)
          ? number.international
          : null;
    } on PhoneNumberException {
      return null;
    }
  }

  Future<void> _sendCode({required bool whatsapp}) async {
    final phone = _e164();
    setState(() => _invalid = phone == null);
    if (phone == null) return;
    final ok = await ref
        .read(formSubmissionProvider(_form).notifier)
        .run(
          () => ref
              .read(authFlowsProvider)
              .sendPhoneCode(phone, whatsapp: whatsapp),
        );
    if (ok && mounted) {
      await context.push(
        '/verify',
        extra: CodeTarget(
          LoginIdentifier.phone(phone),
          CodePurpose.phoneLogin,
          whatsapp: whatsapp,
        ),
      );
    }
  }

  Future<void> _google() => ref
      .read(formSubmissionProvider(_form).notifier)
      .run(
        () =>
            ref.read(authFlowsProvider).signInWithGoogle(widget.oauthRedirect),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submission = ref.watch(formSubmissionProvider(_form));
    final config = ref.watch(authEntryConfigProvider).value;
    final phoneEnabled = ref.watch(loginMethodsProvider).value?.phone ?? false;
    final busy = submission.isLoading;

    return Theme(
      data: AppTheme.brand(Theme.of(context).brightness),
      child: Builder(
        builder: (context) =>
            _body(context, l10n, submission, config, phoneEnabled, busy),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<void> submission,
    AuthEntryConfig? config,
    bool phoneEnabled,
    bool busy,
  ) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Voile sur la photo dans la couleur du fond : clair en thème clair, sombre en thème sombre.
    final veil = tokens.surface;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: tokens.surface,
        // Photo et logo sur ~45 % de l'écran, puis la feuille de connexion qui la chevauche et descend jusqu'en bas.
        body: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: box.maxHeight * 0.45,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/welcome-hero.jpg',
                        package: 'core',
                        fit: BoxFit.cover,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              veil.withValues(alpha: 0.35),
                              veil.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                      const SafeArea(
                        child: Center(child: BrandLogo(width: 280)),
                      ),
                    ],
                  ),
                ),
                Container(
                  transform: Matrix4.translationValues(0, -Radii.sheet, 0),
                  constraints: BoxConstraints(
                    minHeight: box.maxHeight * 0.55 + Radii.sheet,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(Radii.sheet),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      Space.xl,
                      Space.xl,
                      Space.xl,
                      Space.lg,
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (config?.bannerTitle != null) ...[
                            _Banner(
                              title: config!.bannerTitle!,
                              body: config.bannerBody,
                            ),
                            const SizedBox(height: Space.xl),
                          ],
                          Text(
                            l10n.authWelcome,
                            textAlign: TextAlign.center,
                            style: text.headlineMedium!.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: Space.xs),
                          Text(
                            l10n.authPhonePrompt,
                            textAlign: TextAlign.center,
                            style: text.bodyMedium!.copyWith(
                              color: tokens.muted,
                            ),
                          ),
                          const SizedBox(height: Space.xl),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 124,
                                child:
                                    DropdownButtonFormField<
                                      (IsoCode, String, String)
                                    >(
                                      initialValue: _country,
                                      isExpanded: true,
                                      borderRadius: BorderRadius.circular(
                                        Radii.field,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: l10n.authCountry,
                                      ),
                                      items: [
                                        for (final c in _countries)
                                          DropdownMenuItem(
                                            value: c,
                                            child: Text('${c.$2} ${c.$3}'),
                                          ),
                                      ],
                                      onChanged: busy
                                          ? null
                                          : (c) =>
                                                setState(() => _country = c!),
                                    ),
                              ),
                              const SizedBox(width: Space.md),
                              Expanded(
                                child: TextField(
                                  controller: _phone,
                                  enabled: !busy,
                                  keyboardType: TextInputType.phone,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumberNational,
                                  ],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9 ]'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: l10n.authPhone,
                                    errorText: _invalid
                                        ? l10n.authPhoneInvalid
                                        : null,
                                  ),
                                  onChanged: (_) => _invalid
                                      ? setState(() => _invalid = false)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          if (!phoneEnabled) ...[
                            const SizedBox(height: Space.sm),
                            Text(
                              l10n.authPhoneUnavailable,
                              style: text.bodySmall!.copyWith(
                                color: tokens.muted,
                              ),
                            ),
                          ],
                          const SizedBox(height: Space.lg),
                          Row(
                            children: [
                              Expanded(
                                child: config?.whatsapp ?? false
                                    ? OutlinedButton(
                                        onPressed: busy || !phoneEnabled
                                            ? null
                                            : () => _sendCode(whatsapp: false),
                                        child: Text(l10n.authBySms),
                                      )
                                    : FilledButton(
                                        onPressed: busy || !phoneEnabled
                                            ? null
                                            : () => _sendCode(whatsapp: false),
                                        child: Text(l10n.authBySms),
                                      ),
                              ),
                              if (config?.whatsapp ?? false) ...[
                                const SizedBox(width: Space.md),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: busy || !phoneEnabled
                                        ? null
                                        : () => _sendCode(whatsapp: true),
                                    child: Text(l10n.authByWhatsapp),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (submission.hasError) ...[
                            const SizedBox(height: Space.md),
                            Text(
                              failureMessage(l10n, submission.error),
                              textAlign: TextAlign.center,
                              style: text.labelLarge!.copyWith(
                                color: tokens.danger,
                              ),
                            ),
                          ],
                          const SizedBox(height: Space.xl),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Space.md,
                                ),
                                child: Text(
                                  l10n.authOr,
                                  style: text.bodySmall!.copyWith(
                                    color: tokens.muted,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: Space.xl),
                          OutlinedButton.icon(
                            onPressed: busy ? null : _google,
                            icon: const _GoogleMark(),
                            label: Text(l10n.authGoogle),
                          ),
                          const SizedBox(height: Space.md),
                          TextButton.icon(
                            onPressed: () => setState(() => _others = !_others),
                            iconAlignment: IconAlignment.end,
                            icon: Icon(
                              _others ? Icons.expand_less : Icons.expand_more,
                            ),
                            label: Text(l10n.authOtherMethods),
                          ),
                          if (_others) ...[
                            OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () => context.push('/sign-in'),
                              child: Text(l10n.authEmailSignIn),
                            ),
                            const SizedBox(height: Space.sm),
                            OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () => context.push('/sign-up'),
                              child: Text(l10n.authEmailSignUp),
                            ),
                          ],
                          const SizedBox(height: Space.xl),
                          Text(
                            l10n.authTerms,
                            textAlign: TextAlign.center,
                            style: text.bodySmall!.copyWith(
                              color: tokens.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: tokens.primarySoft,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Row(
        children: [
          Icon(Icons.delivery_dining, size: 40, color: tokens.primary),
          const SizedBox(width: Space.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                if (body != null) Text(body!, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// « G » aux couleurs de Google (sans image externe).
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (rect) => const SweepGradient(
      colors: [
        Color(0xFF4285F4),
        Color(0xFF34A853),
        Color(0xFFFBBC05),
        Color(0xFFEA4335),
        Color(0xFF4285F4),
      ],
    ).createShader(rect),
    child: const Text(
      'G',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    ),
  );
}
