import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCustomerRow extends StatelessWidget {
  final double screenWidth;

  const ShimmerCustomerRow({Key? key, required this.screenWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Building ShimmerCustomerRow");

    // Get system brightness to switch between light & dark mode
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    // Colors for shimmer effect (adjusted for dark/light mode)
    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[500]! : Colors.grey[100]!;

    return Column(
      children: List.generate(
        4,
        (index) {
          print("Building row index: $index");
          return _ShimmerRow(
            baseColor: baseColor,
            highlightColor: highlightColor,
            screenWidth: screenWidth,
            isDarkMode: isDarkMode,
          );
        },
      ),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow({
    super.key,
    required this.baseColor,
    required this.highlightColor,
    required this.screenWidth,
    required this.isDarkMode,
  });

  final Color baseColor;
  final Color highlightColor;
  final double screenWidth;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    print("Building _ShimmerRow");

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left - Placeholder for Profile Icon
            Container(
              height: screenWidth * 0.12,
              width: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),

            // Right - Placeholder for Text
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    height: screenWidth * 0.045,
                    width: screenWidth * 0.5,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),

                  // Subtitle
                  Container(
                    height: screenWidth * 0.035,
                    width: screenWidth * 0.35,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.015),

                  // Extra info
                  Container(
                    height: screenWidth * 0.03,
                    width: screenWidth * 0.4,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}