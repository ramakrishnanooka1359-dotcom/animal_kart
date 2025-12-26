class FormatUtils {
  // Indian numbering system: 1,88,000 instead of 188,000
  static String formatAmount(num amount) { 
    final double amountAsDouble = amount.toDouble();
    
    if ((amountAsDouble - amountAsDouble.truncate()).abs() < 0.00001) {
      return _formatIndianNumber(amountAsDouble.truncate().toString());
    } else {
      final parts = amountAsDouble.toStringAsFixed(2).split('.');
      final integerPart = parts[0];
      final decimalPart = parts[1];
      
      return '${_formatIndianNumber(integerPart)}.$decimalPart';
    }
  }
  
  
  static String _formatIndianNumber(String numberStr) {
    // Remove any existing commas
    String cleanStr = numberStr.replaceAll(',', '');
    
    
    bool isNegative = false;
    if (cleanStr.startsWith('-')) {
      isNegative = true;
      cleanStr = cleanStr.substring(1);
    }
    
    // For Indian numbering system:
    // - Last 3 digits are grouped together
    // - Then every 2 digits are grouped
    
    String result = '';
    int length = cleanStr.length;
    
    if (length <= 3) {
      result = cleanStr;
    } else {
      // Get the last 3 digits
      result = cleanStr.substring(length - 3);
      
      // Process remaining digits in groups of 2
      int remaining = length - 3;
      while (remaining > 0) {
        int start = remaining - 2;
        if (start < 0) start = 0;
        String group = cleanStr.substring(start, remaining);
        result = group + ',' + result;
        remaining = start;
      }
    }
    
    return isNegative ? '-$result' : result;
  }
  
  // Alternative: Using regex for Indian numbering
  // static String _formatIndianNumberRegex(String numberStr) {
  //   // Remove any existing commas
  //   String cleanStr = numberStr.replaceAll(',', '');
    
  //   // Handle negative numbers
  //   bool isNegative = false;
  //   if (cleanStr.startsWith('-')) {
  //     isNegative = true;
  //     cleanStr = cleanStr.substring(1);
  //   }
    
  //   // Regex for Indian numbering:
  //   // 1. First 3 digits from right: (\d{3})
  //   // 2. Then every 2 digits: (\d{2})*
  //   String formatted = cleanStr.replaceAllMapped(
  //     RegExp(r'(\d{2})(\d{3})$'),
  //     (Match m) => '${m[1]},${m[2]}',
  //   );
    
  //   // If there are more digits, add more commas
  //   formatted = formatted.replaceAllMapped(
  //     RegExp(r'(\d+)(\d{2},\d{3})$'),
  //     (Match m) => '${m[1]},${m[2]}',
  //   );
    
  //   return isNegative ? '-$formatted' : formatted;
  // }
  
  // Simple Indian formatter using a different approach
  static String formatIndianNumber(num number) {
    String numberStr = number.toString();
    
    // Handle decimal numbers
    List<String> parts = numberStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Format integer part with Indian numbering
    String formattedInteger = _formatIndianNumberSimple(integerPart);
    
    // Combine with decimal part if exists
    if (decimalPart.isNotEmpty) {
      return '$formattedInteger.$decimalPart';
    } else {
      return formattedInteger;
    }
  }
  
  // Simple implementation of Indian numbering
  static String _formatIndianNumberSimple(String numberStr) {
    // Remove any existing commas
    String cleanStr = numberStr.replaceAll(',', '');
    
    // Handle negative numbers
    bool isNegative = false;
    if (cleanStr.startsWith('-')) {
      isNegative = true;
      cleanStr = cleanStr.substring(1);
    }
    
    int len = cleanStr.length;
    String result = '';
    
    if (len <= 3) {
      result = cleanStr;
    } else {
      // Get last 3 digits
      result = cleanStr.substring(len - 3);
      
      // Get remaining digits
      String remaining = cleanStr.substring(0, len - 3);
      
      // Insert commas after every 2 digits from right in remaining
      String formattedRemaining = '';
      int remLen = remaining.length;
      
      while (remLen > 0) {
        int start = remLen - 2;
        if (start < 0) start = 0;
        formattedRemaining = remaining.substring(start, remLen) + 
                            (formattedRemaining.isNotEmpty ? ',' : '') + 
                            formattedRemaining;
        remLen = start;
      }
      
      result = formattedRemaining + (formattedRemaining.isNotEmpty ? ',' : '') + result;
    }
    
    return isNegative ? '-$result' : result;
  }
  
  static String formatAmountWithoutDecimal(num amount) {
    final double amountAsDouble = amount.toDouble();
    final int roundedAmount = amountAsDouble.round();
    
    if ((amountAsDouble - roundedAmount).abs() < 0.00001) {
      return _formatIndianNumber(roundedAmount.toString());
    } else {
      return formatAmount(amount);
    }
  }
  
  // Format with currency symbol (Indian numbering)
  static String formatAmountWithCurrency(num amount, {String symbol = '₹'}) {
    return '$symbol${formatAmount(amount)}';
  }
  
  static String formatAmountWithoutDecimalWithCurrency(num amount, {String symbol = '₹'}) {
    return '$symbol${formatAmountWithoutDecimal(amount)}';
  }
  
  // Test function to verify formatting
  static void testFormatting() {
    final testCases = [
      188000.0,    // Should be: 1,88,000
      1000.0,      // Should be: 1,000
      10000.0,     // Should be: 10,000
      100000.0,    // Should be: 1,00,000
      1000000.0,   // Should be: 10,00,000
      10000000.0,  // Should be: 1,00,00,000
      1234567.89,  // Should be: 12,34,567.89
      500.50,      // Should be: 500.50
    ];
    
    for (var testCase in testCases) {
      print('$testCase -> ${formatAmount(testCase)}');
    }
  }
}