/// Cricket broadcast-style currency formatting. Amounts are in crore rupees.
class CricketCurrency {
  const CricketCurrency._();

  static String format(double amountInCrores) {
    if (!amountInCrores.isFinite || amountInCrores < 0) return '₹—';
    if (amountInCrores >= 1) return '₹${amountInCrores.toStringAsFixed(2)} Cr';
    final lakhs = amountInCrores * 100;
    if (lakhs < 1) return '₹${(lakhs * 100).round()} thousand';
    return '₹${lakhs.toStringAsFixed(lakhs == lakhs.roundToDouble() ? 0 : 2)} lakh';
  }


  /// Formats rupees with Indian digit grouping (e.g. ₹12,34,567).
  static String formatRupees(num amount) {
    if (!amount.isFinite) return '₹—';
    final negative = amount < 0;
    final digits = amount.abs().round().toString();
    if (digits.length <= 3) return '${negative ? '−' : ''}₹$digits';

    final lastThree = digits.substring(digits.length - 3);
    var leading = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (leading.length > 2) {
      groups.insert(0, leading.substring(leading.length - 2));
      leading = leading.substring(0, leading.length - 2);
    }
    if (leading.isNotEmpty) groups.insert(0, leading);
    return '${negative ? '−' : ''}₹${groups.join(',')},$lastThree';
  }

  static String formatCompact(double amountInCrores) {
    if (!amountInCrores.isFinite || amountInCrores < 0) return '₹—';
    if (amountInCrores >= 1) return '₹${amountInCrores.toStringAsFixed(2)} Cr';
    return '₹${(amountInCrores * 100).toStringAsFixed(0)} L';
  }
}
