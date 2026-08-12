import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_account.dart';
import '../data/repositories/auth_repository.dart';
import 'repository_providers.dart';

/// The signed-in user, or `null` when signed out.
///
/// Restored from disk on start, so a returning user lands straight on the
/// home screen instead of the login form.
class AuthController extends AsyncNotifier<UserAccount?> {
  @override
  Future<UserAccount?> build() =>
      ref.read(authRepositoryProvider).restoreSession();

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue<UserAccount?>.loading();
    state = await AsyncValue.guard<UserAccount?>(
      () => ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password),
    );
  }

  Future<void> confirmSignUp({
    required PendingSignUp pending,
    required String code,
  }) async {
    state = const AsyncValue<UserAccount?>.loading();
    state = await AsyncValue.guard<UserAccount?>(
      () => ref
          .read(authRepositoryProvider)
          .confirmSignUp(pending: pending, code: code),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue<UserAccount?>.data(null);
  }
}

final AsyncNotifierProvider<AuthController, UserAccount?>
authControllerProvider = AsyncNotifierProvider<AuthController, UserAccount?>(
  AuthController.new,
);

/// Convenience read for screens that only need the account.
final Provider<UserAccount?> currentUserProvider = Provider<UserAccount?>(
  (Ref ref) => ref.watch(authControllerProvider).value,
);
