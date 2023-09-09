import 'package:intl/intl.dart';

class currencyFormat {
  static String convertToIdr(dynamic number) {
    NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return currencyFormatter.format(number);
  }
}
