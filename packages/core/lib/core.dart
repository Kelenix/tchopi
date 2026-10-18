/// Code partagé par les apps Client, Livreur et Back-office.
library;

export 'l10n/app_localizations.dart';
export 'src/app/app_root.dart';
export 'src/app/bootstrap.dart';
export 'src/auth/application/auth_providers.dart';
export 'src/auth/domain/app_failure.dart';
export 'src/auth/domain/login_identifier.dart';
export 'src/auth/domain/models.dart';
export 'src/auth/presentation/account_screen.dart' show AccountLink;
export 'src/auth/presentation/welcome_screen.dart';
export 'src/auth/presentation/widgets/auth_form_scaffold.dart'
    show failureMessage;
export 'src/auth/presentation/widgets/confirm_sheet.dart';
export 'src/config/env.dart';
export 'src/couriers/models.dart';
export 'src/design/app_theme.dart';
export 'src/design/dish_art.dart';
export 'src/design/tokens.dart';
export 'src/places/models.dart';
export 'src/places/places_providers.dart';
export 'src/routing/app_router.dart';
export 'src/supabase/supabase_setup.dart';
export 'src/utils/money.dart';
