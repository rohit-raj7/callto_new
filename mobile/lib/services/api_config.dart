import 'package:flutter/foundation.dart';

class ApiConfig {
  static final String baseUrl = kDebugMode
      ? 'http://localhost:3002'
      : 'https://callto-4.onrender.com';

  // static final String baseUrl = 'https://callto-4.onrender.com';
      

  static final String socketUrl = baseUrl;

  static final String apiBase = '$baseUrl/api';

  static final String socialLogin = '$apiBase/auth/social-login';
  static final String register = '$apiBase/auth/register';
  static final String logout = '$apiBase/auth/logout';

  static final String userProfile = '$apiBase/users/profile';
  static final String userLanguages = '$apiBase/users/languages';
  static final String userWallet = '$apiBase/users/wallet';

  static final String listeners = '$apiBase/listeners';
  static final String listenerSearch = '$apiBase/listeners/search';

  static final String calls = '$apiBase/calls';
  static final String callHistory = '$apiBase/calls/history/me';
  static final String listenerCallHistory = '$apiBase/calls/history/listener';
  static final String activeCalls = '$apiBase/calls/active/me';
  static final String agoraToken = '$apiBase/calls/agora/token';

  static final String chats = '$apiBase/chats';

  static final String health = '$apiBase/health';

  static final Duration timeout = const Duration(seconds: 30);
}
