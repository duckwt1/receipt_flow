import '../models/parsed_receipt.dart';
import '../utils/money_parser.dart';

class ParseReceiptUseCase {
  const ParseReceiptUseCase();

  static final _totalKeyword = RegExp(
    r'(?:GRAND\s+TOTAL|TOTAL\s+AMOUNT|AMOUNT\s+DUE|TOTAL|TỔNG\s+TIỀN|TỔNG\s+CỘNG|THÀNH\s+TIỀN|PHẢI\s+TRẢ|THANH\s+TOÁN)',
    caseSensitive: false,
  );
  static final _money = RegExp(
    r'(?<![\w/])(?:\d{1,3}(?:[.,]\d{3})+|\d{4,})(?:[.,]\d{1,2})?\s*(?:VND|VNĐ|đ|₫)?(?!\w)',
    caseSensitive: false,
  );
  static final _date = RegExp(r'(?<!\d)(\d{1,2})[./-](\d{1,2})[./-](\d{4})(?!\d)');
  static final _phone = RegExp(r'^(?:\+?\d[\d ()-]{7,}\d)$');
  static final _dateLine = RegExp(r'^\d{1,2}[./-]\d{1,2}[./-]\d{4}$');
  static final _address = RegExp(
    r'\b(\d+\s+.+\b(?:street|st\.?|road|rd\.?|avenue|ave\.?|district|ward|huyện|quận|đường|phường)\b)',
    caseSensitive: false,
  );
  static final _excludedMerchant = RegExp(
    r'(TOTAL|SUBTOTAL|TAX|VAT|CASH|CHANGE|THANK|RECEIPT|INVOICE|PHONE|HOTLINE|DATE|TIME|TỔNG|TIỀN|THANH TOÁN|HÓA ĐƠN|ĐỊA CHỈ)',
    caseSensitive: false,
  );

  ParsedReceipt call(String rawText) {
    final lines = rawText
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    final merchant = _parseMerchant(lines);
    final amount = _parseAmount(lines);
    final date = _parseDate(rawText);
    return ParsedReceipt(
      rawText: rawText,
      merchantName: merchant?.$1,
      merchantConfidence: merchant?.$2 ?? 0,
      totalAmount: amount?.$1,
      amountConfidence: amount?.$2 ?? 0,
      transactionDate: date?.$1,
      dateConfidence: date?.$2 ?? 0,
    );
  }

  (String, double)? _parseMerchant(List<String> lines) {
    for (var i = 0; i < lines.length && i < 8; i++) {
      final line = lines[i];
      if (line.length < 2 || line.length > 50) continue;
      if (_money.hasMatch(line) || _dateLine.hasMatch(line) || _phone.hasMatch(line)) continue;
      if (_address.hasMatch(line) || _excludedMerchant.hasMatch(line)) continue;
      final letters = line.replaceAll(RegExp(r'[^A-Za-zÀ-ỹ]'), '');
      if (letters.length < 3) continue;
      final upperCount = RegExp('[A-ZÀ-Ỹ]').allMatches(letters).length;
      final uppercaseRatio = upperCount / letters.length;
      return (line, i < 3 ? (uppercaseRatio > 0.65 ? 0.88 : 0.72) : 0.58);
    }
    return null;
  }

  (double, double)? _parseAmount(List<String> lines) {
    final candidates = <({double value, int score, int order})>[];
    for (var i = 0; i < lines.length; i++) {
      for (final match in _money.allMatches(lines[i])) {
        final value = MoneyParser.parse(match.group(0)!);
        if (value == null || value <= 0) continue;
        final before = lines[i].substring(0, match.start);
        final after = lines[i].substring(match.end);
        final keywordNearby = _totalKeyword.hasMatch(before) ||
            _totalKeyword.hasMatch(after) ||
            (i > 0 && _totalKeyword.hasMatch(lines[i - 1])) ||
            (i + 1 < lines.length && _totalKeyword.hasMatch(lines[i + 1]));
        candidates.add((
          value: value,
          score: keywordNearby ? 100 : 0,
          order: i * 1000 + match.start,
        ));
      }
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final score = b.score.compareTo(a.score);
      return score != 0 ? score : b.order.compareTo(a.order);
    });
    final best = candidates.first;
    final confidence = best.score > 0 ? 0.95 : (candidates.length == 1 ? 0.56 : 0.38);
    return (best.value, confidence);
  }

  (DateTime, double)? _parseDate(String text) {
    final match = _date.firstMatch(text);
    if (match == null) return null;
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    if (year < 1900 || year > 2200 || month < 1 || month > 12 || day < 1) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) return null;
    return (date, 0.96);
  }
}
