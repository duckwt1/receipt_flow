abstract final class MoneyParser {
  static double? parse(String raw) {
    var number = raw
        .replaceAll(RegExp(r'\s*(?:VND|VNĐ|đ|₫)\s*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s'), '');
    if (number.isEmpty) return null;

    if (number.contains(',') && number.contains('.')) {
      final decimalSeparator = number.lastIndexOf('.') > number.lastIndexOf(',') ? '.' : ',';
      final thousandsSeparator = decimalSeparator == '.' ? ',' : '.';
      number = number.replaceAll(thousandsSeparator, '');
      number = number.replaceFirst(decimalSeparator, '.');
    } else if (RegExp(r'[.,]\d{3}$').hasMatch(number)) {
      number = number.replaceAll(RegExp(r'[.,]'), '');
    } else {
      number = number.replaceAll(',', '.');
    }
    return double.tryParse(number);
  }
}
