import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The FoodLink brand mark: a rounded tile with the donation/hands icon used
/// consistently on the splash, login, and sign-up screens.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        Icons.volunteer_activism_rounded,
        color: AppColors.primaryGreen,
        size: size * 0.5,
      ),
    );
  }
}
