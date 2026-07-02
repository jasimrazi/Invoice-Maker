import 'package:flutter/material.dart';
import 'package:invoice_maker/database/database_helper.dart';
import 'package:invoice_maker/provider/invoice_provider.dart';
import 'package:invoice_maker/provider/recepient_provider.dart';
import 'package:invoice_maker/provider/settings_provider.dart';
import 'package:invoice_maker/provider/voucher_provider.dart';
import 'package:invoice_maker/screen/home_page.dart';
import 'package:invoice_maker/utils/apptheme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => RecepientProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const BouncingScrollBehavior(),
      theme: AppTheme.lightTheme,
      home: HomePage(),
    );
  }
}

class BouncingScrollBehavior extends MaterialScrollBehavior {
  const BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
