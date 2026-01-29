import 'package:flutter/material.dart';
import '../screens/home_screen.dart'; 
import '../screens/chat_screen.dart';
import '../screens/recents_screen.dart';
import '../../services/incoming_call_overlay_service.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;
  final IncomingCallOverlayService _overlayService = IncomingCallOverlayService();

  final List<Widget> _screens = const [
    HomeScreen(), 
    ChatScreen(),
    RecentsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize overlay service after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOverlayService();
    });
  }
  
  Future<void> _initializeOverlayService() async {
    await _overlayService.initialize(context);
  }

  @override
  void dispose() {
    // Don't full dispose - just clear context
    _overlayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Call',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Recents',
          ),
        ],
      ),
    );
  }
}
