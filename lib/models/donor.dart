import 'user_role.dart';

class Donor {
  Donor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.donorType = 'Household',
    this.role = UserRole.donor,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String donorType;
  final UserRole role;

  Donor copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? donorType,
    UserRole? role,
  }) {
    return Donor(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password,
      donorType: donorType ?? this.donorType,
      role: role ?? this.role,
    );
  }
}
