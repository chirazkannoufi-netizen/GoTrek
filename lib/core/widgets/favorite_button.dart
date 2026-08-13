import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/catalog_item.dart';
import '../../features/auth/auth_gate.dart';
import '../../state/favorites_controller.dart';

/// Heart toggle. Writes through the favourites controller, so every card
/// showing the same item updates together.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({
    super.key,
    required this.item,
    this.onImage = false,
    this.size = 20,
  });

  final CatalogItem item;

  /// Renders on a translucent chip for use over a photo.
  final bool onImage;
  final double size;

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    // Saving belongs to an account, so guests are prompted first.
    if (!await ensureSignedIn(context, ref, action: 'save places')) return;
    if (!context.mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool added = await ref
        .read(favoritesControllerProvider.notifier)
        .toggle(item.favoriteRef);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added
                ? '${item.title} saved to favourites'
                : '${item.title} removed from favourites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool isSaved = ref.watch(isFavoriteProvider(item.favoriteRef));

    final Color iconColor =
        isSaved
            ? theme.colorScheme.error
            : (onImage ? Colors.white : theme.colorScheme.onSurfaceVariant);

    final Widget icon = Icon(
      isSaved ? Icons.favorite : Icons.favorite_border,
      color: iconColor,
      size: size,
    );

    return Semantics(
      button: true,
      label:
          isSaved
              ? 'Remove ${item.title} from favourites'
              : 'Save ${item.title} to favourites',
      child: Material(
        color:
            onImage
                ? Colors.black.withValues(alpha: 0.35)
                : theme.colorScheme.surfaceContainerLowest,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _toggle(context, ref),
          child: Padding(padding: const EdgeInsets.all(8), child: icon),
        ),
      ),
    );
  }
}
