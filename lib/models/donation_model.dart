class Donation {
  final String id;
  final String foodName;
  final String foodType;
  final int quantity;
  final String location;
  final DateTime safeUseDate;
  String status;

  Donation({
    required this.id,
    required this.foodName,
    required this.foodType,
    required this.quantity,
    required this.location,
    required this.safeUseDate,
    this.status = 'Available',
  });
}
