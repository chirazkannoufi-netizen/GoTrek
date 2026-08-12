/// Form validation shared by the auth screens.
///
/// Each function returns `null` when the value is acceptable, matching the
/// signature `TextFormField.validator` expects.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _phone = RegExp(r'^\+?[\d\s-]{8,15}$');

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? fullName(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Full name is required';
    if (text.length < 2) return 'Please enter your full name';
    return null;
  }

  static String? email(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (!_email.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  /// Sign-up accepts either an email address or a phone number.
  static String? emailOrPhone(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email or phone number is required';
    if (_email.hasMatch(text) || _phone.hasMatch(text)) return null;
    return 'Enter a valid email or phone number';
  }

  static String? password(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 8) return 'Use at least 8 characters';
    if (!text.contains(RegExp(r'\d'))) return 'Include at least one number';
    return null;
  }

  /// Login only checks presence — strength rules belong on sign-up.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }
}
