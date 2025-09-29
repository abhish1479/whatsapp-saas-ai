import 'dart:ui';

import 'package:flutter/material.dart';

class ColorConstant {
  static Color appColor = fromHex('#CF4B3D');
  static Color appColorLight = fromHex('#FFE9E7');
  static Color white = fromHex('#ffffff');
  static Color black = fromHex('#000000');
  static Color black182D1D = fromHex('#182D1D');
  static Color border911987 = fromHex('#911987');
  static Color blue525EC8 = fromHex('#525EC8');
  static Color blue3245B2 = fromHex('#3245B2');
  static Color blue2D3C93 = fromHex('#2D3C93');
  static Color orangeFCA300 = fromHex('#FCA300');
  static Color orangeE58200 = fromHex('#E58200');
  static Color yellowD8B203 = fromHex('#D8B203');
  static Color yellowLightFFF9F0 = fromHex('#FFF9F0');
  static Color yellowLightFEB137 = fromHex('#FEB137');
  static Color blueLightE2F8FF = fromHex('#E2F8FF');
  static Color greenLight77CA98 = fromHex('#77CA98');
  static Color green039661 = fromHex('#039661');
  static Color green00b524 = fromHex('#00b524');
  static Color lightBlue64B5F6 = fromHex('#64B5F6');
  static Color darkBlue1976D2 = fromHex('#0478FF');
  static Color whiteF0F0F3 = fromHex('#F0F0F3');
  static Color limeGreen77CA98 = fromHex('#77CA98');
  static Color darkGreen59AA79 = fromHex('#59AA79');
  static Color lightRedFFB196 = fromHex('#FFB196');
  static Color darkRedF88B64 = fromHex('#F88B64');
  static Color red = fromHex('#e10000');
  static Color appColorButton = fromHex('#CF4B3D');
  static Color black_002F47 = fromHex('#002F47');
  static Color grey757575 = fromHex('#757575');
  static Color greyF9F9F9 = fromHex('#F9F9F9');
  static Color grey737373 = fromHex('#737373');
  static Color grey_7D94A0 = fromHex('#7D94A0');
  static Color greyE0E0E0 = fromHex('#E0E0E0');
  static Color greyAAAAAA = fromHex('#AAAAAA');
  static Color greyDFDFDF = fromHex('#DFDFDF');
  static Color grey999999 = fromHex('#999999');
  static Color grey818C92 = fromHex('#818C92');
  static Color greyF2F3FB = fromHex('#F2F3FB');
  static Color greyDDDDDD = fromHex('#DDDDDD');
  static Color greydadbdd = fromHex('#dadbdd');
  static Color greyF4F6F8 = fromHex('#F4F6F8');
  static Color greyF8F8F8 = fromHex('#F8F8F8');
  static Color greyD2D2D2 = fromHex('#D2D2D2');
  static Color greyABABAB = fromHex('#ABABAB');
  static Color grey535F65 = fromHex('#535F65');
  static Color greyE3E6FF = fromHex('#E3E6FF');
  static Color grey979797 = fromHex('#979797');
  static Color greyF9F9FF = fromHex('#F9F9FF');
  static Color grey9d9fa1 = fromHex('#9d9fa1');
  static Color greyB4BADE = fromHex('#B4BADE');
  static Color black_171717 = fromHex('#171717');
  static Color blue_7878F0 = fromHex('#7878F0');
  static Color creamFFF2F0 = fromHex('#FFF2F0');
  static Color blue0E5AA7 = fromHex('#0E5AA7');
  static Color blue0E68C0 = fromHex('#0E68C0');
  static Color greenF1F8E9 = fromHex('#F1F8E9');
  static Color greenDAF7BB = fromHex('#DAF7BB');
  static Color greyE4EDF9 = fromHex('#E4EDF9');
  static Color colorDisableBtn = fromHex('#80EA1F2A');
  static Color lead_green = fromHex('#039661');
  static Color yellow_EE8B35 = fromHex('#EE8B35');
  static Color blueButton = fromHex('#0E5AA7');
  static Color blueFFBAC3ED = fromHex('#FFBAC3ED');
  static Color blueF3F5FE = fromHex('#F3F5FE');
  static Color colorToolbar = fromHex('#CF4B3D');
  static Color red_e3361e = fromHex('#e3361e');
  static Color estimate = fromHex('#FFE9E7');
  static Color white_FFFFFF = fromHex('#FFFFFF');
  static Color gray_7A = fromHex('#7A7A7A');
  static Color green_33691E = fromHex('#33691E');
  static Color dark_cream_FBCFCF = fromHex('#FBCFCF');
  static Color dark_white_F4F5F7 = fromHex('#F4F5F7');
  static Color light_green_ECF4EC = fromHex('#ECF4EC');
  static Color light_red_F4ECEC = fromHex('#F4ECEC');



  static Color gradient1 = fromHex('#FFC05C');
  static Color gradient2 = fromHex('#FFCD7D');

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class CustomColors {
  // A list of colors
  static List<Color> colorList = [
    Colors.blue, // Standard blue
    Colors.green, // Standard green
    Colors.orange, // Standard orange
    Colors.purple, // Standard purple
    Colors.red, // Standard red
    Colors.yellow, // Standard yellow
    Colors.cyan, // Standard cyan
    Colors.teal, // Standard teal
    Colors.indigo, // Standard indigo
    Colors.brown, // Standard brown
    Colors.grey, // Standard grey
    Colors.pink, // Standard pink
    Colors.amber, // Standard amber
    Colors.deepOrange, // Deep orange
    Colors.deepPurple, // Deep purple
    Colors.lime, // Lime green
    Colors.lightBlue, // Light blue
    Colors.lightGreen, // Light green// Light pink
    Colors.blueGrey, // Blue grey
    Color(0xFF607D8B), // Custom blue-grey
    Color(0xFFFFEB3B), // Custom yellow
    Color(0xFF4CAF50), // Custom green
    Color(0xFFCDDC39), // Custom lime
    Color(0xFF9E9D24),
    Color(0xFF8BC34A), // Custom light green
    Color(0xFF795548), // Custom brown
    Color(0xFF9C27B0), // Custom purple
    Color(0xFF00BCD4), // Custom cyan
  ];
}
