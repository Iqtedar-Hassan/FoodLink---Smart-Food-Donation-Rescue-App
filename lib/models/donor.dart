class Donor {
  Donor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.donorType = 'Household',
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String donorType;

  Donor copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? donorType,
  }) {
    return Donor(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password,
      donorType: donorType ?? this.donorType,
    );
  }
}
