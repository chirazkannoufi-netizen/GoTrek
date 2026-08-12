/// The signed-in user.
class UserAccount {
  const UserAccount({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;

  String get initials {
    final List<String> parts =
        fullName
            .trim()
            .split(RegExp(r'\s+'))
            .where((String part) => part.isNotEmpty)
            .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.firstLetter;
    return '${parts.first.firstLetter}${parts.last.firstLetter}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
  };

  static UserAccount fromJson(Map<String, dynamic> json) => UserAccount(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String?,
  );
}

extension on String {
  String get firstLetter => isEmpty ? '' : substring(0, 1).toUpperCase();
}
