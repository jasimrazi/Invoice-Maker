/// Converts a double amount to words with capitalized format.
/// Example: 12345.67 becomes "Twelve Thousand Three Hundred And Forty Five Rupees And Sixty Seven Paise ONLY".
String convertAmountToWords(double amount) {
  int rupees = amount.floor();
  int paise = ((amount - rupees) * 100).round();

  String rupeesWords = _convertNumberToWords(rupees);
  String paiseWords = paise > 0 ? _convertNumberToWords(paise) : "";

  if (paise > 0) {
    return "${rupeesWords} Rupees And ${paiseWords} Paise Only";
  } else {
    return "${rupeesWords} Rupees Only";
  }
}

/// Helper function to convert an integer into capitalized words.
String _convertNumberToWords(int number) {
  if (number == 0) return "Zero";
  if (number < 0) return "Minus ${_convertNumberToWords(-number)}";

  final List<String> units = [
    "",
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
    "Ten",
    "Eleven",
    "Twelve",
    "Thirteen",
    "Fourteen",
    "Fifteen",
    "Sixteen",
    "Seventeen",
    "Eighteen",
    "Nineteen",
  ];
  final List<String> tens = [
    "",
    "",
    "Twenty",
    "Thirty",
    "Forty",
    "Fifty",
    "Sixty",
    "Seventy",
    "Eighty",
    "Ninety",
  ];

  String words = "";

  // Crore
  if ((number / 10000000).floor() > 0) {
    words += "${_convertNumberToWords((number / 10000000).floor())} Crore ";
    number %= 10000000;
  }
  // Lakh
  if ((number / 100000).floor() > 0) {
    words += "${_convertNumberToWords((number / 100000).floor())} Lakh ";
    number %= 100000;
  }
  // Thousand
  if ((number / 1000).floor() > 0) {
    words += "${_convertNumberToWords((number / 1000).floor())} Thousand ";
    number %= 1000;
  }
  // Hundred
  if ((number / 100).floor() > 0) {
    words += "${_convertNumberToWords((number / 100).floor())} Hundred ";
    number %= 100;
  }
  if (number > 0) {
    if (words.isNotEmpty) {
      words += "And ";
    }
    if (number < 20) {
      words += units[number];
    } else {
      words += tens[(number / 10).floor()];
      if ((number % 10) > 0) {
        words += " ${units[number % 10]}";
      }
    }
  }
  return words.trim();
}
