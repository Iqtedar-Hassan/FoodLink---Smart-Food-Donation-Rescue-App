enum PickupRequestStatus { pending, approved, rejected, cancelled }

extension PickupRequestStatusX on PickupRequestStatus {
  String get label {
    switch (this) {
      case PickupRequestStatus.pending:
        return 'Pending';
      case PickupRequestStatus.approved:
        return 'Approved';
      case PickupRequestStatus.rejected:
        return 'Rejected';
      case PickupRequestStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class PickupRequest {
  PickupRequest({
    required this.id,
    required this.donationId,
    this.ngoId,
    required this.ngoName,
    this.ngoDescription = '',
    this.ngoWorkingArea = '',
    this.ngoCommunitiesServed = '',
    required this.requestedQuantity,
    required this.requestedUnit,
    required this.pickupDate,
    required this.submittedAt,
    required this.message,
    required this.status,
  });

  final String id;
  final String donationId;
  final String? ngoId;
  final String ngoName;
  final String ngoDescription;
  final String ngoWorkingArea;
  final String ngoCommunitiesServed;
  final num requestedQuantity;
  final String requestedUnit;
  final DateTime pickupDate;
  final DateTime submittedAt;
  final String message;
  PickupRequestStatus status;
}
