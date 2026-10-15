import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Inline loading content for a full-width primary button (e.g. "Logging in…").
/// Keeps the button height stable and shows a spinner beside a clear label.
class ButtonLoading extends StatelessWidget {
  const ButtonLoading({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.white),
          ),
        ),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}
