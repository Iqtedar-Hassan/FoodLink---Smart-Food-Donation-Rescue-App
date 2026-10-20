import 'package:flutter_test/flutter_test.dart';
import 'package:foodlink/core/constants/app_constants.dart';
import 'package:foodlink/data/repositories/local_donation_repository.dart';
import 'package:foodlink/models/food_donation.dart';
import 'package:foodlink/models/pickup_request.dart';
import 'package:foodlink/models/user_role.dart';

void main() {
  group('FoodLinkRepository (local demo data)', () {
    test('login succeeds with demo credentials and fails otherwise', () {
      final repository = FoodLinkRepository();

      expect(
        repository.login(AppConstants.demoEmail, AppConstants.demoPassword),
        UserRole.donor,
      );
      expect(repository.isAuthenticated, isTrue);
      expect(repository.currentDonor?.email, AppConstants.demoEmail);

      repository.logout();
      expect(repository.isAuthenticated, isFalse);

      expect(
        () => repository.login(AppConstants.demoEmail, 'wrong-password'),
        throwsStateError,
      );
    });

    test('all five fixed accounts are seeded once and survive logout', () {
      final repository = FoodLinkRepository();
      expect(repository.donors, hasLength(5));

      final fixedAccounts = <(String, String, UserRole)>[
        ('iqtedaronor@gmail.com', 'Pass12345', UserRole.donor),
        ('adeeldonor@gmail.com', 'Pass12345', UserRole.donor),
        ('iqtedarNGO@gmail.com', 'Pass1234', UserRole.ngo),
        ('adeelNGO@gmail.com', 'Pass1234', UserRole.ngo),
        ('admin@gmail.com', 'Admin@12345', UserRole.admin),
      ];
      for (final (email, password, role) in fixedAccounts) {
        expect(repository.login(email, password), role);
        expect(repository.currentDonor?.email, email);
        repository.logout();
      }

      expect(repository.donors, hasLength(5));
      expect(
        () => repository.login('admin@gmail.com', 'wrong-password'),
        throwsStateError,
      );
      expect(() => repository.login('', 'Pass12345'), throwsStateError);
      expect(() => repository.login('admin@gmail.com', ''), throwsStateError);
    });

    test('temporary accounts survive logout but not repository restart', () {
      final repository = FoodLinkRepository();
      repository.signup(
        fullName: 'Temporary Donor',
        email: 'temporary@foodlink.demo',
        phone: '+923001112223',
        password: 'Pass12345',
      );
      expect(
        repository.login('temporary@foodlink.demo', 'Pass12345'),
        UserRole.donor,
      );
      repository.logout();
      expect(
        repository.login('temporary@foodlink.demo', 'Pass12345'),
        UserRole.donor,
      );
      repository.logout();

      final restartedRepository = FoodLinkRepository();
      expect(restartedRepository.donors, hasLength(5));
      expect(
        () => restartedRepository.login('temporary@foodlink.demo', 'Pass12345'),
        throwsStateError,
      );
    });

    test('NGO role is stored and returned by shared login', () {
      final repository = FoodLinkRepository();

      repository.signup(
        fullName: 'Community NGO',
        email: 'ngo@foodlink.demo',
        phone: '+923001112223',
        password: 'Pass1234',
        role: UserRole.ngo,
      );

      expect(repository.currentDonor?.role, UserRole.ngo);
      expect(repository.donors.last.role, UserRole.ngo);
      expect(repository.login('ngo@foodlink.demo', 'Pass1234'), UserRole.ngo);
      expect(repository.currentDonor?.role, UserRole.ngo);
    });

    test('Admin accounts cannot be created through public registration', () {
      final repository = FoodLinkRepository();
      final donorCount = repository.donors.length;

      expect(
        () => repository.signup(
          fullName: 'Public Admin',
          email: 'admin@foodlink.demo',
          phone: '+923001112223',
          password: 'Pass1234',
          role: UserRole.admin,
        ),
        throwsStateError,
      );
      expect(repository.donors, hasLength(donorCount));
    });

    test('only an authenticated admin can create additional admins', () {
      final repository = FoodLinkRepository();
      expect(
        () => repository.createAdminAccount(
          fullName: 'Unauthorized Admin',
          email: 'unauthorized@gmail.com',
          phone: '+923001112223',
          password: 'Admin@12345',
        ),
        throwsStateError,
      );
      expect(repository.donors, hasLength(5));

      repository.login('admin@gmail.com', 'Admin@12345');
      repository.createAdminAccount(
        fullName: 'Session Admin',
        email: 'session.admin@gmail.com',
        phone: '+923001112223',
        password: 'Admin@12345',
      );
      repository.logout();
      expect(
        repository.login('session.admin@gmail.com', 'Admin@12345'),
        UserRole.admin,
      );
      expect(
        () => repository.createAdminAccount(
          fullName: 'Duplicate Admin',
          email: 'ADMIN@gmail.com',
          phone: '+923004445556',
          password: 'Admin@12345',
        ),
        throwsStateError,
      );
      repository.logout();

      expect(FoodLinkRepository().donors, hasLength(5));
    });

    test('signup stores donor type and blocks duplicate emails', () {
      final repository = FoodLinkRepository();

      repository.signup(
        fullName: 'Test Donor',
        email: 'test@foodlink.demo',
        phone: '+923001112223',
        password: 'Pass1234',
        donorType: 'Bakery',
      );

      expect(repository.currentDonor?.fullName, 'Test Donor');
      expect(repository.currentDonor?.donorType, 'Bakery');

      expect(
        () => repository.signup(
          fullName: 'Another Donor',
          email: AppConstants.demoEmail,
          phone: '+923004445556',
          password: 'Pass1234',
        ),
        throwsStateError,
      );
    });

    test(
      'NGO requests are account-specific and active requests are unique',
      () {
        final repository = FoodLinkRepository();
        repository.signup(
          fullName: 'Community NGO',
          email: 'ngo@foodlink.demo',
          phone: '+923001112223',
          password: 'Pass1234',
          role: UserRole.ngo,
        );
        expect(
          () => repository.signup(
            fullName: 'Duplicate Email Donor',
            email: 'NGO@foodlink.demo',
            phone: '+923005556667',
            password: 'Pass1234',
          ),
          throwsStateError,
        );

        repository.requestPickup('don_101');

        expect(repository.currentNgoPickupRequests, hasLength(1));
        expect(
          repository.currentNgoPickupRequests.single.ngoId,
          repository.currentDonor?.id,
        );
        expect(() => repository.requestPickup('don_101'), throwsStateError);
        expect(repository.currentNgoPickupRequests, hasLength(1));

        repository.signup(
          fullName: 'Community NGO',
          email: 'second-ngo@foodlink.demo',
          phone: '+923004445556',
          password: 'Pass1234',
          role: UserRole.ngo,
        );
        expect(repository.currentNgoPickupRequests, isEmpty);
      },
    );

    test('NGO profile is saved and captured on each pickup request', () {
      final repository = FoodLinkRepository();
      repository.signup(
        fullName: 'Community NGO',
        email: 'ngo@foodlink.demo',
        phone: '+923001112223',
        password: 'Pass1234',
        role: UserRole.ngo,
      );
      repository.updateNgoProfile(
        fullName: 'Community Food Network',
        description: 'Rescuing meals and supporting local families.',
        workingArea: 'Islamabad',
        communitiesServed: 'Low-income families and community kitchens',
      );

      repository.requestPickup('don_101');
      final request = repository.currentNgoPickupRequests.single;
      expect(request.ngoName, 'Community Food Network');
      expect(
        request.ngoDescription,
        'Rescuing meals and supporting local families.',
      );
      expect(request.ngoWorkingArea, 'Islamabad');
      expect(
        request.ngoCommunitiesServed,
        'Low-income families and community kitchens',
      );

      repository.updateNgoProfile(
        fullName: 'Community Food Network',
        description: 'Updated description.',
        workingArea: 'Rawalpindi',
        communitiesServed: 'Shelters',
      );
      expect(
        request.ngoDescription,
        'Rescuing meals and supporting local families.',
      );
      expect(request.ngoWorkingArea, 'Islamabad');
      expect(
        () => repository.updateNgoProfile(
          fullName: 'Community Food Network',
          description: 'x' * 301,
          workingArea: 'Rawalpindi',
          communitiesServed: '',
        ),
        throwsStateError,
      );
    });

    test('created donations appear immediately for the logged-in donor', () {
      final repository = FoodLinkRepository();
      repository.login(AppConstants.demoEmail, AppConstants.demoPassword);

      final before = repository.totalDonations;
      final now = DateTime.now();
      final donation = FoodDonation(
        id: 'don_test_1',
        donorId: repository.currentDonor!.id,
        foodName: 'Test Rice',
        category: 'Cooked Meals',
        quantity: 3,
        quantityUnit: 'Portions',
        safeUseDeadline: now.add(const Duration(hours: 10)),
        pickupStart: now.add(const Duration(hours: 1)),
        pickupEnd: now.add(const Duration(hours: 2)),
        pickupArea: 'H-9',
        pickupAddress: 'Test address',
        notes: '',
        createdAt: now,
        status: DonationStatus.available,
      );

      repository.createDonation(donation);

      expect(repository.totalDonations, before + 1);
      expect(
        repository.donorDonations.any(
          (donation) => donation.id == 'don_test_1',
        ),
        isTrue,
      );
      expect(() => repository.createDonation(donation), throwsStateError);
      expect(repository.totalDonations, before + 1);
    });

    test('recent donations are active, unexpired, and newest first', () {
      final repository = FoodLinkRepository();
      repository.login(AppConstants.demoEmail, AppConstants.demoPassword);

      expect(repository.recentDonations.map((donation) => donation.id), [
        'don_102',
        'don_101',
        'don_103',
      ]);
    });

    test('generated donation IDs remain unique within one millisecond', () {
      final repository = FoodLinkRepository();

      final firstId = repository.generateDonationId();
      final secondId = repository.generateDonationId();

      expect(secondId, isNot(firstId));
    });

    test('availableDonations excludes past-deadline donations', () {
      final repository = FoodLinkRepository();
      repository.login(AppConstants.demoEmail, AppConstants.demoPassword);
      final now = DateTime.now();

      final totalBefore = repository.totalDonations;
      final availableBefore = repository.availableDonations;

      repository.createDonation(
        FoodDonation(
          id: 'don_expired',
          donorId: repository.currentDonor!.id,
          foodName: 'Expired Soup',
          category: 'Cooked Meals',
          quantity: 2,
          quantityUnit: 'Portions',
          safeUseDeadline: now.subtract(const Duration(hours: 1)),
          pickupStart: now.subtract(const Duration(hours: 3)),
          pickupEnd: now.subtract(const Duration(hours: 2)),
          pickupArea: 'H-9',
          pickupAddress: 'Test address',
          notes: '',
          createdAt: now,
          status: DonationStatus.available,
        ),
      );

      // Total grows, but the expired donation is not counted as available.
      expect(repository.totalDonations, totalBefore + 1);
      expect(repository.availableDonations, availableBefore);
    });

    test('expired donations cannot be approved for pickup', () {
      final repository = FoodLinkRepository();
      repository.login(AppConstants.demoEmail, AppConstants.demoPassword);
      final donation = repository.donationById('don_101')!;
      repository.updateDonation(
        donation.copyWith(
          safeUseDeadline: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      );

      expect(() => repository.approvePickupRequest('req_1'), throwsStateError);
      expect(
        repository.donationById('don_101')?.status,
        DonationStatus.available,
      );
      expect(repository.availableDonations, 1);
    });

    test(
      'approving a request reserves the donation and blocks a second approval',
      () {
        final repository = FoodLinkRepository();
        repository.login(AppConstants.demoEmail, AppConstants.demoPassword);

        // don_101 starts Available with two pending requests (req_1, req_3).
        repository.approvePickupRequest('req_1');

        final donation = repository.donationById('don_101');
        expect(donation?.status, DonationStatus.reserved);
        expect(
          repository
              .requestsForDonation('don_101')
              .firstWhere((request) => request.id == 'req_1')
              .status,
          PickupRequestStatus.approved,
        );

        expect(
          () => repository.approvePickupRequest('req_3'),
          throwsStateError,
        );
      },
    );

    test('only pending requests can be approved or rejected', () {
      final repository = FoodLinkRepository();
      repository.login(AppConstants.demoEmail, AppConstants.demoPassword);

      // req_4 (don_102) is seeded as rejected.
      expect(() => repository.approvePickupRequest('req_4'), throwsStateError);
      expect(() => repository.rejectPickupRequest('req_4'), throwsStateError);
    });

    test('rejecting all pending requests keeps the donation available', () {
      final repository = FoodLinkRepository();
      repository.login(AppConstants.demoEmail, AppConstants.demoPassword);

      // don_101 starts Available with two pending requests.
      repository.rejectPickupRequest('req_1');
      repository.rejectPickupRequest('req_3');

      expect(
        repository.donationById('don_101')?.status,
        DonationStatus.available,
      );
    });

    test('cancelling a donation cancels its pending requests', () {
      final repository = FoodLinkRepository();
      repository.login(AppConstants.demoEmail, AppConstants.demoPassword);

      repository.cancelDonation('don_101');

      expect(
        repository.donationById('don_101')?.status,
        DonationStatus.cancelled,
      );
      expect(
        repository
            .requestsForDonation('don_101')
            .every(
              (request) => request.status == PickupRequestStatus.cancelled,
            ),
        isTrue,
      );
    });

    test('collected and delivered donations cannot be cancelled', () {
      final repository = FoodLinkRepository();
      repository.login(AppConstants.demoEmail, AppConstants.demoPassword);

      // don_104 is seeded as collected.
      expect(() => repository.cancelDonation('don_104'), throwsStateError);
    });

    test('profile updates persist and duplicate emails are rejected', () {
      final repository = FoodLinkRepository();
      repository.login(AppConstants.demoEmail, AppConstants.demoPassword);

      expect(
        () => repository.updateDonorProfile(
          fullName: 'Ayesha K.',
          email: 'adeeldonor@gmail.com',
          phone: '+923001234567',
        ),
        throwsStateError,
      );

      repository.updateDonorProfile(
        fullName: 'Ayesha K.',
        email: 'ayesha@foodlink.demo',
        phone: '+923007778889',
        donorType: 'Supermarket',
      );

      expect(repository.currentDonor?.fullName, 'Ayesha K.');
      expect(repository.currentDonor?.email, 'ayesha@foodlink.demo');
      expect(repository.currentDonor?.phone, '+923007778889');
      expect(repository.currentDonor?.donorType, 'Supermarket');
    });
  });
}
