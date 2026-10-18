import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/media.dart';
import '../restaurant_providers.dart';

/// R-04 : produit (photo, nom, description, prix, catégorie, disponibilité) ; retrait du menu (RES-04, RES-05).
class ProductEditorScreen extends ConsumerStatefulWidget {
  const ProductEditorScreen({super.key, this.product});

  static const path = '/restaurant/product';

  final Product? product;

  @override
  ConsumerState<ProductEditorScreen> createState() =>
      _ProductEditorScreenState();
}

class _ProductEditorScreenState extends ConsumerState<ProductEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _description, _price;
  String? _categoryId;
  late bool _available;
  Uint8List? _newPhoto;
  bool _saving = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product?.name);
    _description = TextEditingController(text: product?.description);
    _price = TextEditingController(text: product?.price.toString());
    _categoryId = product?.categoryId;
    _available = product?.isAvailable ?? true;
  }

  @override
  void dispose() {
    for (final controller in [_name, _description, _price]) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _restaurantId => ref.read(managedRestaurantIdProvider)!;

  Future<void> _newCategory() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.categoryNew),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.fieldCategoryName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
    if (name == null || name.isEmpty) return;
    try {
      final menu = await ref.read(restaurantMenuProvider(_restaurantId).future);
      final category = await ref
          .read(restaurantRepositoryProvider)
          .addCategory(_restaurantId, name, menu.categories.length);
      ref.invalidate(restaurantMenuProvider(_restaurantId));
      setState(() => _categoryId = category.id);
    } on AppFailure catch (failure) {
      setState(() => _error = failure);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final saved = AppLocalizations.of(context).productSaved;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final photo = _newPhoto;
      final photoPath = photo == null
          ? widget.product?.photoPath
          : await ref
                .read(mediaRepositoryProvider)
                .uploadRestaurantImage(_restaurantId, photo, 'product');
      await ref
          .read(restaurantRepositoryProvider)
          .saveProduct(
            Product(
              id: widget.product?.id,
              restaurantId: _restaurantId,
              categoryId: _categoryId,
              name: _name.text,
              description: _description.text,
              price: int.parse(_price.text),
              photoPath: photoPath,
              isAvailable: _available,
            ),
          );
      ref.invalidate(restaurantMenuProvider(_restaurantId));
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(saved)));
      context.pop();
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _archive() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.remove_circle_outline,
      title: l10n.productArchiveTitle,
      body: l10n.productArchiveBody,
      confirmLabel: l10n.productArchive,
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(restaurantRepositoryProvider).archive(widget.product!.id!);
      ref.invalidate(restaurantMenuProvider(_restaurantId));
      if (mounted) context.pop();
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final categories =
        ref.watch(restaurantMenuProvider(_restaurantId)).value?.categories ??
        const <MenuCategory>[];
    final existingPhoto = widget.product?.photoPath;
    final ImageProvider? photo = _newPhoto != null
        ? MemoryImage(_newPhoto!)
        : existingPhoto == null
        ? null
        : NetworkImage(
            ref.read(mediaRepositoryProvider).publicUrl(existingPhoto),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? l10n.productNewTitle : l10n.productEditTitle,
        ),
        backgroundColor: tokens.background,
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(Space.screen),
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Material(
                color: tokens.surfaceAlt,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.card),
                ),
                child: InkWell(
                  onTap: () async {
                    final bytes = await pickPhoto(context);
                    if (bytes != null) setState(() => _newPhoto = bytes);
                  },
                  child: photo == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 32,
                              color: tokens.muted,
                            ),
                            const SizedBox(height: Space.sm),
                            Text(
                              l10n.productPhoto,
                              style: TextStyle(color: tokens.muted),
                            ),
                          ],
                        )
                      : Ink.image(image: photo, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: Space.xl),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.fieldProductName),
              validator: (value) =>
                  (value?.trim().length ?? 0) < 2 ? l10n.errorRequired : null,
            ),
            const SizedBox(height: Space.lg),
            TextFormField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: InputDecoration(labelText: l10n.fieldDescription),
            ),
            const SizedBox(height: Space.lg),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l10n.fieldPrice),
              validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0
                  ? l10n.errorNumber
                  : null,
            ),
            const SizedBox(height: Space.lg),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey((_categoryId, categories.length)),
                    initialValue: categories.any((c) => c.id == _categoryId)
                        ? _categoryId
                        : null,
                    items: [
                      DropdownMenuItem(child: Text(l10n.categoryNone)),
                      for (final category in categories)
                        DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                    ],
                    onChanged: (id) => _categoryId = id,
                    decoration: InputDecoration(labelText: l10n.fieldCategory),
                  ),
                ),
                IconButton(
                  tooltip: l10n.categoryNew,
                  icon: const Icon(Icons.add),
                  onPressed: _newCategory,
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _available ? l10n.productAvailable : l10n.productUnavailable,
              ),
              value: _available,
              onChanged: (value) => setState(() => _available = value),
            ),
            if (_error != null) ...[
              const SizedBox(height: Space.md),
              Text(
                failureMessage(l10n, _error),
                style: TextStyle(color: tokens.danger),
              ),
            ],
            const SizedBox(height: Space.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(l10n.actionSave),
            ),
            if (widget.product != null) ...[
              const SizedBox(height: Space.sm),
              TextButton(
                onPressed: _archive,
                child: Text(
                  l10n.productArchive,
                  style: TextStyle(color: tokens.danger),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
