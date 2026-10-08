class ParsedReceipt {
  const ParsedReceipt({
    required this.rawText,
    this.merchantName,
    this.totalAmount,
    this.transactionDate,
    this.merchantConfidence = 0,
    this.amountConfidence = 0,
    this.dateConfidence = 0,
  });

  final String? merchantName;
  final double? totalAmount;
  final DateTime? transactionDate;
  final String rawText;
  final double merchantConfidence;
  final double amountConfidence;
  final double dateConfidence;
}
