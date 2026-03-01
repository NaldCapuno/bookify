import 'package:flutter/material.dart';
import 'package:bookkeeping/core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    return Text(
      title,
      style: theme.textTheme.titleSmall!.copyWith(
        color: appColors.accentBlue,
      ),
    );
  }
}
