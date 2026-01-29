import 'package:flutter/material.dart';
import 'login/login.dart';
import 'user/widgets/bottom_nav_bar.dart' as user_bottom_nav_bar;
import 'listener/widgets/bottom_nav_bar.dart' as listener_bottom_nav_bar;
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/listener_service.dart';
import 'services/socket_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ConnectoApp());
}

class ConnectoApp extends StatefulWidget {
  const ConnectoApp({super.key});

  @override
  State<ConnectoApp> createState() => _ConnectoAppState();
}

class _ConnectoAppState extends State<ConnectoApp> with WidgetsBindingObserver {
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('[LIFECYCLE] AppLifecycleState: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        SocketService().emitListenerOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        SocketService().emitListenerOffline();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Callto',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFCE4EC),
      ),
      home: const SplashScreen(),
    );
  }
}

/// Splash screen to check login status
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 500));

    final isLoggedIn = await _authService.checkLoginStatus();

    if (!mounted) return;

    if (isLoggedIn) {
      // Refresh user data from backend to ensure we know if the user is a listener
      try {
        final user = await _authService.refreshUserData();

        if (user != null) {
          // Role-based navigation: display appropriate dashboard based on account type
          if (user.accountType == 'listener') {
            // Listener: fetch listener profile and save avatar to local storage, then display listener dashboard
            await _storageService.saveIsListener(true);
            
            // Socket will be connected by IncomingCallOverlayService in BottomNavBar
            
            // Fetch listener profile to get latest avatar
            try {
              final listenerService = ListenerService();
              final profileResult = await listenerService.getMyProfile();
              if (profileResult.success && profileResult.listener != null) {
                // Save avatar to local storage for top_bar
                if (profileResult.listener!.avatarUrl != null) {
                  await _storageService.saveListenerAvatarUrl(profileResult.listener!.avatarUrl!);
                }
              }
            } catch (e) {
              print('Failed to fetch listener profile: $e');
            }
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const listener_bottom_nav_bar.BottomNavBar()),
            );
            return;
          } else if (user.accountType == 'user' || user.accountType == 'both') {
            // User: always display user dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const user_bottom_nav_bar.BottomNavBar()),
            );
            return;
          }
        }

        // Fallback: if user data refresh failed or account type not recognized
        // Go to user dashboard as default
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const user_bottom_nav_bar.BottomNavBar()),
        );
      } catch (e) {
        // If refresh fails, fall back to local storage checks
        print('Failed to refresh user data: $e');

        // Check if locally marked as listener
        final isListener = await _storageService.getIsListener();
        if (isListener) {
          // Socket will be connected by IncomingCallOverlayService in BottomNavBar
          
          // Try to fetch listener profile for avatar
          try {
            final listenerService = ListenerService();
            final profileResult = await listenerService.getMyProfile();
            if (profileResult.success && profileResult.listener != null) {
              // Save avatar to local storage for top_bar
              if (profileResult.listener!.avatarUrl != null) {
                await _storageService.saveListenerAvatarUrl(profileResult.listener!.avatarUrl!);
              }
            }
          } catch (e) {
            print('Failed to fetch listener profile: $e');
          }
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const listener_bottom_nav_bar.BottomNavBar()),
          );
          return;
        }

        // Not a listener - go to user dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const user_bottom_nav_bar.BottomNavBar()),
        );
      }
    } else {
      // User is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/login/logo.png',
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.phone_in_talk,
                  size: 80,
                  color: Colors.pinkAccent,
                );
              },
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.pinkAccent,
            ),
          ],
        ),
      ),
    );
  }
}
