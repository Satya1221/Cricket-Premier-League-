/// Cricket broadcast-style currency formatting. Amounts are in crore rupees.
class CricketCurrency {
  const CricketCurrency._();

  static String format(double amountInCrores) {
    if (!amountInCrores.isFinite || amountInCrores < 0) {
      throw ArgumentError.value(amountInCrores, 'amountInCrores', 'Must be finite and non-negative.');
    }
    if (amountInCrores >= 1) return '₹${amountInCrores.toStringAsFixed(2)} Cr';
    final lakhs = amountInCrores * 100;
    if (lakhs < 1) return '₹${(lakhs * 100).round()} thousand';
    return '₹${lakhs.toStringAsFixed(lakhs == lakhs.roundToDouble() ? 0 : 2)} lakh';
  }

  static String formatCompact(double amountInCrores) {
    if (amountInCrores >= 1) return '₹${amountInCrores.toStringAsFixed(2)} Cr';
    return '₹${(amountInCrores * 100).toStringAsFixed(0)} L';
  }
}
