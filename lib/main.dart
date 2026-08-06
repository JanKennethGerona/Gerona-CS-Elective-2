import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram UI',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const InstagramFeedScreen(),
    );
  }
}

class InstagramFeedScreen extends StatelessWidget {
  const InstagramFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Instagram',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 26),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Story Circle Border
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.amber, Colors.pink, Colors.purple],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'username',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.more_vert),
                ],
              ),
            ),

            // Post Content (Gradient area from sample screenshot)
            Container(
              height: 400,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFFFFB74D), // Yellow/Orange
                    Color(0xFFE91E63), // Pink
                    Color(0xFF5E35B1), // Purple
                  ],
                ),
              ),
            ),

            // Post Action Buttons (matches screenshot)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.favorite, color: Colors.red, size: 28),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 18),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.chat_bubble_outline, size: 26),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 18),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.send_outlined, size: 26),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.bookmark_border, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Likes Counter
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                '10547 Likes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),

            const SizedBox(height: 6),

            // Caption Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 13),
                  children: [
                    TextSpan(
                      text: '@username ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'Lorem ipsum dolor sit amet, consectetur',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Hashtags
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                '#lorem  #ipsum  #dolor  #sit  #amet  #concestetur',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.video_collection_outlined, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 28), label: ''),
        ],
      ),
    );
  }
}