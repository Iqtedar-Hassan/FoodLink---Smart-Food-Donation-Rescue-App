import '../models/donation_model.dart';

class DonationData {
  static final List<Donation> donations = [
    Donation(
      id: '1',
      foodName: 'Cooked Rice',
      foodType: 'Cooked Food',
      quantity: 10,
      location: 'Islamabad',
      safeUseDate: DateTime.now().add(const Duration(hours: 5)),
    ),
    Donation(
      id: '2',
      foodName: 'Fresh Bread',
      foodType: 'Bakery',
      quantity: 20,
      location: 'Rawalpindi',
      safeUseDate: DateTime.now().add(const Duration(hours: 8)),
    ),
    Donation(
      id: '3',
      foodName: 'Fresh Vegetables',
      foodType: 'Fruits and Vegetables',
      quantity: 5,
      location: 'Islamabad',
      safeUseDate: DateTime.now().add(const Duration(days: 1)),
    ),
  ];
}
