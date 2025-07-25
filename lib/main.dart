import 'package:flutter/material.dart';
import 'package:hpackweb/screen/dashboard/dashboardpage.dart';
import 'package:hpackweb/screen/dashboard/pricelistscreen.dart';
import 'package:hpackweb/screen/splashscreen.dart';
import 'package:hpackweb/service/sessiontimeout.dart';
import 'package:hpackweb/utils/sharedpref.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:html' as html;
import 'loginpage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  setUrlStrategy(const HashUrlStrategy());
  await Prefs.init();
  html.window.history.pushState(null, '', html.window.location.href);
  html.window.onPopState.listen((event) {
    html.window.history.pushState(null, '', html.window.location.href);
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hpack Approval',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2A3F54),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        fontFamily: 'Helvetica',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      initialRoute: '/',
      //home: PriceListScreen(),
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
