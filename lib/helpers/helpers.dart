import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
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

  static double paddingSnackBarSwitchScreen(String currentRouteApp) {
    switch (currentRouteApp) {
      case bottomNav:
        return 80.0;
      default:
        return 20.0;
    }
  }
}
