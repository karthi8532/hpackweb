import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hpackweb/utils/appcolor.dart';

class AppUtils {
  static void hideKeyboard(context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static String capitalize(String value) =>
      value.trim().length > 1 ? value.toUpperCase() : value;

  static void showSnackbar({
    required BuildContext context,
    required Widget message,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: message,
        backgroundColor: backgroundColor ?? Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static Future showSingleDialogPopup(
    BuildContext context,
    String title,
    String buttonname,
    Function onPressed,
    String? icons,
  ) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          icon:
              (icons != null)
                  ? Image.asset(icons, width: 80, height: 80)
                  : const SizedBox.shrink(),
          title: Text(
            title,
            maxLines: null,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                backgroundColor: WidgetStateProperty.all<Color>(
                  Appcolor.primary,
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Appcolor.primary),
                  ),
                ),
              ),
              onPressed: () => onPressed(),
              child: Text(buttonname, style: const TextStyle(fontSize: 14)),
            ),
          ],
        );
      },
    );
  }

  static Future showconfirmDialog(
    BuildContext context,
    String title,
    String yesstring,
    String nostring,
    VoidCallback onPressedYes,
    VoidCallback onPressedNo,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontSize: 12)),
          actions: [
            TextButton(onPressed: onPressedYes, child: Text(yesstring)),
            TextButton(onPressed: onPressedNo, child: Text(nostring)),
          ],
        );
      },
    );
  }

  static Widget buildHeaderText({final String? text}) {
    return Text(
      text.toString(),
      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
    );
  }

  static Widget buildNormalText({
    required String? text,
    Color? color,
    double fontSize = 12,
    TextAlign? textAlign,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    String? fontFamily,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    double? lineSpacing,
    FontStyle? fontStyle,
  }) {
    return Text(
      text ?? '--',
      textAlign: textAlign ?? TextAlign.left,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        decoration: decoration ?? TextDecoration.none,
        color: color ?? Colors.black,
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w400,
        letterSpacing: letterSpacing ?? 0,
        wordSpacing: wordSpacing ?? 0.0,
        height: lineSpacing,
        fontStyle: fontStyle ?? FontStyle.normal,
        fontFamily: fontFamily,
      ),
    );
  }

  static Widget iconWithText({
    required IconData icons,
    required String? text,
    MaterialColor? iconcolor,
    Color? color,
    double fontSize = 12,
    TextAlign? textAlign,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    String? fontFamily,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    double? lineSpacing,
    FontStyle? fontStyle,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icons, color: iconcolor ?? Colors.black),
        const SizedBox(width: 5),
        Text(
          text ?? '--',
          textAlign: textAlign ?? TextAlign.left,
          maxLines: maxLines,
          overflow: overflow,
          style: TextStyle(
            decoration: decoration ?? TextDecoration.none,
            color: color ?? Colors.black,
            fontSize: fontSize,
            fontWeight: fontWeight ?? FontWeight.w400,
            letterSpacing: letterSpacing ?? 0,
            wordSpacing: wordSpacing ?? 0.0,
            height: lineSpacing,
            fontStyle: fontStyle ?? FontStyle.normal,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  static void showBottomCupertinoDialog(
    BuildContext context, {
    required String? title,
    required VoidCallback btn1function,
    required VoidCallback btn2function,
  }) async {
    return showCupertinoModalPopup(
      context: context,
      builder:
          (_) => CupertinoActionSheet(
            title: Text(title.toString()),
            actions: [
              CupertinoActionSheetAction(
                onPressed: btn1function,
                child: const Text('Camera'),
              ),
              CupertinoActionSheetAction(
                onPressed: btn2function,
                child: const Text('Files'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
              child: const Text('Cancel'),
            ),
          ),
    );
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  static Widget bottomHanger(BuildContext context) {
    return Center(
      child: Container(
        height: 5,
        width: MediaQuery.of(context).size.width / 6,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  static void changeNodeFocus(
    BuildContext context, {
    FocusNode? current,
    FocusNode? next,
  }) {
    current?.unfocus();
    if (next != null) {
      FocusScope.of(context).requestFocus(next);
    }
  }

  static void errorsnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(message)),
    );
  }

  static void successsnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text(message)),
    );
  }

  static double averageRatings(List<int> ratings) {
    if (ratings.isEmpty) return 0;
    double avg = ratings.reduce((a, b) => a + b) / ratings.length;
    return avg;
  }

  static Widget gethanger(BuildContext context) {
    return Center(
      child: Container(
        height: 5,
        width: MediaQuery.of(context).size.width / 6,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
