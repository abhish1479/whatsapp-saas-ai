import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../ui_helper/custom_text_style.dart';
import 'app_loger.dart';
import 'color_constant.dart';


class AppUtils {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      // Duration for the toast message (Toast.LENGTH_SHORT or Toast.LENGTH_LONG)
      gravity: ToastGravity.CENTER,
      // Position of the toast message (ToastGravity.TOP, ToastGravity.CENTER, or ToastGravity.BOTTOM)
      backgroundColor: ColorConstant.appColor,
      // Background color of the toast
      textColor: ColorConstant.white,
      // Text color of the toast
      fontSize: 16.0, // Font size of the text
    );
  }

  static void showToastLong(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: ColorConstant.white,
      textColor: ColorConstant.black182D1D,
      fontSize: 16.0,
    );
  }

  static void errorToast(BuildContext context, String message, int second) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 240.0,
        left: 20.0,
        right: 20.0,
        child: Material(
          elevation: 20.0,
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: ColorConstant.appColorLight,
                width: 1.5,
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: ColorConstant.black_002F47,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lato',
                height: 1.5,
                letterSpacing: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // Insert the toast into the overlay
    overlay.insert(overlayEntry);

    // Remove the toast after a delay
    Future.delayed(Duration(seconds: second), () {
      overlayEntry.remove();
    });
  }

  static void infoToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 240.0,
        left: 20.0,
        right: 20.0,
        child: Material(
          elevation: 20.0,
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: ColorConstant.yellowD8B203,
                width: 2.0,
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: ColorConstant.black_002F47,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lato',
                height: 1.5,
                letterSpacing: 1.1,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    );

    // Insert the toast into the overlay
    overlay.insert(overlayEntry);

    // Remove the toast after a delay
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  static void positiveToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 250.0,
        left: 15.0,
        right: 15.0,
        child: Material(
          elevation: 20.0,
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Color(0xFFC8E6C9),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Colors.green,
                width: 2.0,
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: Colors.green,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lato',
                height: 1.8,
                letterSpacing: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // Insert the toast into the overlay
    overlay.insert(overlayEntry);

    // Remove the toast after a delay
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  // Static method to show a simple alert dialog
  static void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: CustomStyle.textStyleBlack20Lato,
          ),
          content: Text(
            message,
            style: CustomStyle.textStyleBlack16,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK',
                  style: TextStyle(
                      color: ColorConstant.appColor,
                      fontSize: 16,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Static method to show a snackbar
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // method defined to check internet connectivity
  static Future<bool> isConnected() async {
    /*var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult[0] == ConnectivityResult.none) {
      return false;
    } else if (connectivityResult[0] == ConnectivityResult.wifi) {
      return true;
    } else if (connectivityResult[0] == ConnectivityResult.mobile) {
      return true;
    }
    return false;*/

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      AppLogger.error('❌ Failed to connect internet', tag: AppLogger.api);
      return false;
    }
    // Attempt to lookup a reliable address (e.g., Google)
    try {
      final result = await InternetAddress.lookup('login.mymobiforce.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final networkType = await Connectivity().checkConnectivity();
        // final ip = result.isNotEmpty ? result[0].address : 'Unavailable';
        AppLogger.info('✅ Internet connected, NetworkType: $networkType',
            tag: AppLogger.api);
        return true;
      }
      AppLogger.error('❌ Failed to connect internet', tag: AppLogger.api);
      return false;
    } catch (e) {
      AppLogger.error('❌ Failed to connect internet', tag: AppLogger.api);
      return false;
    }
  }

  static bool isEmailValid(String email) {
    // Regular expression pattern for a valid email address
    final RegExp emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    );

    return emailRegex.hasMatch(email);
  }

  static bool isDateToday(DateTime dateToCheck) {
    DateTime now = DateTime.now();
    return now.year == dateToCheck.year &&
        now.month == dateToCheck.month &&
        now.day == dateToCheck.day;
  }

  static String monthNumberToString(int monthNumber) {
    // Create a DateTime object with the given month number (1-12).
    // The day doesn't matter, so we use 1.
    DateTime dateTime = DateTime(DateTime.now().year, monthNumber, 1);

    // Use DateFormat to format the month as a 3-letter abbreviation.
    DateFormat formatter = DateFormat.MMM(); // Use 'MMM' for the abbreviation.
    return formatter.format(dateTime);
  }

  static String getDayStringFromDate(DateTime dateTime) {
    // Define the format to get the day of the week (full, abbreviated, or short)
    DateFormat format = DateFormat
        .E(); // Use 'E' for abbreviated (e.g., Mon), 'EEEE' for full (e.g., Monday)

    // Get the day of the week
    String dayOfWeek = format.format(dateTime);
    return dayOfWeek;
  }

  static String generateRandom16DigitNumber() {
    Random random = Random();
    String randomNumber = '';

    // Generate each digit
    for (int i = 0; i < 16; i++) {
      randomNumber += random.nextInt(10).toString();
    }

    return randomNumber;
  }

  static String getNextDaysOfDate(String startDate, int howManyDays) {
    String returnDate = "";
    try {
      final DateFormat sdf = DateFormat('yyyy-MM-dd');
      DateTime date = sdf.parse(startDate);
      date = date.subtract(const Duration(days: 1)); // going a day previous

      for (int i = 0; i <= howManyDays; i++) {
        date = date.add(const Duration(days: 1));
        if (i == howManyDays) {
          returnDate = sdf.format(date);
        }
      }
    } catch (e) {
      return returnDate;
    }
    return returnDate;
  }

  static DateTime? convertStringToDateFormat(String date) {
    try {
      final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      return formatter.parse(date);
    } catch (e) {
      print("Error parsing date: $e");
      return null;
    }
  }

  static String todayDateString() {
    final now = DateTime.now();
    final today =
    DateTime(now.year, now.month, now.day); // sets time to 00:00:00
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(today);
  }

  static String todayDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }


  static String tomorrowDate() {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(tomorrow);
  }

  static String generateRandom4DigitNumber() {
    Random random = Random();
    String randomNumber = '';

    // Generate each digit
    for (int i = 0; i < 4; i++) {
      randomNumber += random.nextInt(10).toString();
    }

    return randomNumber;
  }

  static List<String> removeDuplicates(List<String> listWithDuplicates) {
    /*// Convert list to set to remove duplicates
    Set<String> setWithoutDuplicates = listWithDuplicates.toSet();

    // Convert set back to list
    List<String> listWithoutDuplicates = setWithoutDuplicates.toList();

    return listWithoutDuplicates;*/

    List<String> listWithoutDuplicates = [];
    Set<String> seen = Set<String>();

    for (String item in listWithDuplicates) {
      if (!seen.contains(item)) {
        seen.add(item);
      }
    }

    List<String> newList = seen.toList();
    return newList;
  }

}

