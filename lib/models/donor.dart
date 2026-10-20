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
    this.ngoDescription = '',
    this.workingArea = '',
    this.communitiesServed = '',
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String donorType;
  final UserRole role;
  final String ngoDescription;
  final String workingArea;
  final String communitiesServed;

  Donor copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? donorType,
    UserRole? role,
    String? ngoDescription,
    String? workingArea,
    String? communitiesServed,
  }) {
    return Donor(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password,
      donorType: donorType ?? this.donorType,
      role: role ?? this.role,
      ngoDescription: ngoDescription ?? this.ngoDescription,
      workingArea: workingArea ?? this.workingArea,
      communitiesServed: communitiesServed ?? this.communitiesServed,
    );
  }
}
