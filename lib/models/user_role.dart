enum UserRole { donor, ngo, admin }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.donor:
        return 'Donor';
      case UserRole.ngo:
        return 'NGO';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
