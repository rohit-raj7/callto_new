

import 'package:flutter/material.dart';
import '../actions/charting.dart';
import '../../services/listener_service.dart';
import '../../services/socket_service.dart';
import '../../models/listener_model.dart' as models;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ListenerService _listenerService = ListenerService();
  final SocketService _socketService = SocketService();
  
  List<models.Listener> _listeners = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadListeners();
    _setupOnlineStatusListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setupOnlineStatusListener() {
    _socketService.listenerStatusStream.listen((statusMap) {
      if (mounted) {
        setState(() {
          // Update listener online status based on socket events
          for (var listener in _listeners) {
            if (statusMap.containsKey(listener.userId)) {
              // This would require making Listener mutable or creating a new model
              // For now, we'll just trigger a rebuild
            }
          }
        });
      }
    });
  }

  Future<void> _loadListeners() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _listenerService.getListeners(
        isOnline: true, // Only show online listeners for chat
        sortBy: 'rating',
      );

      if (result.success) {
        setState(() {
          _listeners = result.listeners;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Failed to load listeners';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading listeners: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchListeners(String query) async {
    if (query.isEmpty) {
      _loadListeners();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _listenerService.searchListeners(query);
      
      if (result.success) {
        setState(() {
          _listeners = result.listeners;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Search error: $e';
        _isLoading = false;
      });
    }
  }

  List<models.Listener> get _filteredListeners {
    if (_searchQuery.isEmpty) return _listeners;
    
    return _listeners.where((listener) {
      final name = listener.professionalName?.toLowerCase() ?? '';
      final specialties = listener.specialties.join(' ').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || specialties.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          'Chat Now',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFEBEE), Color(0xFFFCE4EC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  if (value.length >= 2) {
                    _searchListeners(value);
                  } else if (value.isEmpty) {
                    _loadListeners();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search experts...',
                  prefixIcon: const Icon(Icons.search, color: Colors.pinkAccent),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.pinkAccent),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadListeners,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final listeners = _filteredListeners;

    if (listeners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No experts available',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadListeners,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadListeners,
      child: ListView.builder(
        itemCount: listeners.length,
        itemBuilder: (context, index) {
          final listener = listeners[index];
          return _buildListenerCard(listener);
        },
      ),
    );
  }

  Widget _buildListenerCard(models.Listener listener) {
    final isOnline = listener.isOnline && listener.isAvailable;
    
    return Card(
      color: const Color(0xFFFFE4EC),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              backgroundImage: listener.avatarUrl != null
                  ? NetworkImage(listener.avatarUrl!)
                  : const AssetImage('assets/images/khushi.jpg') as ImageProvider,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${listener.professionalName ?? 'Expert'} ${listener.age != null ? '• ${listener.age} Y' : ''}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  if (listener.city != null) Text(listener.city!),
                  if (listener.specialties.isNotEmpty)
                    Text(
                      listener.specialties.first,
                      style: const TextStyle(color: Colors.pinkAccent),
                    ),
                  Text(
                    '₹${listener.ratePerMinute.toInt()}/min',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? "Online" : "Offline",
                      style: TextStyle(
                        color: isOnline ? Colors.green : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Chat Now Button
                ElevatedButton.icon(
                  onPressed: isOnline
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                expertName: listener.professionalName ?? 'Expert',
                                imagePath: 'assets/images/khushi.jpg',
                                otherUserId: listener.userId,
                                otherUserAvatar: listener.avatarUrl,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.chat_bubble_outline,
                      size: 18, color: Colors.white),
                  label: const Text(
                    "Chat Now",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOnline ? Colors.pinkAccent : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                  ),
                ),

                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(listener.rating.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
