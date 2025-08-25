import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:hpackweb/loginpage.dart';
import 'package:hpackweb/utils/sharedpref.dart';

class IdleLogoutWrapper extends StatefulWidget {
  final Widget child;

  const IdleLogoutWrapper({super.key, required this.child});

  @override
  State<IdleLogoutWrapper> createState() => _IdleLogoutWrapperState();
}

class _IdleLogoutWrapperState extends State<IdleLogoutWrapper> {
  Timer? _idleTimer;
  final Duration _idleTimeout = const Duration(hours: 1);

  @override
  void initState() {
    super.initState();
    _initializeIdleWatcher();
  }

  void _initializeIdleWatcher() {
    // Listen for user activity
    html.document.onMouseMove.listen((_) => _resetTimer());
    html.document.onClick.listen((_) => _resetTimer());
    html.document.onKeyDown.listen((_) => _resetTimer());
    html.document.onTouchStart.listen((_) => _resetTimer());

    _resetTimer();
  }

  void _resetTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleTimeout, _handleIdleTimeout);
  }

  void _handleIdleTimeout() {
    // Clear user session (localStorage, SharedPreferences, etc.)
    html.window.localStorage.clear();
    Prefs.setLoggedIn(false);
    Prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
