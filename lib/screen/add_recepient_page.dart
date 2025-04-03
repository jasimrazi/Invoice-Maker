import 'package:flutter/material.dart';
import 'package:invoice_maker/provider/recepient_provider.dart';
import 'package:invoice_maker/screen/inovice/invoice_page.dart';
import 'package:invoice_maker/screen/widget/appbar.dart';
import 'package:invoice_maker/screen/widget/bottomnavbar.dart';
import 'package:invoice_maker/screen/widget/textfield.dart';
import 'package:provider/provider.dart';

class AddRecepientPage extends StatelessWidget {
  AddRecepientPage({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController placeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final recepientProvider = Provider.of<RecepientProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Add Recepient'),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  hintText: 'Enter recipient name',
                  controller: nameController,
                  validator: recepientProvider.validateField,
                ),
                const SizedBox(height: 16.0),
                CustomTextField(
                  hintText: 'Enter recipient address',
                  controller: addressController,
                  isMultiline: true,
                  validator: recepientProvider.validateField,
                ),
                const SizedBox(height: 16.0),
                CustomTextField(
                  hintText: 'Enter GSTIN',
                  controller: gstinController,
                  validator: recepientProvider.validateField,
                ),
                const SizedBox(height: 16.0),
                CustomTextField(
                  hintText: 'Enter place',
                  controller: placeController,
                  validator: recepientProvider.validateField,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          label: "Add Recepient",
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              try {
                await recepientProvider.addRecepient(
                  name: nameController.text,
                  address: addressController.text,
                  gstin: gstinController.text,
                  place: placeController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recipient added successfully!'),
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => InvoicePage()),
                ); // Go back after adding
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            }
          },
        ),
      ),
    );
  }
}
