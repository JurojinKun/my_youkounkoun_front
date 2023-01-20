import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  static Future<void> launchMyUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url));
    } else {
      throw 'cannot open $url';
    }
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static String formattingDate(DateTime date, String localeLanguage) {
    initializeDateFormatting();
    DateFormat format = localeLanguage == "fr"
        ? DateFormat.yMMMd("fr")
        : DateFormat.yMMMd("en");

    return format.format(date).toString();
  }

  static String dateFormat(String dateString) {
    String dateFormated = "";
    DateTime date;
    if (dateString.contains("00:00")) {
      date = DateFormat('yyyy-MM-dd hh:mm').parse(dateString);
    } else {
      date = DateFormat('yyyy-MM-dd').parse(dateString);
    }
    dateFormated = DateFormat('dd/MM/yyyy').format(date);
    return dateFormated;
  }

  static DateTime convertStringToDateTime(String dateString) {
    DateTime date;
    if (dateString.contains("00:00")) {
      date = DateFormat('yyyy-MM-dd hh:mm').parse(dateString);
    } else {
      date = DateFormat('yyyy-MM-dd').parse(dateString);
    }
    return date;
  }

  static String differenceDatetimeNowAndOther(DateTime dateTime) {
    String timeString = "";

    DateTime dateNow = DateTime.now();
    int difference = dateNow.difference(dateTime).inHours;

    if (difference < 1) {
      difference = dateNow.difference(dateTime).inMinutes;
      if (difference < 1) {
        timeString = "now";
      } else {
        timeString = "${difference.toString()}min";
      }
    } else if (difference >= 1 && difference < 24) {
      timeString = "${difference.toString()}h";
    } else if (difference >= 24 && difference < 168) {
      difference = dateNow.difference(dateTime).inDays;
      timeString = "${difference.toString()}j";
    } else {
      difference = (dateNow.difference(dateTime).inDays ~/ 7);
      timeString = "${difference.toString()}sem";
    }

    return timeString;
  }
}
