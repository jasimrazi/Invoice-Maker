import 'package:flutter/material.dart';
import 'package:invoice_maker/model/recipient.dart';
import 'package:invoice_maker/provider/invoice_provider.dart';
import 'package:invoice_maker/provider/recepient_provider.dart';
import 'package:invoice_maker/screen/add_recepient_page.dart';
import 'package:invoice_maker/utils/apptheme.dart';
import 'package:provider/provider.dart';

class SearchRecipient extends StatefulWidget {
  const SearchRecipient({super.key});

  @override
  State<SearchRecipient> createState() => _SearchRecipientState();
}

class _SearchRecipientState extends State<SearchRecipient> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).clearSearchField();
      _searchController.clear();
      _searchFocusNode.unfocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final recepientProvider = Provider.of<RecepientProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Field
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100], // Lighter background for a cleaner look
            borderRadius: BorderRadius.circular(12.0),
          ),
          // padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText:
                        invoiceProvider.selectedRecipient == null
                            ? 'Search recipient...'
                            : invoiceProvider.selectedRecipient!.name,
                    hintStyle: TextStyle(
                      color:
                          invoiceProvider.selectedRecipient == null
                              ? Colors.grey
                              : AppColors.blackColor,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100, // Light background color
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none, // No default border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1.0,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        invoiceProvider.clearSearchField();
                        invoiceProvider.clearSuggestions();
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  onChanged: (value) async {
                    invoiceProvider.setTypingState(value.isNotEmpty);
                    if (value.isNotEmpty) {
                      final recipients =
                          await recepientProvider.getRecipients();
                      final suggestions =
                          recipients
                              .where(
                                (recipient) => recipient.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()),
                              )
                              .toList();
                      invoiceProvider.updateSuggestions(suggestions);
                    } else {
                      invoiceProvider.clearSearchField();
                      invoiceProvider.clearSuggestions();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10.0),
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddRecepientPage(),
                      ),
                    ),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),

        // Search Suggestions (with animation)
        if (invoiceProvider.suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12.0),
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: invoiceProvider.suggestions.length,
              itemBuilder: (context, index) {
                final recipient = invoiceProvider.suggestions[index];
                return ListTile(
                  title: Text(
                    recipient.name,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  onTap: () {
                    invoiceProvider.selectRecipient(recipient);
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                  },
                );
              },
            ),
          ),

        // No Matching Items Text
        if (invoiceProvider.hasStartedTyping &&
            invoiceProvider.suggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: Text(
                'No matching recipients found',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14.0),
              ),
            ),
          ),
      ],
    );
  }
}
