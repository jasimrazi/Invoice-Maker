import 'package:flutter/material.dart';
import 'package:invoice_maker/database/recepient_db.dart';
import 'package:invoice_maker/model/recipient.dart';

class RecepientProvider extends ChangeNotifier {
  final RecipientDB _recipientDB = RecipientDB();

  // Add recipient to the database
  Future<void> addRecepient({
    required String name,
    required String address,
    required String gstin,
    required String place,
  }) async {
    if (name.isEmpty || address.isEmpty || gstin.isEmpty || place.isEmpty) {
      throw Exception('All fields are required');
    }

    final recipient = Recipient(
      name: name,
      address: address,
      gstin: gstin,
      place: place,
    );

    await _recipientDB.insertRecipient(recipient);
    notifyListeners(); // Notify listeners to update UI if needed
  }

  // Fetch all recipients from the database
  Future<List<Recipient>> getRecipients() async {
    return await _recipientDB.getRecipients();
  }

  // Update a recipient in the database
  Future<void> updateRecepient({
    required int id,
    required String name,
    required String address,
    required String gstin,
    required String place,
  }) async {
    if (name.isEmpty || address.isEmpty || gstin.isEmpty || place.isEmpty) {
      throw Exception('All fields are required');
    }

    final recipient = Recipient(
      id: id,
      name: name,
      address: address,
      gstin: gstin,
      place: place,
    );

    await _recipientDB.updateRecipient(recipient, id);
    notifyListeners(); // Notify listeners to update UI if needed
  }

  // Delete a recipient from the database
  Future<void> deleteRecepient(int id) async {
    await _recipientDB.deleteRecipient(id);
    notifyListeners(); // Notify listeners to update UI if needed
  }

  // Validator function
  String? validateField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }
}
