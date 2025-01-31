import 'package:flutter/widgets.dart';

class DeviceUtil {
  final double screenWidth;
  final double screenHeight;
  final double blockSizeHorizontal;
  final double blockSizeVertical;
  final double textMultiplier;
  final double imageSizeMultiplier;
  final double heightMultiplier;

  DeviceUtil._({
    required this.screenWidth,
    required this.screenHeight,
    required this.blockSizeHorizontal,
    required this.blockSizeVertical,
    required this.textMultiplier,
    required this.imageSizeMultiplier,
    required this.heightMultiplier,
  });

  static late DeviceUtil _instance;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    _instance = DeviceUtil._(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      blockSizeHorizontal: screenWidth / 100,
      blockSizeVertical: screenHeight / 100,
      textMultiplier: screenWidth / 100,
      imageSizeMultiplier: screenWidth / 100,
      heightMultiplier: screenHeight / 100,
    );
  }

  static DeviceUtil get instance => _instance;
}
