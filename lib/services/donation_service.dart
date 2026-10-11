import '../data/donation_data.dart';
import '../models/donation_model.dart';

class DonationService {
  // Get all donations
  static List<Donation> getAllDonations() {
    return DonationData.donations;
  }

  // Get available donations only
  static List<Donation> getAvailableDonations() {
    return DonationData.donations
        .where((donation) => donation.status == 'Available')
        .toList();
  }

  // Add a new donation
  static void addDonation(Donation donation) {
    DonationData.donations.add(donation);
  }

  // Update donation status
  static void updateStatus(String id, String newStatus) {
    final index = DonationData.donations.indexWhere(
      (donation) => donation.id == id,
    );

    if (index != -1) {
      DonationData.donations[index].status = newStatus;
    }
  }

  // Find a donation by ID
  static Donation? getDonationById(String id) {
    try {
      return DonationData.donations.firstWhere((donation) => donation.id == id);
    } catch (_) {
      return null;
    }
  }
}
