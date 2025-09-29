import 'package:flutter/material.dart';
import '../utils/color_constant.dart';

class CustomProgressView extends StatelessWidget {
  final String progressText;

  const CustomProgressView({super.key, required this.progressText});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      // Transparent black background
      child: Center(
        child: Container(
          width: 175,
          height: 150,
          decoration: BoxDecoration(
            color: ColorConstant.white,
            border: Border.all(
              color: ColorConstant.grey818C92,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: ColorConstant.green039661,
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 16),
                // Adjust the spacing between the CircularProgressIndicator and text
                Text(
                  progressText, // Use the progressText parameter
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorConstant.black_002F47,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
