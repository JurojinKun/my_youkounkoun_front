import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Helpers {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static String formattingDate(DateTime date) {
    initializeDateFormatting();
    DateFormat format = DateFormat.yMMMd("fr_FR");

    return format.format(date).toString();
  }
}
