import 'package:shared_preferences/shared_preferences.dart';

import '../models/catalog_item.dart';

/// Saved places, persisted on the device so they survive a restart.
class FavoritesRepository {
  static const String _key = 'gotrek.favorites';

  Future<Set<FavoriteRef>> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? const <String>[];
    final Set<FavoriteRef> refs = <FavoriteRef>{};
    for (final String entry in raw) {
      final FavoriteRef? ref = FavoriteRef.decode(entry);
      if (ref != null) refs.add(ref);
    }
    return refs;
  }

  Future<void> save(Set<FavoriteRef> refs) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      refs.map((FavoriteRef ref) => ref.encode()).toList(),
    );
  }
}
