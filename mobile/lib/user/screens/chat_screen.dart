

import 'package:flutter/material.dart';
import '../actions/charting.dart';  

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

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
        'image': 'assets/images/khushi.jpg',
      },
      {
        'name': 'Sneha D',
        'age': 31,
        'city': 'Ahmedabad',
        'topic': 'Career Advisor',
        'rate': '₹20/min',
        'rating': 4.9,
        'image': 'assets/images/khushi.jpg',
      },
      {
        'name': 'Khushi Raj',
        'age': 35,
        'city': 'Delhi',
        'topic': 'Astrology',
        'rate': '₹25/min',
        'rating': 4.7,
        'image': 'assets/images/khushi.jpg',
      },
    ];

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
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
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

            // 👩‍💼 Expert Cards
            Expanded(
              child: ListView.builder(
                itemCount: experts.length,
                itemBuilder: (context, index) {
                  final expert = experts[index];
                  return Card(
                    color: const Color(0xFFFFE4EC),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(expert['image']),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${expert['name']} • ${expert['age']} Y",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(expert['city']),
                                Text(expert['topic'],
                                    style: const TextStyle(
                                        color: Colors.pinkAccent)),
                                Text(expert['rate'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.circle,
                                      size: 10, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    "Online",
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // 💬 Chat Now Button
                              ElevatedButton.icon(
                                onPressed: () {
                                  // 👇 Navigate to Chat Page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        expertName: expert['name'],
                                        imagePath: expert['image'],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline,
                                    size: 18, color: Colors.white),
                                label: const Text(
                                  "Chat Now",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent,
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
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  Text(expert['rating'].toString()),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
