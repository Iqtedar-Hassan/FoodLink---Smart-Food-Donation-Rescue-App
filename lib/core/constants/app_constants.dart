class AppConstants {
  static const String appTitle = 'FoodLink';
  static const String demoEmail = 'donor@foodlink.demo';
  static const String demoPassword = 'Pass1234';

  /// Donor type options shown at sign-up and on the profile screen.
  static const List<String> donorTypes = [
    'Household',
    'Restaurant',
    'Bakery',
    'Supermarket',
  ];

  /// Food category options used by the Create/Edit Donation form.
  static const List<String> foodCategories = [
    'Cooked Meals',
    'Bakery Items',
    'Fruits',
    'Vegetables',
    'Dairy Products',
    'Packaged Food',
    'Other',
  ];

  /// Quantity unit options used by the Create/Edit Donation form.
  static const List<String> quantityUnits = [
    'Kilograms',
    'Portions',
    'Boxes',
    'Packs',
    'Items',
    'Grams',
    'Litres',
  ];

  /// All NGOs and pickup requests in this prototype are local sample data,
  /// never real verified organizations.
  static const String demoDataNote =
      'All organizations and requests are local demo data.';
}
