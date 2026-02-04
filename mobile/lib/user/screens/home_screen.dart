import 'package:flutter/material.dart';
import '../widgets/expert_card.dart';
import '../widgets/top_bar.dart';
import '../../services/listener_service.dart';
import '../../services/socket_service.dart';
import '../../models/listener_model.dart' as listener_model;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ListenerService _listenerService = ListenerService();
  
  String? selectedTopic;
  Map<String, bool> listenerOnlineMap = {};
  List<listener_model.Listener> _listeners = [];
  List<listener_model.Listener> _filteredListeners = [];
  bool _isLoading = false;
  String? _error;

  final List<String> topics = [
    'All',
    'Confidence',
    'Marriage',
    'Breakup',
    'Single',
    'Relationship',
  ];

  @override
  void initState() {
    super.initState();
    selectedTopic = 'All';
    _loadListeners();
    SocketService().connectListener();
    // --- FIX: Listen for real-time status, no default offline ---
    SocketService().listenerStatusStream.listen((map) {
      setState(() {
        listenerOnlineMap = Map.from(map);
      });
    });
  }

  Future<void> _loadListeners() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _listenerService.getListeners();
      if (result.success) {
        setState(() {
          _listeners = result.listeners;
          _filterListeners();
        });
      } else {
        setState(() {
          _error = 'Failed to load listeners';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterByTopic(String? topic) {
    setState(() {
      selectedTopic = topic;
      _filterListeners();
    });
  }

  void _filterListeners() {
    if (selectedTopic == 'All') {
      _filteredListeners = _listeners;
    } else {
      _filteredListeners = _listeners.where((listener_model.Listener listener) {
        return listener.specialties.contains(selectedTopic);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TopBar(),

            // Title + Dropdown Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Start a Conversation...",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Professional Dropdown Button
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4EC),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTopic,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.pinkAccent,
                          size: 24,
                        ),
                        elevation: 8,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        items: topics.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selectedTopic == value 
                                      ? FontWeight.w600 
                                      : FontWeight.w500,
                                  color: selectedTopic == value
                                      ? Colors.pinkAccent
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: _filterByTopic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Expert List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.pinkAccent,
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadListeners,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredListeners.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No experts found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try selecting a different category',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadListeners,
                              child: ListView.builder(
                                itemCount: _filteredListeners.length,
                                itemBuilder: (context, index) {
                                  final listener = _filteredListeners[index];
                                  return ExpertCard(
                                    name: listener.professionalName ?? 'Unknown',
                                    age: listener.age ?? 20,
                                    city: listener.location,
                                    topic: listener.primarySpecialty,
                                    rate: listener.formattedRate,
                                    rating: listener.rating,
                                    imagePath: listener.avatarUrl ?? 'assets/images/khushi.jpg',
                                    languages: listener.languages,
                                    listenerId: listener.listenerId,
                                    listenerUserId: listener.userId,
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
