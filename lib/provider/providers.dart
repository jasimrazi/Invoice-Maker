import 'package:invoice_maker/provider/invoice_provider.dart';
import 'package:invoice_maker/provider/recepient_provider.dart';
import 'package:provider/provider.dart';
// Import your provider classes here
// import 'package:invoice_maker/providers/your_provider.dart';

final List<ChangeNotifierProvider> appProviders = [
  ChangeNotifierProvider(create: (_) => InvoiceProvider()),
  ChangeNotifierProvider(create: (_) => RecepientProvider()),
];
