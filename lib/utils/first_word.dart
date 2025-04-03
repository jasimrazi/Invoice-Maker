String getFirstWord(String recipientName) {
  // Trim the input to remove any extra spaces
  recipientName = recipientName.trim();
  if (recipientName.isEmpty) return "";
  // Split the name by whitespace and return the first element
  return recipientName.split(RegExp(r'\s+'))[0];
}
