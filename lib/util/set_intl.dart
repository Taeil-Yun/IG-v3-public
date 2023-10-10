import 'package:intl/intl.dart';

class SetIntl {
  dynamic numberFormat(dynamic number) {
    if (number == null) {
      return 0;
    }
    return NumberFormat('###,###,###,###').format(number);
  }
}