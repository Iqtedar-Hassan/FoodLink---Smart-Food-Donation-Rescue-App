import 'package:flutter/foundation.dart';

import '../../core/utils/date_time_utils.dart';
import '../../models/donor.dart';
import '../../models/food_donation.dart';
import '../../models/pickup_request.dart';
import '../../models/user_role.dart';

class FoodLinkRepository extends ChangeNotifier {
  FoodLinkRepository() {
    _donors = [
      Donor(
        id: 'donor_1',
        fullName: 'Iqtedar Donor',
        email: 'iqtedaronor@gmail.com',
        phone: '+923001234567',
        password: 'Pass12345',
        donorType: 'Restaurant',
      ),
      Donor(
        id: 'donor_2',
        fullName: 'Adeel Donor',
        email: 'adeeldonor@gmail.com',
        phone: '+923335556677',
        password: 'Pass12345',
        donorType: 'Household',
      ),
      Donor(
        id: 'ngo_1',
        fullName: 'Iqtedar NGO',
        email: 'iqtedarNGO@gmail.com',
        phone: '+923001112223',
        password: 'Pass1234',
        role: UserRole.ngo,
        ngoDescription: 'Supporting local communities through food rescue.',
        workingArea: 'Islamabad',
        communitiesServed: 'Families in need',
      ),
      Donor(
        id: 'ngo_2',
        fullName: 'Adeel NGO',
        email: 'adeelNGO@gmail.com',
        phone: '+923335556677',
        password: 'Pass1234',
        role: UserRole.ngo,
        ngoDescription: 'Connecting surplus food with nearby communities.',
        workingArea: 'Rawalpindi',
        communitiesServed: 'Community kitchens and shelters',
      ),
      Donor(
        id: 'admin_1',
        fullName: 'FoodLink Administrator',
        email: 'admin@gmail.com',
        phone: '',
        password: 'Admin@12345',
        role: UserRole.admin,
      ),
    ];

    final now = DateTime.now();
    _donations = [
      FoodDonation(
        id: 'don_101',
        donorId: 'donor_1',
        foodName: 'Chicken Rice Bowl',
        category: 'Cooked Meals',
        quantity: 12,
        quantityUnit: 'Portions',
        safeUseDeadline: now.add(const Duration(days: 1, hours: 6)),
        pickupStart: now.add(const Duration(days: 1)),
        pickupEnd: now.add(const Duration(days: 1, hours: 2)),
        pickupArea: 'G-11',
        pickupAddress: 'Street 3, Sector G-11/1, Islamabad',
        notes: 'Freshly prepared and packed in sealed containers.',
        createdAt: now.subtract(const Duration(days: 2)),
        status: DonationStatus.available,
      ),
      FoodDonation(
        id: 'don_102',
        donorId: 'donor_1',
        foodName: 'Fresh Bread Pack',
        category: 'Bakery Items',
        quantity: 20,
        quantityUnit: 'Items',
        safeUseDeadline: now.add(const Duration(hours: 12)),
        pickupStart: now.add(const Duration(hours: 2)),
        pickupEnd: now.add(const Duration(hours: 5)),
        pickupArea: 'F-8',
        pickupAddress: 'Market Road, F-8 Markaz, Islamabad',
        notes: 'Best consumed on the same day.',
        createdAt: now.subtract(const Duration(days: 1)),
        status: DonationStatus.available,
      ),
      FoodDonation(
        id: 'don_103',
        donorId: 'donor_1',
        foodName: 'Fruit Basket',
        category: 'Fruits',
        quantity: 7,
        quantityUnit: 'Kilograms',
        safeUseDeadline: now.add(const Duration(days: 2)),
        pickupStart: now.add(const Duration(days: 1, hours: 3)),
        pickupEnd: now.add(const Duration(days: 1, hours: 6)),
        pickupArea: 'Bahria Town',
        pickupAddress: 'Plot 42, Bahria Town Phase 7, Rawalpindi',
        notes: 'Apples, bananas, and grapes, all in good condition.',
        createdAt: now.subtract(const Duration(days: 3)),
        status: DonationStatus.reserved,
      ),
      FoodDonation(
        id: 'don_104',
        donorId: 'donor_1',
        foodName: 'Milk and Yogurt',
        category: 'Dairy Products',
        quantity: 10,
        quantityUnit: 'Packs',
        safeUseDeadline: now.add(const Duration(hours: 8)),
        pickupStart: now.add(const Duration(hours: 1)),
        pickupEnd: now.add(const Duration(hours: 4)),
        pickupArea: 'I-9',
        pickupAddress: 'Shop 9, I-9 Market, Islamabad',
        notes: 'Requires quick collection due to short shelf life.',
        createdAt: now.subtract(const Duration(days: 7)),
        status: DonationStatus.collected,
      ),
      FoodDonation(
        id: 'don_105',
        donorId: 'donor_2',
        foodName: 'Vegetable Boxes',
        category: 'Vegetables',
        quantity: 15,
        quantityUnit: 'Boxes',
        safeUseDeadline: now.add(const Duration(days: 3)),
        pickupStart: now.add(const Duration(days: 2)),
        pickupEnd: now.add(const Duration(days: 2, hours: 4)),
        pickupArea: 'Sihala',
        pickupAddress: 'Lane 5, Sihala, Islamabad',
        notes: 'Mixed seasonal vegetables.',
        createdAt: now.subtract(const Duration(days: 4)),
        status: DonationStatus.available,
      ),
      FoodDonation(
        id: 'don_106',
        donorId: 'donor_1',
        foodName: 'Packaged Family Meal',
        category: 'Packaged Food',
        quantity: 5,
        quantityUnit: 'Boxes',
        safeUseDeadline: now.add(const Duration(days: 6)),
        pickupStart: now.add(const Duration(days: 3)),
        pickupEnd: now.add(const Duration(days: 3, hours: 2)),
        pickupArea: 'Wah Cantt',
        pickupAddress: 'D-Block, Wah Cantt, Punjab',
        notes: 'Sealed goods suitable for families.',
        createdAt: now.subtract(const Duration(days: 12)),
        status: DonationStatus.cancelled,
      ),
    ];

    _pickupRequests = [
      PickupRequest(
        id: 'req_1',
        donationId: 'don_101',
        ngoName: 'Care for Humanity',
        requestedQuantity: 4,
        requestedUnit: 'Portions',
        pickupDate: now.add(const Duration(days: 1, hours: 1)),
        submittedAt: now.subtract(const Duration(days: 1)),
        message: 'We can pick up in the morning and distribute to families.',
        status: PickupRequestStatus.pending,
      ),
      PickupRequest(
        id: 'req_2',
        donationId: 'don_103',
        ngoName: 'Hope Food Bank',
        requestedQuantity: 2,
        requestedUnit: 'Kilograms',
        pickupDate: now.add(const Duration(days: 1, hours: 4)),
        submittedAt: now.subtract(const Duration(hours: 6)),
        message: 'Our volunteers can collect before noon.',
        status: PickupRequestStatus.approved,
      ),
      PickupRequest(
        id: 'req_3',
        donationId: 'don_101',
        ngoName: 'Noor Welfare',
        requestedQuantity: 3,
        requestedUnit: 'Portions',
        pickupDate: now.add(const Duration(days: 1, hours: 3)),
        submittedAt: now.subtract(const Duration(hours: 4)),
        message: 'We need food for a community kitchen.',
        status: PickupRequestStatus.pending,
      ),
      PickupRequest(
        id: 'req_4',
        donationId: 'don_102',
        ngoName: 'Food First Initiative',
        requestedQuantity: 10,
        requestedUnit: 'Items',
        pickupDate: now.add(const Duration(hours: 3)),
        submittedAt: now.subtract(const Duration(days: 1)),
        message: 'We can collect in the next few hours.',
        status: PickupRequestStatus.rejected,
      ),
      PickupRequest(
        id: 'req_5',
        donationId: 'don_105',
        ngoName: 'Green Harvest Trust',
        requestedQuantity: 5,
        requestedUnit: 'Boxes',
        pickupDate: now.add(const Duration(days: 2, hours: 3)),
        submittedAt: now.subtract(const Duration(hours: 5)),
        message: 'Please confirm if we can collect this evening.',
        status: PickupRequestStatus.pending,
      ),
    ];
  }

  late List<Donor> _donors;
  late List<FoodDonation> _donations;
  late List<PickupRequest> _pickupRequests;
  Donor? _currentDonor;
  int _lastGeneratedDonationId = 0;
  int _lastGeneratedAccountId = 0;

  Donor? get currentDonor => _currentDonor;
  List<Donor> get donors => List.unmodifiable(_donors);
  List<FoodDonation> get donations => List.unmodifiable(_donations);
  List<PickupRequest> get pickupRequests => List.unmodifiable(_pickupRequests);
  bool get isAuthenticated => _currentDonor != null;

  UserRole login(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      throw StateError('Email and password are required.');
    }
    final normalizedEmail = email.trim();
    final donor = _donors.firstWhere(
      (item) => item.email.toLowerCase() == normalizedEmail.toLowerCase(),
      orElse: () =>
          Donor(id: '', fullName: '', email: '', phone: '', password: ''),
    );

    if (donor.id.isEmpty || donor.password != password) {
      throw StateError('Invalid email or password.');
    }

    _currentDonor = donor;
    notifyListeners();
    return donor.role;
  }

  void signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    UserRole role = UserRole.donor,
    String? donorType,
  }) {
    if (role != UserRole.donor && role != UserRole.ngo) {
      throw StateError('Only Donor and NGO accounts can register publicly.');
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (fullName.trim().isEmpty ||
        normalizedEmail.isEmpty ||
        phone.trim().isEmpty ||
        password.isEmpty) {
      throw StateError('Please complete all required fields.');
    }
    final existing = _donors.any(
      (donor) => donor.email.toLowerCase() == normalizedEmail,
    );
    if (existing) {
      throw StateError(
        'A donor account with this email already exists in the local demo data.',
      );
    }

    final account = Donor(
      id: _generateAccountId(role),
      fullName: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      password: password,
      donorType: donorType ?? 'Household',
      role: role,
    );
    _donors.add(account);
    _currentDonor = account;
    notifyListeners();
  }

  void createAdminAccount({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    if (_currentDonor?.role != UserRole.admin) {
      throw StateError('Only an administrator can create admin accounts.');
    }
    if (fullName.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.isEmpty) {
      throw StateError('Please complete all required fields.');
    }

    final normalizedEmail = email.trim().toLowerCase();
    final existing = _donors.any(
      (donor) => donor.email.toLowerCase() == normalizedEmail,
    );
    if (existing) {
      throw StateError('An account with this email already exists.');
    }

    _donors.add(
      Donor(
        id: _generateAccountId(UserRole.admin),
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        password: password,
        role: UserRole.admin,
      ),
    );
    notifyListeners();
  }

  String _generateAccountId(UserRole role) {
    String id;
    do {
      id =
          '${role.name}_${DateTime.now().microsecondsSinceEpoch}_'
          '${_lastGeneratedAccountId++}';
    } while (_donors.any((donor) => donor.id == id));
    return id;
  }

  void logout() {
    _currentDonor = null;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  List<FoodDonation> get donorDonations {
    final donorId = _currentDonor?.id;
    if (donorId == null) {
      return const [];
    }
    final list = _donations
        .where((donation) => donation.donorId == donorId)
        .toList();
    list.sort((a, b) => a.safeUseDeadline.compareTo(b.safeUseDeadline));
    return list;
  }

  List<PickupRequest> get donorPickupRequests {
    final donorId = _currentDonor?.id;
    if (donorId == null) {
      return const [];
    }
    final donationIds = _donations
        .where((donation) => donation.donorId == donorId)
        .map((donation) => donation.id)
        .toSet();

    return _pickupRequests
        .where((request) => donationIds.contains(request.donationId))
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  FoodDonation? donationById(String id) {
    for (final donation in _donations) {
      if (donation.id == id) {
        return donation;
      }
    }
    return null;
  }

  List<PickupRequest> requestsForDonation(String donationId) {
    return _pickupRequests
        .where((request) => request.donationId == donationId)
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  int get totalDonations => donorDonations.length;

  /// Donations that are currently open for pickup requests: status is
  /// Available and the safe-use deadline has not passed yet.
  int get availableDonations => donorDonations
      .where(
        (donation) =>
            donation.status == DonationStatus.available &&
            !DateTimeUtils.isPastDeadline(donation.safeUseDeadline),
      )
      .length;

  int get pendingPickupRequests => donorPickupRequests
      .where((request) => request.status == PickupRequestStatus.pending)
      .length;

  int get completedDonations => donorDonations
      .where(
        (donation) =>
            donation.status == DonationStatus.collected ||
            donation.status == DonationStatus.delivered,
      )
      .length;

  List<FoodDonation> get recentDonations =>
      donorDonations
          .where(
            (donation) =>
                (donation.status == DonationStatus.available ||
                    donation.status == DonationStatus.reserved) &&
                !DateTimeUtils.isPastDeadline(donation.safeUseDeadline),
          )
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  String generateDonationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nextId = timestamp > _lastGeneratedDonationId
        ? timestamp
        : _lastGeneratedDonationId + 1;
    _lastGeneratedDonationId = nextId;
    return 'don_$nextId';
  }

  void createDonation(FoodDonation donation) {
    if (_donations.any((existing) => existing.id == donation.id)) {
      throw StateError('A donation with this id already exists.');
    }
    _donations.add(donation);
    notifyListeners();
  }

  void updateDonation(FoodDonation updatedDonation) {
    final index = _donations.indexWhere(
      (donation) => donation.id == updatedDonation.id,
    );
    if (index != -1) {
      _donations[index] = updatedDonation;
      notifyListeners();
    }
  }

  void cancelDonation(String id) {
    final donation = donationById(id);
    if (donation == null) {
      throw StateError('Donation could not be found.');
    }
    if (donation.status != DonationStatus.available &&
        donation.status != DonationStatus.reserved) {
      throw StateError(
        'A ${donation.status.label.toLowerCase()} donation can no longer be cancelled.',
      );
    }
    donation.status = DonationStatus.cancelled;
    final pendingRequests = requestsForDonation(id)
        .where((request) => request.status == PickupRequestStatus.pending)
        .toList();
    for (final request in pendingRequests) {
      request.status = PickupRequestStatus.cancelled;
    }
    notifyListeners();
  }

  void approvePickupRequest(String requestId) {
    final request = _pickupRequests.firstWhere(
      (item) => item.id == requestId,
      orElse: () => PickupRequest(
        id: '',
        donationId: '',
        ngoName: '',
        requestedQuantity: 0,
        requestedUnit: '',
        pickupDate: DateTime.now(),
        submittedAt: DateTime.now(),
        message: '',
        status: PickupRequestStatus.pending,
      ),
    );

    if (request.id.isEmpty) {
      throw StateError('Pickup request could not be found.');
    }
    if (request.status != PickupRequestStatus.pending) {
      throw StateError(
        'Only pending requests can be approved. This request is already ${request.status.label.toLowerCase()}.',
      );
    }

    final donation = donationById(request.donationId);
    if (donation == null) {
      throw StateError('The related donation is unavailable.');
    }
    if (DateTimeUtils.isPastDeadline(donation.safeUseDeadline)) {
      throw StateError(
        'This donation has passed its safe-use deadline and cannot be approved.',
      );
    }
    if (donation.status == DonationStatus.cancelled) {
      throw StateError(
        'This donation has been cancelled, so its requests cannot be approved.',
      );
    }
    if (donation.status == DonationStatus.collected ||
        donation.status == DonationStatus.delivered) {
      throw StateError(
        'This donation has already been ${donation.status.label.toLowerCase()}.',
      );
    }

    final alreadyApproved = _pickupRequests.any(
      (item) =>
          item.donationId == request.donationId &&
          item.id != request.id &&
          item.status == PickupRequestStatus.approved,
    );

    if (alreadyApproved) {
      throw StateError(
        'This donation already has one approved pickup request.',
      );
    }

    request.status = PickupRequestStatus.approved;
    donation.status = DonationStatus.reserved;
    notifyListeners();
  }

  void rejectPickupRequest(String requestId) {
    final request = _pickupRequests.firstWhere(
      (item) => item.id == requestId,
      orElse: () => PickupRequest(
        id: '',
        donationId: '',
        ngoName: '',
        requestedQuantity: 0,
        requestedUnit: '',
        pickupDate: DateTime.now(),
        submittedAt: DateTime.now(),
        message: '',
        status: PickupRequestStatus.pending,
      ),
    );

    if (request.id.isEmpty) {
      throw StateError('Pickup request could not be found.');
    }
    if (request.status != PickupRequestStatus.pending) {
      throw StateError(
        'Only pending requests can be rejected. This request is already ${request.status.label.toLowerCase()}.',
      );
    }

    request.status = PickupRequestStatus.rejected;
    final donation = donationById(request.donationId);
    if (donation != null &&
        donation.status == DonationStatus.reserved &&
        !_pickupRequests.any(
          (item) =>
              item.donationId == request.donationId &&
              item.status == PickupRequestStatus.approved,
        )) {
      donation.status = DonationStatus.available;
    }
    notifyListeners();
  }

  void updateDonorProfile({
    required String fullName,
    required String email,
    required String phone,
    String? donorType,
  }) {
    if (_currentDonor == null) return;

    final normalizedEmail = email.trim().toLowerCase();
    final emailTaken = _donors.any(
      (donor) =>
          donor.id != _currentDonor!.id &&
          donor.email.toLowerCase() == normalizedEmail,
    );
    if (emailTaken) {
      throw StateError(
        'This email is already used by another demo donor account.',
      );
    }

    final updatedDonor = _currentDonor!.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      donorType: donorType,
    );

    final index = _donors.indexWhere((donor) => donor.id == _currentDonor!.id);
    if (index != -1) {
      _donors[index] = updatedDonor;
      _currentDonor = updatedDonor;
      notifyListeners();
    }
  }

  void updateNgoProfile({
    required String fullName,
    required String description,
    required String workingArea,
    required String communitiesServed,
  }) {
    final user = _currentDonor;
    if (user == null || user.role != UserRole.ngo) {
      throw StateError('Please sign in with an NGO account.');
    }

    final normalizedName = fullName.trim();
    final normalizedArea = workingArea.trim();
    final normalizedDescription = description.trim();
    if (normalizedName.isEmpty) {
      throw StateError('NGO name is required.');
    }
    if (normalizedArea.isEmpty) {
      throw StateError('Working area or city is required.');
    }
    if (normalizedDescription.length > 300) {
      throw StateError('Description must be 300 characters or fewer.');
    }

    final updatedNgo = user.copyWith(
      fullName: normalizedName,
      ngoDescription: normalizedDescription,
      workingArea: normalizedArea,
      communitiesServed: communitiesServed.trim(),
    );
    final index = _donors.indexWhere((donor) => donor.id == user.id);
    if (index != -1) {
      _donors[index] = updatedNgo;
      _currentDonor = updatedNgo;
      notifyListeners();
    }
  }

  List<FoodDonation> get ngoAvailableDonations {
    final items = _donations.where((donation) {
      return donation.status == DonationStatus.available &&
          !DateTimeUtils.isPastDeadline(donation.safeUseDeadline);
    }).toList();

    items.sort((a, b) => a.safeUseDeadline.compareTo(b.safeUseDeadline));

    return items;
  }

  List<PickupRequest> get currentNgoPickupRequests {
    final ngoId = _currentDonor?.id;

    if (_currentDonor?.role != UserRole.ngo || ngoId == null) {
      return const [];
    }

    return _pickupRequests.where((request) => request.ngoId == ngoId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  void requestPickup(String donationId) {
    final user = _currentDonor;

    if (user == null || user.role != UserRole.ngo) {
      throw StateError('Please sign in with an NGO account.');
    }

    final donation = donationById(donationId);

    if (donation == null ||
        donation.status != DonationStatus.available ||
        DateTimeUtils.isPastDeadline(donation.safeUseDeadline)) {
      throw StateError('This donation is no longer available.');
    }

    final alreadyRequested = _pickupRequests.any((request) {
      return request.donationId == donationId &&
          request.ngoId == user.id &&
          (request.status == PickupRequestStatus.pending ||
              request.status == PickupRequestStatus.approved);
    });

    if (alreadyRequested) {
      throw StateError('You have already requested this donation.');
    }

    _pickupRequests.add(
      PickupRequest(
        id: 'req_${DateTime.now().microsecondsSinceEpoch}',
        donationId: donation.id,
        ngoId: user.id,
        ngoName: user.fullName,
        ngoDescription: user.ngoDescription,
        ngoWorkingArea: user.workingArea,
        ngoCommunitiesServed: user.communitiesServed,
        requestedQuantity: donation.quantity,
        requestedUnit: donation.quantityUnit,
        pickupDate: donation.pickupStart,
        submittedAt: DateTime.now(),
        message: 'Pickup requested by ${user.fullName}.',
        status: PickupRequestStatus.pending,
      ),
    );

    notifyListeners();
  }
}
