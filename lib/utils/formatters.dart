/// Formats a number in Indian comma system: 12,50,000
String formatIndian(double value) {
  if (value < 0) return '-${formatIndian(-value)}';
  String numStr = value.round().toString();
  if (numStr.length <= 3) return numStr;
  String last3 = numStr.substring(numStr.length - 3);
  String remaining = numStr.substring(0, numStr.length - 3);
  String result = '';
  while (remaining.length > 2) {
    result = ',${remaining.substring(remaining.length - 2)}$result';
    remaining = remaining.substring(0, remaining.length - 2);
  }
  result = '$remaining$result,$last3';
  return result;
}

/// Formats as ₹ with Indian commas
String formatRupee(double value) => '₹${formatIndian(value)}';

/// Converts to short Indian notation (L, Cr)
String formatShortIndian(double value) {
  double v = value.abs();
  if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)} Cr';
  if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(2)} L';
  if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)} K';
  return '₹${v.toStringAsFixed(0)}';
}
