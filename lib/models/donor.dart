class Donor {
  Donor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String password;

  Donor copyWith({String? fullName, String? email, String? phone}) {
    return Donor(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password,
    );
  }
}
