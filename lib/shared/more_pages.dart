import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Taille d'une page de liste (commandes, paiements, utilisateurs…).
const pageSize = 20;

/// Suite d'une liste paginée : la première page vient du fournisseur de l'écran, les suivantes sont demandées ici,
/// page par page, avec « Voir plus ». [reset] après un rafraîchissement de la première page.
class MorePages<T> extends ChangeNotifier {
  MorePages(this._load);

  final Future<List<T>> Function(int offset, int limit) _load;
  final items = <T>[];
  bool loading = false;
  Object? error;
  bool _done = false;
  int _generation = 0;

  /// La première page était pleine et la dernière page chargée aussi : il en reste peut-être.
  bool hasMore(int firstPage) =>
      !_done && (items.isNotEmpty || firstPage >= pageSize);

  Future<void> more(int firstPage) async {
    if (loading) return;
    final generation = _generation;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final page = await _load(firstPage + items.length, pageSize);
      if (generation != _generation) return;
      items.addAll(page);
      _done = page.length < pageSize;
    } on Object catch (e) {
      if (generation == _generation) error = e;
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void reset() {
    _generation++;
    items.clear();
    loading = false;
    error = null;
    _done = false;
    notifyListeners();
  }
}

/// Bas de liste : « Voir plus », chargement en cours, ou erreur avec nouvel essai.
class MorePagesFooter extends StatelessWidget {
  const MorePagesFooter({
    super.key,
    required this.pages,
    required this.firstPage,
  });

  final MorePages<Object?> pages;
  final int firstPage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: pages,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.md),
        child: Center(
          child: pages.loading
              ? const CircularProgressIndicator()
              : pages.error != null
              ? Column(
                  children: [
                    Text(failureMessage(l10n, pages.error!)),
                    TextButton(
                      onPressed: () => pages.more(firstPage),
                      child: Text(l10n.actionRetry),
                    ),
                  ],
                )
              : pages.hasMore(firstPage)
              ? OutlinedButton(
                  onPressed: () => pages.more(firstPage),
                  child: Text(l10n.historyLoadMore),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
