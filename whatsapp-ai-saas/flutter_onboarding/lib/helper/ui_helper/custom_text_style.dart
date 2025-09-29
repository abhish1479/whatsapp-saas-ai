import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/color_constant.dart';

class CustomStyle {
  static TextStyle styleInputText = TextStyle(
      fontSize: 14,
      fontFamily: 'Lato',
      color: ColorConstant.black_171717,
      fontWeight: FontWeight.w600);

  static OutlineInputBorder borderInputUnFocused = OutlineInputBorder(
    borderSide: BorderSide(color: ColorConstant.grey818C92),
  );

  static OutlineInputBorder borderInputFocused = OutlineInputBorder(
    borderSide: BorderSide(color: ColorConstant.black_002F47),
  );

  static TextStyle styleLabelInput = TextStyle(
      fontSize: 16,
      color: ColorConstant.grey818C92,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w400);

  static TextStyle styleLabelInputFloating = TextStyle(
      fontSize: 19,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w400);

  static TextStyle styleInputHint = TextStyle(
      fontSize: 16,
      color: ColorConstant.grey818C92,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w400);

  static TextStyle styleInputError = const TextStyle(
      color: Colors.red,
      fontSize: 16,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w500);

  static OutlineInputBorder borderInputError = const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.red,
    ),
  );

  static TextStyle textStyleBlack26Lato = TextStyle(
      fontSize: 26,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      letterSpacing: 2,
      fontWeight: FontWeight.w400);

  static TextStyle textStyleBlack22 = TextStyle(
      fontSize: 22,
      color: ColorConstant.black_171717,
      fontFamily: 'Lato',
      letterSpacing: 2,
      fontWeight: FontWeight.w600);

  static TextStyle textStyleBlack20 = TextStyle(
      fontSize: 20,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleBlack20Lato = TextStyle(
      fontSize: 20,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      height: 1.5,
      fontWeight: FontWeight.w400);

  static TextStyle textStyleBlack19 = TextStyle(
      fontSize: 19,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleBlack18 = TextStyle(
      fontSize: 18,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleBlack18Lato = TextStyle(
      fontSize: 18,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w700);

  static TextStyle textStyleBlack17 = TextStyle(
      fontSize: 17,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleBlack16 = TextStyle(
      fontSize: 16,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      height: 1.5,
      fontWeight: FontWeight.w600);

  static TextStyle textStyleBlack16Bold = TextStyle(
      fontSize: 16,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleBlack14 = TextStyle(
      fontSize: 14,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleBlack15Bold = TextStyle(
      fontSize: 14,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleBlack15 = TextStyle(
      fontSize: 15,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleBlack13 = TextStyle(
      fontSize: 13,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleBlack12 = TextStyle(
      fontSize: 12,
      color: ColorConstant.black_002F47,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleGrey16 = TextStyle(
      fontSize: 16,
      color: ColorConstant.grey535F65,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleGrey14_600 = TextStyle(
      fontSize: 14,
      color: ColorConstant.grey535F65,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600);

  static TextStyle textStyleGrey14_700 = TextStyle(
      fontSize: 14,
      color: ColorConstant.grey535F65,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w700);

  static TextStyle textStyleGrey14_500 = TextStyle(
      fontSize: 14,
      color: ColorConstant.grey535F65,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w500);

  static TextStyle textStyleGrey13 = TextStyle(
      fontSize: 13,
      color: ColorConstant.grey818C92,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w500);

  static TextStyle textStyleGrey12 = TextStyle(
      fontSize: 12,
      color: ColorConstant.grey818C92,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w400);

  static TextStyle textStyleGrey11 = TextStyle(
      fontSize: 11,
      color: ColorConstant.grey818C92,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w400);

  static TextStyle textStyleGrey10 = TextStyle(
      fontSize: 10,
      color: ColorConstant.grey818C92,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w400);

  static TextStyle styleButtonText18Lato = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w500);

  static TextStyle styleButtonText16Lato = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w500);

  static TextStyle styleButtonText14Lato = const TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    letterSpacing: 1.1,
  );

  static TextStyle textStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
        fontSize: fontSize ?? 14,
        color: color ?? ColorConstant.black_002F47,
        fontFamily: 'Lato',
        fontWeight: fontWeight ?? FontWeight.w500);
  }

  static ButtonStyle styleButtonBlue = ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
      (states) {
        if (states.contains(MaterialState.disabled)) {
          return ColorConstant.greyD2D2D2;
        }
        return ColorConstant.blue3245B2;
      },
    ),
    shape: MaterialStateProperty.all<ContinuousRectangleBorder>(
      ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
    ),
    elevation:
        MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return 8; // Increase elevation when pressed
      }
      return 5; // Default elevation
    }),
    shadowColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      return ColorConstant.blue2D3C93;
    }),
    overlayColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return ColorConstant.blue3245B2
            .withOpacity(0.5); // Overlay color when pressed
      }
      return Colors.transparent;
    }),
  );

  static ButtonStyle styleButtonLight = ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
      (states) {
        return ColorConstant.appColorLight;
      },
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
  );
}
