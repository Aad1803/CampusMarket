import 'package:campusmarket/homescreen/home_screen.dart';
import 'package:flutter/material.dart';

class NavbarScreen extends StatefulWidget {
  const NavbarScreen({super.key});

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  // Colors
  static const Color themeColor = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF8F9FB);
  static const Color whiteColor = Colors.white;
  static const Color primaryTextColor = Color(0xFF111827);
  static const Color secondaryTextColor = Color(0xFF6B7280);

  int selectedIndex = 0;

  final List<Color> bodyColors = [
    backgroundColor,
    const Color(0xFFFFF7ED),
    const Color(0xFFF0FDF4),
    const Color(0xFFF5F3FF),
  ];

  final List<String> titles = [
    'Home',
    'Sell',
    'Messages',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColors[selectedIndex],

      // Body
      body: Center(
        child: selectedIndex == 0
            ? HomeScreen()
            : Text(
                titles[selectedIndex],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: whiteColor,
        selectedItemColor: themeColor,
        unselectedItemColor: secondaryTextColor,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
