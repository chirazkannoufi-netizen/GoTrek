import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/booking_repository.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/favorites_repository.dart';

/// Single place where the repositories are constructed, so tests can override
/// any of them with `ProviderScope(overrides: ...)`.
final Provider<CatalogRepository> catalogRepositoryProvider =
    Provider<CatalogRepository>((Ref ref) => CatalogRepository());

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) => AuthRepository());

final Provider<FavoritesRepository> favoritesRepositoryProvider =
    Provider<FavoritesRepository>((Ref ref) => FavoritesRepository());

final Provider<BookingRepository> bookingRepositoryProvider =
    Provider<BookingRepository>((Ref ref) => BookingRepository());
