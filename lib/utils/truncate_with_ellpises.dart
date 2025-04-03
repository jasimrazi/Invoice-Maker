import 'package:syncfusion_flutter_pdf/pdf.dart';

String truncateTextWithEllipsis({
  required String text,
  required PdfFont font,
  required double maxWidth,
}) {
  // Measure the full text width
  double textWidth = font.measureString(text).width;

  // If the text fits within the maxWidth, return it as is
  if (textWidth <= maxWidth) {
    return text;
  }

  // Estimate the width of the ellipsis (...)
  const String ellipsis = "...";
  double ellipsisWidth = font.measureString(ellipsis).width;

  // Binary search-like approach to find the truncation point
  String truncatedText = text;
  while (font.measureString(truncatedText + ellipsis).width > maxWidth &&
      truncatedText.isNotEmpty) {
    truncatedText = truncatedText.substring(0, truncatedText.length - 1);
  }

  // Append ellipsis if the text was truncated
  return truncatedText.isNotEmpty ? "$truncatedText$ellipsis" : text;
}
