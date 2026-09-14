import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';

class LoadingList extends StatelessWidget {
  const LoadingList({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceSolid,
      highlightColor: AppColors.surfaceElevated,
      period: const Duration(milliseconds: 1400),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: count,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          height: 92,
          decoration: BoxDecoration(
            color: AppColors.surfaceSolid,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
