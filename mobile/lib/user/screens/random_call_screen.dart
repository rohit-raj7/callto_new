import 'dart:ui';
import 'package:flutter/material.dart';
import '../actions/calling.dart';
import '../../services/socket_service.dart';
import '../../services/storage_service.dart';
import '../../services/call_service.dart';
import '../../services/listener_service.dart';
import '../../models/listener_model.dart' as model;

class RandomCallScreen extends StatefulWidget {
  const RandomCallScreen({super.key});

  @override
  State<RandomCallScreen> createState() => _RandomCallScreenState();
}

class _RandomCallScreenState extends State<RandomCallScreen> {
  bool isSearching = false;
  Map<String, String>? matchedUser;
  final SocketService _socketService = SocketService();
  final StorageService _storage = StorageService();
  final ListenerService _listenerService = ListenerService();

  void findRandomPerson() async {
    setState(() {
      isSearching = true;
      matchedUser = null;
    });

    try {
      final result = await _listenerService.getListeners(isOnline: true, limit: 20);
      
      if (result.success && result.listeners.isNotEmpty) {
        final listeners = result.listeners;
        listeners.shuffle();
        final randomListener = listeners.first;
        
        setState(() {
          isSearching = false;
          matchedUser = {
            'id': randomListener.userId,
            'listener_id': randomListener.listenerId,
            'name': randomListener.professionalName ?? 'Unknown',
            'city': randomListener.city ?? 'Unknown',
            'topic': randomListener.specialties.isNotEmpty ? randomListener.specialties.first : 'General',
            'image': randomListener.avatarUrl ?? 'assets/images/khushi.jpg',
          };
        });
      } else {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          isSearching = false;
          matchedUser = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No listeners online right now. Please try again later.')),
          );
        }
      }
    } catch (e) {
      print('Error finding random listener: $e');
      setState(() {
        isSearching = false;
      });
    }
  }

  void startCall(Map<String, String> user) async {
    // Connect to socket and wait for connection
    final connected = await _socketService.connect();
    
    if (!connected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect. Please try again.')),
        );
      }
      return;
    }
    
    // Get current user info
    final userName = await _storage.getDisplayName() ?? 'You';
    final userAvatar = await _storage.getAvatarUrl();
    final userGender = await _storage.getGender();
    
    final listenerId = user['id'];
    
    // Create call record in database first
    final callService = CallService();
    final callResult = await callService.initiateCall(
      listenerId: user['listener_id'] ?? listenerId ?? '',
      callType: 'audio',
    );
    
    if (!callResult.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(callResult.error ?? 'Failed to initiate call')),
        );
      }
      return;
    }
    
    final callId = callResult.call!.callId;
    
    // Notify listener via socket
    if (listenerId != null) {
      print('Caller: Initiating call to listener userId: $listenerId');
      _socketService.initiateCall(
        callId: callId,
        listenerId: listenerId,
        callerName: userName,
        callerAvatar: userAvatar,
        topic: user['topic'],
        gender: userGender,
      );
    } else {
      print('Warning: No listener userId available for call');
    }
    
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Calling(
          callerName: user['name']!,
          callerAvatar: user['image']!,
          userName: userName,
          userAvatar: userAvatar,
          channelName: callId,
          listenerId: listenerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Random Call",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121220), Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: isSearching
                  ? _searchingView()
                  : matchedUser != null
                      ? _matchedCard(matchedUser!)
                      : _idleView(),
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- Idle View ----------------
  Widget _idleView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.pinkAccent.withOpacity(0.2),
                  Colors.purpleAccent.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              size: 80,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Connect with someone instantly",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Random voice call based on your interests",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              elevation: 8,
              shadowColor: Colors.pinkAccent.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: findRandomPerson,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 22),
                SizedBox(width: 12),
                Text(
                  "Find Someone",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- Searching View ----------------
  Widget _searchingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.pinkAccent.withOpacity(0.2),
                Colors.purpleAccent.withOpacity(0.1),
              ],
            ),
          ),
          child: const CircularProgressIndicator(
            color: Colors.pinkAccent,
            strokeWidth: 4,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Searching for a match...",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "This may take a few seconds",
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// ---------------- Matched User Card ----------------
  Widget _matchedCard(Map<String, String> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            // Success badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "Match Found",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.pinkAccent.withOpacity(0.3),
                    Colors.purpleAccent.withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 64,
                backgroundImage: AssetImage(user['image']!),
              ),
            ),
            const SizedBox(height: 20),
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                user['name']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Location
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.white60, size: 16),
                const SizedBox(width: 4),
                Text(
                  user['city']!,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Topic chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.psychology, color: Colors.pinkAccent, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      user['topic']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: Colors.green.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => startCall(user),
                      icon: const Icon(Icons.call, size: 22),
                      label: const Text(
                        "Start Call",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: findRandomPerson,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Find Another Person",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
