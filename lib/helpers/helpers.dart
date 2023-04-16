import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  static Future<void> launchMyUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url));
    } else {
      throw 'cannot open $url';
    }
  }

  static Future<void> launchStore(String urlAndroid, String urliOS) async {
    String url;
    if (Platform.isIOS) {
      url = urliOS;
    } else {
      url = urlAndroid;
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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

  static String readTimeStamp(BuildContext context, int timestamp) {
    DateTime dateNow = DateTime.now();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
    Duration difference = dateNow.difference(date);

    String timestampString = "";

    // if (difference.inDays > 365) {
    //   return "${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? "an" : "ans"}";
    // }
    // if (difference.inDays > 30) return "${(difference.inDays / 30).floor()}mois";
    if (difference.inDays > 7) {
      timestampString =
          "${(difference.inDays / 7).floor()}${AppLocalization.of(context).translate("general", "weeks")}";
    } else if (difference.inDays > 0) {
      timestampString =
          "${difference.inDays}${AppLocalization.of(context).translate("general", "days")}";
    } else if (difference.inHours > 0) {
      timestampString =
          "${difference.inHours}${AppLocalization.of(context).translate("general", "hours")}";
    } else if (difference.inMinutes > 0) {
      timestampString =
          "${difference.inMinutes}${AppLocalization.of(context).translate("general", "minutes")}";
    } else {
      timestampString = AppLocalization.of(context).translate("general", "now");
    }

    return timestampString;
  }

  // Convertir le timestamp en heure et minutes formatées
  static String formatDateHoursMinutes(int timestamp, String locale) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
    var formattedTime = DateFormat('HH:mm', locale).format(date);
    return formattedTime;
  }

  // Récupérer le jour de la semaine, la date du jour et le mois formatés
  static String formatDateDayWeek(
      int timestamp, String locale, bool withHours) {
    DateTime dateNow = DateTime.now();
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
    Duration difference = dateNow.difference(date);

    if (withHours) {
      if (difference.inHours <= 24) {
        return "Aujourd'hui";
      } else if (difference.inHours > 24 && difference.inHours <= 48) {
        return "Hier";
      } else {
        String formattedDate = "";
        if (date.year == DateTime.now().year) {
          formattedDate = DateFormat('EEE d MMM', locale).format(date);
        } else {
          formattedDate = DateFormat('d MMM y', locale).format(date);
        }
        return formattedDate;
      }
    } else {
      String formattedDate = "";
      if (date.year == DateTime.now().year) {
        formattedDate = DateFormat('EEE d MMM', locale).format(date);
      } else {
        formattedDate = DateFormat('d MMM y', locale).format(date);
      }
      return formattedDate;
    }
  }

  static SystemUiOverlayStyle uiOverlayApp(BuildContext context) {
    SystemUiOverlayStyle uiOverlay;

    if (Theme.of(context).brightness == Brightness.light) {
      if (Platform.isIOS) {
        uiOverlay = SystemUiOverlayStyle.dark;
      } else {
        uiOverlay = SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
            systemNavigationBarIconBrightness: Brightness.dark);
      }
    } else {
      if (Platform.isIOS) {
        uiOverlay = SystemUiOverlayStyle.light;
      } else {
        uiOverlay = SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
            systemNavigationBarIconBrightness: Brightness.light);
      }
    }

    return uiOverlay;
  }

  static Color uiApp(BuildContext context) {
    Color ui;

    if (Theme.of(context).brightness == Brightness.light) {
      ui = cBlack;
    } else {
      ui = cWhite;
    }

    return ui;
  }

  static Map<int, Color> getSwatch(Color color) {
    final hslColor = HSLColor.fromColor(color);
    final lightness = hslColor.lightness;

    /// if [500] is the default color, there are at LEAST five
    /// steps below [500]. (i.e. 400, 300, 200, 100, 50.) A
    /// divisor of 5 would mean [50] is a lightness of 1.0 or
    /// a color of #ffffff. A value of six would be near white
    /// but not quite.
    const lowDivisor = 6;

    /// if [500] is the default color, there are at LEAST four
    /// steps above [500]. A divisor of 4 would mean [900] is
    /// a lightness of 0.0 or color of #000000
    const highDivisor = 5;

    final lowStep = (1.0 - lightness) / lowDivisor;
    final highStep = lightness / highDivisor;

    return {
      50: (hslColor.withLightness(lightness + (lowStep * 5))).toColor(),
      100: (hslColor.withLightness(lightness + (lowStep * 4))).toColor(),
      200: (hslColor.withLightness(lightness + (lowStep * 3))).toColor(),
      300: (hslColor.withLightness(lightness + (lowStep * 2))).toColor(),
      400: (hslColor.withLightness(lightness + lowStep)).toColor(),
      500: (hslColor.withLightness(lightness)).toColor(),
      600: (hslColor.withLightness(lightness - highStep)).toColor(),
      700: (hslColor.withLightness(lightness - (highStep * 2))).toColor(),
      800: (hslColor.withLightness(lightness - (highStep * 3))).toColor(),
      900: (hslColor.withLightness(lightness - (highStep * 4))).toColor(),
    };
  }

  static Color stringToColor(String colorString) {
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static String colorToString(Color color) {
    String hexaString =
        "#${color.value.toRadixString(16).substring(2).toUpperCase()}";
    return hexaString;
  }

  static String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      double k = number / 1000;
      if (k % 1 == 0) {
        return '${k.toInt()}k';
      } else {
        return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
      }
    } else if (number < 1000000000) {
      double m = number / 1000000;
      if (m % 1 == 0) {
        return '${m.toInt()}m';
      } else {
        return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}m';
      }
    } else {
      double b = number / 1000000000;
      if (b % 1 == 0) {
        return '${b.toInt()}b';
      } else {
        return '${b.toStringAsFixed(b.truncateToDouble() == b ? 0 : 1)}b';
      }
    }
  }
}
