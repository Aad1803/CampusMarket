import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const Color themeColor = Color(0xFF2F69EC);
const Color backgroundColor = Color(0xFFF7F8FA);
const Color whiteColor = Colors.white;
const Color primaryTextColor = Color(0xFF111827);
const Color secondaryTextColor = Color(0xFF6B7280);
const Color lightTextColor = Color(0xFF9CA3AF);
const Color borderColor = Color(0xFFE5E7EB);
const Color cardColor = Colors.white;

const Color labelColor = Color(0xFF374151);

Map<dynamic, dynamic> user = {};

bool isLoggedIn = false;

Future<void> saveUser(userData) async {
  final prefs = await SharedPreferences.getInstance();
  user = userData;
  isLoggedIn = true;
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('user', jsonEncode(userData));
}

Future<void> loadUser() async {
  final prefs = await SharedPreferences.getInstance();
  isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  if (isLoggedIn) {
    final String? savedUser = prefs.getString('user');
    if (savedUser != null && savedUser.isNotEmpty) {
      user = Map<String, dynamic>.from(
        jsonDecode(savedUser),
      );
    }
  }
}

List<String> categories = [
  'Electronics',
  'Books & Education',
  'Furniture & Home',
  'Clothing & Fashion',
  'Transportation',
  'Food & Beverages',
  'Sports & Fitness',
  'Beauty & Personal Care',
  'Games & Entertainment',
  'Tickets & Events',
  'Services',
  'Pet Supplies',
  'Hobbies & Collectibles',
  'Free Items',
  'Other',
];

Future<void> logoutUser() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('isLoggedIn');
  await prefs.remove('user');

  isLoggedIn = false;
  user = {};
}
