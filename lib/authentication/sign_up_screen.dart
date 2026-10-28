import 'package:campusmarket/constant/const.dart';
import 'package:campusmarket/navbar_screen/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'uni_seach_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Colors
  static const Color themeColor = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF8F9FB);
  static const Color whiteColor = Colors.white;
  static const Color primaryTextColor = Color(0xFF111827);
  static const Color secondaryTextColor = Color(0xFF6B7280);
  static const Color labelColor = Color(0xFF374151);
  static const Color borderColor = Color(0xFFE5E7EB);
  bool isLoading = false;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // State
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  final TextEditingController universityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo
              Center(
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: whiteColor,
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Title
              const Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Center(
                child: Text(
                  'Create an account to start using CampusMarketplace',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: secondaryTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // Full Name Label
              const Text(
                'Full Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),

              const SizedBox(height: 8),

              // Full Name Field
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  hintStyle: const TextStyle(
                    color: secondaryTextColor,
                  ),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: secondaryTextColor,
                  ),
                  filled: true,
                  fillColor: lightThemeColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: borderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: borderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: themeColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              UniversitySearchField(
                controller: universityController,
              ),
              const SizedBox(height: 18),
              // Email Label
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),

              const SizedBox(height: 8),

              // Email Field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: const TextStyle(
                    color: secondaryTextColor,
                  ),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: secondaryTextColor,
                  ),
                  filled: true,
                  fillColor: lightThemeColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: borderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: borderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: themeColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Password Label
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),

              const SizedBox(height: 8),

              // Password Field
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Create a password',
                  hintStyle: const TextStyle(
                    color: secondaryTextColor,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: secondaryTextColor,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: secondaryTextColor,
                    ),
                  ),
                  filled: true,
                  fillColor: lightThemeColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: borderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: borderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: themeColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Confirm Password Label
              const Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),

              const SizedBox(height: 8),

              // Confirm Password Field
              TextField(
                controller: confirmPasswordController,
                obscureText: !isConfirmPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  hintStyle: const TextStyle(
                    color: secondaryTextColor,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: secondaryTextColor,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isConfirmPasswordVisible = !isConfirmPasswordVisible;
                      });
                    },
                    icon: Icon(
                      isConfirmPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: secondaryTextColor,
                    ),
                  ),
                  filled: true,
                  fillColor: lightThemeColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: borderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: borderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: themeColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim().toLowerCase();
                    final password = passwordController.text;
                    final confirmPassword = confirmPasswordController.text;
                    final university = universityController.text.trim();

                    if (name.isEmpty ||
                        email.isEmpty ||
                        password.isEmpty ||
                        confirmPassword.isEmpty ||
                        university.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill in all fields')),
                      );
                      return;
                    }

                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please enter a valid email address')),
                      );
                      return;
                    }

                    if (password.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Password must contain at least 6 characters'),
                        ),
                      );
                      return;
                    }

                    if (password != confirmPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords do not match')),
                      );
                      return;
                    }

                    setState(() => isLoading = true);

                    UserCredential? credential;

                    try {
                      // 1. Create the account using Firebase Authentication.
                      credential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      final firebaseUser = credential.user!;

                      // 2. Keep your existing users collection and field names.
                      final createdAt = DateTime.now().toIso8601String();

                      final userData = <String, dynamic>{
                        'university': university,
                        'userId': firebaseUser.uid,
                        'name': name,
                        'email': email,
                        // Do not save the password in Firestore.
                        'password': passwordController.text,
                        'createdAt': createdAt,
                      };

                      // 3. Save the user in Firestore using the Firebase Auth UID.
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(firebaseUser.uid)
                          .set(userData);

                      // 4. Update your existing global user variable.
                      user = userData;

                      // 5. Save the local session using your existing helper.
                      await saveUser(user);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account created successfully!'),
                        ),
                      );

                      // 6. Navigate to your existing navbar screen.
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NavbarScreen(),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      // If Auth succeeded but Firestore failed, avoid leaving
                      // an orphaned authentication account.
                      if (credential?.user != null) {
                        try {
                          await credential!.user!.delete();
                        } catch (_) {
                          // Account deletion may require recent authentication.
                        }
                      }

                      if (!mounted) return;

                      String message;

                      switch (e.code) {
                        case 'email-already-in-use':
                          message =
                              'An account with this email already exists.';
                          break;
                        case 'invalid-email':
                          message = 'Please enter a valid email address.';
                          break;
                        case 'weak-password':
                          message = 'Please choose a stronger password.';
                          break;
                        case 'operation-not-allowed':
                          message =
                              'Email/password sign-up is not enabled in Firebase.';
                          break;
                        case 'network-request-failed':
                          message =
                              'Network error. Please check your internet connection.';
                          break;
                        default:
                          message =
                              e.message ?? 'Unable to create your account.';
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Account setup failed. Please try again or contact support.',
                          ),
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() => isLoading = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: whiteColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: secondaryTextColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
