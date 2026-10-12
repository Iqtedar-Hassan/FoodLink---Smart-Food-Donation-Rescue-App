import 'package:flutter_test/flutter_test.dart';
import 'package:foodlink/core/constants/app_constants.dart';
import 'package:foodlink/data/repositories/local_donation_repository.dart';
import 'package:foodlink/models/food_donation.dart';
import 'package:foodlink/models/pickup_request.dart';

void main() {
  group('FoodLinkRepository (local demo data)', () {
    test('login succeeds with demo credentials and fails otherwise', () {
      final repository = FoodLinkRepository();

      repository.login(AppConstants.demoEmail, AppConstants.demoPassword);
      expect(repository.isAuthenticated, isTrue);
      expect(repository.currentDonor?.email, AppConstants.demoEmail);

      repository.logout();
      expect(repository.isAuthenticated, isFalse);

      expect(
        () => repository.login(AppConstants.demoEmail, 'wrong-password'),
        throwsStateError,
      );
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

    test('created donations appear immediately for the logged-in donor', () {
      final repository = FoodLinkRepository();
      repository.login(AppConstants.demoEmail, AppConstants.demoPassword);

      final before = repository.totalDonations;
      final now = DateTime.now();

      repository.createDonation(
        FoodDonation(
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
        ),
      );

      expect(repository.totalDonations, before + 1);
      expect(
        repository.donorDonations.any(
          (donation) => donation.id == 'don_test_1',
        ),
        isTrue,
      );
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
          email: 'muneeb@foodlink.demo',
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
