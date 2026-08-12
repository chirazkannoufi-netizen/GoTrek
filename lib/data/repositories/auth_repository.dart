import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';

/// A pending sign-up waiting on SMS confirmation.
class PendingSignUp {
  const PendingSignUp({
    required this.fullName,
    required this.contact,
    required this.code,
  });

  final String fullName;
  final String contact;

  /// The code the user has to type back in.
  ///
  /// There is no SMS gateway behind the app, so the code is generated on the
  /// device and shown on the verification screen. The check itself is real —
  /// a wrong code is rejected.
  final String code;

  bool get contactIsEmail => contact.contains('@');

  String get email => contactIsEmail ? contact : '$_localPart@gotrek.app';

  String? get phone => contactIsEmail ? null : contact;

  String get _localPart => contact.replaceAll(RegExp(r'\D'), '');
}

/// Session handling.
///
/// There is no auth server in this project, so a session is created locally
/// for any well-formed credentials and persisted with `shared_preferences`.
/// Swapping in a real OAuth2/JWT backend means reimplementing this class only.
class AuthRepository {
  AuthRepository({Random? random}) : _random = random ?? Random();

  static const String _sessionKey = 'gotrek.session.user';

  final Random _random;

  Future<UserAccount?> restoreSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    try {
      return UserAccount.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      await prefs.remove(_sessionKey);
      return null;
    }
  }

  Future<UserAccount> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AuthException('Enter your email and password to continue.');
    }
    final UserAccount account = UserAccount(
      id: 'user-${email.trim().toLowerCase().hashCode}',
      fullName: _nameFromEmail(email),
      email: email.trim(),
    );
    await _persist(account);
    return account;
  }

  /// Starts a sign-up and issues the verification code.
  Future<PendingSignUp> startSignUp({
    required String fullName,
    required String contact,
  }) async {
    final String code = (1000 + _random.nextInt(9000)).toString();
    return PendingSignUp(
      fullName: fullName.trim(),
      contact: contact.trim(),
      code: code,
    );
  }

  /// Confirms a pending sign-up and opens the session.
  Future<UserAccount> confirmSignUp({
    required PendingSignUp pending,
    required String code,
  }) async {
    if (code != pending.code) {
      throw const AuthException('That code is not correct. Try again.');
    }
    final UserAccount account = UserAccount(
      id: 'user-${pending.contact.toLowerCase().hashCode}',
      fullName: pending.fullName,
      email: pending.email,
      phone: pending.phone,
    );
    await _persist(account);
    return account;
  }

  Future<void> signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> _persist(UserAccount account) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(account.toJson()));
  }

  static String _nameFromEmail(String email) {
    final String local = email.trim().split('@').first;
    final List<String> words = local
        .split(RegExp(r'[._-]+'))
        .where((String word) => word.isNotEmpty)
        .map(
          (String word) =>
              word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .toList();
    return words.isEmpty ? 'Traveller' : words.join(' ');
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
