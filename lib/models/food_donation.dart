enum DonationStatus { available, reserved, collected, delivered, cancelled }

extension DonationStatusX on DonationStatus {
  String get label {
    switch (this) {
      case DonationStatus.available:
        return 'Available';
      case DonationStatus.reserved:
        return 'Reserved';
      case DonationStatus.collected:
        return 'Collected';
      case DonationStatus.delivered:
        return 'Delivered';
      case DonationStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class FoodDonation {
  FoodDonation({
    required this.id,
    required this.donorId,
    required this.foodName,
    required this.category,
    required this.quantity,
    required this.quantityUnit,
    required this.safeUseDeadline,
    required this.pickupStart,
    required this.pickupEnd,
    required this.pickupArea,
    required this.pickupAddress,
    required this.notes,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String donorId;
  final String foodName;
  final String category;
  final num quantity;
  final String quantityUnit;
  final DateTime safeUseDeadline;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final String pickupArea;
  final String pickupAddress;
  final String notes;
  final DateTime createdAt;
  DonationStatus status;

  FoodDonation copyWith({
    String? foodName,
    String? category,
    num? quantity,
    String? quantityUnit,
    DateTime? safeUseDeadline,
    DateTime? pickupStart,
    DateTime? pickupEnd,
    String? pickupArea,
    String? pickupAddress,
    String? notes,
    DonationStatus? status,
  }) {
    return FoodDonation(
      id: id,
      donorId: donorId,
      foodName: foodName ?? this.foodName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      safeUseDeadline: safeUseDeadline ?? this.safeUseDeadline,
      pickupStart: pickupStart ?? this.pickupStart,
      pickupEnd: pickupEnd ?? this.pickupEnd,
      pickupArea: pickupArea ?? this.pickupArea,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}
