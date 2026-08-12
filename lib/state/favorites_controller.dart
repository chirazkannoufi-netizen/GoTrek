import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/catalog_item.dart';
import 'repository_providers.dart';

/// Saved places. Writes go to disk immediately, so the list survives a
/// restart and stays consistent between the tabs that show it.
class FavoritesController extends AsyncNotifier<Set<FavoriteRef>> {
  @override
  Future<Set<FavoriteRef>> build() =>
      ref.read(favoritesRepositoryProvider).load();

  Future<bool> toggle(FavoriteRef favorite) async {
    final Set<FavoriteRef> current = <FavoriteRef>{...?state.value};
    final bool added = current.add(favorite);
    if (!added) current.remove(favorite);

    state = AsyncValue<Set<FavoriteRef>>.data(current);
    await ref.read(favoritesRepositoryProvider).save(current);
    return added;
  }

  Future<void> clear() async {
    state = const AsyncValue<Set<FavoriteRef>>.data(<FavoriteRef>{});
    await ref.read(favoritesRepositoryProvider).save(<FavoriteRef>{});
  }
}

final AsyncNotifierProvider<FavoritesController, Set<FavoriteRef>>
favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, Set<FavoriteRef>>(
      FavoritesController.new,
    );

/// Whether one specific item is saved. Kept as a family so a card rebuilds
/// only when its own saved state changes.
final ProviderFamily<bool, FavoriteRef> isFavoriteProvider =
    Provider.family<bool, FavoriteRef>(
      (Ref ref, FavoriteRef favorite) =>
          ref.watch(favoritesControllerProvider).value?.contains(favorite) ??
          false,
    );

final Provider<int> favoritesCountProvider = Provider<int>(
  (Ref ref) => ref.watch(favoritesControllerProvider).value?.length ?? 0,
);
