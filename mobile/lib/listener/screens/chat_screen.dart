

import 'package:flutter/material.dart';
import '../actions/charting.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> experts = [
      {
        'name': 'Aarav Sharma',
        'age': 28,
        'city': 'Mumbai',
        'topic': 'Life Coach',
        'rate': '₹15/min',
        'rating': 4.8,
        'language': 'Hindi',
        'image': 'assets/images/khushi.jpg',
        'isOnline': true,
      },
      {
        'name': 'Sneha D',
        'age': 31,
        'city': 'Ahmedabad',
        'topic': 'Career Advisor',
        'rate': '₹20/min',
        'rating': 4.9,
        'language': 'English',
        'image': 'assets/images/khushi.jpg',
        'isOnline': false,
      },
      {
        'name': 'Khushi Raj',
        'age': 35,
        'city': 'Delhi',
        'topic': 'Astrology',
        'rate': '₹25/min',
        'rating': 4.7,
        'language': 'Hindi',
        'image': 'assets/images/khushi.jpg',
        'isOnline': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          'Chat with Experts',
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search experts...',
                  prefixIcon: const Icon(Icons.search, color: Colors.pinkAccent),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.pinkAccent.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.pinkAccent),
                  ),
                ),
              ),
            ),

            // Expert Cards
            Expanded(
              child: experts.isEmpty
                  ? _buildNoExpertsView()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: experts.length,
                      itemBuilder: (context, index) {
                        final expert = experts[index];
                        return _buildExpertCard(expert);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertCard(Map<String, dynamic> expert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE91E63).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.1),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(expert['image']),
                ),
                if (expert['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expert['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${expert['age']} years old",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Text(
                    "${expert['language']}",
                    style: const TextStyle(
                        color: Colors.pinkAccent, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (expert['isOnline'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          "Online",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "Offline",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: expert['isOnline']
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                expertName: expert['name'],
                                imagePath: expert['image'],
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
                    backgroundColor: expert['isOnline']
                        ? Colors.pinkAccent
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoExpertsView() => const Center(
        child: Text(
          'No experts available',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF880E4F),
          ),
        ),
      );
}
