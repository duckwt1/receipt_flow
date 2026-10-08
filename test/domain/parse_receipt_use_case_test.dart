import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_flow/domain/use_cases/parse_receipt_use_case.dart';
import 'package:receipt_flow/domain/utils/money_parser.dart';

void main() {
  const parser = ParseReceiptUseCase();

  group('money parsing', () {
    test('normalizes user-entered currency values with locale separators', () {
      expect(MoneyParser.parse('150.000 đ'), 150000);
      expect(MoneyParser.parse('1,250,000 VND'), 1250000);
      expect(MoneyParser.parse('150,50'), 150.5);
    });

    test('supports Vietnamese and international thousands separators', () {
      for (final source in [
        'MINI MART\nTOTAL 150,000 VND',
        'MINI MART\nTOTAL 150.000 đ',
        'MINI MART\nTOTAL 150000 VND',
        'MINI MART\nTOTAL 150000đ',
        'MINI MART\nTOTAL 1.250.000',
        'MINI MART\nTOTAL 1,250,000',
      ]) {
        expect(parser(source).totalAmount, source.contains('1.') || source.contains('1,') ? 1250000 : 150000);
      }
    });

    test('prefers an amount near total keywords over a larger item amount', () {
      final receipt = parser('COFFEE SHOP\nEspresso 250000\nTOTAL AMOUNT 68000');
      expect(receipt.totalAmount, 68000);
      expect(receipt.amountConfidence, greaterThan(0.8));
    });
  });

  test('parses a valid date and rejects impossible dates', () {
    expect(parser('SHOP\n07/10/2026').transactionDate, DateTime(2026, 10, 7));
    expect(parser('SHOP\n07-10-2026').transactionDate, DateTime(2026, 10, 7));
    expect(parser('SHOP\n07.10.2026').transactionDate, DateTime(2026, 10, 7));
    expect(parser('SHOP\n31/02/2026').transactionDate, isNull);
  });

  test('selects an uppercase merchant line near the top', () {
    final receipt = parser('LOTUS COFFEE\nPhone: 0123456789\nTOTAL 45000');
    expect(receipt.merchantName, 'LOTUS COFFEE');
    expect(receipt.merchantConfidence, greaterThan(0.7));
  });
}
