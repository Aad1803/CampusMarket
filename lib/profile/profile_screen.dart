import 'package:campusmarket/authentication/uni_seach_screen.dart';
import 'package:campusmarket/constant/const.dart';
import 'package:campusmarket/constant/uni_list.dart';
import 'package:campusmarket/sellscreen/sell_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const Color primaryColor = Color(0xFF315C4C);
  static const Color backgroundColor = Color(0xFFF7F8F5);
  static const Color textColor = Color(0xFF202720);
  static const Color mutedColor = Color(0xFF7B827B);

  bool _loggingOut = false;

  String get _uid => _auth.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> currentUser = user;
    // final usr = user;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your profile.')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined, color: textColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _db.collection('users').doc(_uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _errorView('Could not load your profile.');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          final data = user ?? <String, dynamic>{};

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(data),
                const SizedBox(height: 22),
                _buildStats(),
                const SizedBox(height: 28),
                _sectionTitle('My Marketplace'),
                const SizedBox(height: 12),
                _buildMenuCard([
                  _menuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'My Listings',
                    subtitle: 'Manage the items you are selling',
                    onTap: () => _openMyListings(),
                  ),
                  _menuDivider(),
                  _menuItem(
                    icon: Icons.favorite_border_rounded,
                    title: 'Saved Items',
                    subtitle: 'Products you have saved',
                    onTap: () => _openSavedItems(),
                  ),
                ]),
                const SizedBox(height: 26),
                _sectionTitle('Account'),
                const SizedBox(height: 12),
                _buildMenuCard([
                  _menuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: _editProfile,
                  ),
                  _menuDivider(),
                  _menuItem(
                    icon: Icons.school_outlined,
                    title: 'My University',
                    subtitle: _text(data['university'], 'Not selected'),
                    onTap: () => _editProfile(),
                  ),
                  _menuDivider(),
                  _menuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'Account preferences',
                    onTap: _showSettings,
                  ),
                ]),
                const SizedBox(height: 26),
                _sectionTitle('Support'),
                const SizedBox(height: 12),
                _buildMenuCard([
                  _menuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'Get help using CampusMarket',
                    onTap: _showHelp,
                  ),
                  _menuDivider(),
                  _menuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About CampusMarket',
                    subtitle: 'Learn about our marketplace',
                    onTap: _showAbout,
                  ),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: _loggingOut ? null : _confirmLogout,
                    icon: _loggingOut
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.logout_rounded),
                    label: Text(
                      _loggingOut ? 'Signing out...' : 'Log Out',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'CAMPUSMARKET  •  MADE FOR STUDENTS',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 10,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // PROFILE HEADER
  // --------------------------------------------------

  Widget _buildProfileHeader(Map<String, dynamic> data) {
    final username = _text(
      data['name'],
      data['name'],
    );

    final email = _text(
      data['email'],
      _auth.currentUser?.email ?? '',
    );

    final university = _text(data['university'], 'University not selected');

    final photoUrl = _text(
      data['photoUrl'],
      _auth.currentUser?.photoURL ?? '',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8ECE7)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFFE5EDE7),
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: primaryColor,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _editProfile,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            username.startsWith('@') ? username : '@$username',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: mutedColor,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF3EE),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 16,
                  color: primaryColor,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    university,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // LISTING STATISTICS
  // --------------------------------------------------

  Widget _buildStats() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db
          .collection('products')
          .where('userId', isEqualTo: user['userId'])
          .snapshots(),
      builder: (context, snapshot) {
        final products = snapshot.data?.docs ?? [];
        final activeCount = products.where((doc) {
          final status = doc.data()['status'];
          return status == null || status == 'available';
        }).length;

        return Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.storefront_outlined,
                value: snapshot.hasError ? '—' : '$activeCount',
                label: 'Active listings',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.inventory_2_outlined,
                value: snapshot.hasError ? '—' : '${products.length}',
                label: 'Total listings',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.favorite_border_rounded,
                value: '—',
                label: 'Saved items',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECE7)),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              color: textColor,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // MENU COMPONENTS
  // --------------------------------------------------

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textColor,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECE7)),
      ),
      child: Column(children: children),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: const Color(0xFFEDF3EE),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: mutedColor,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: mutedColor,
      ),
      onTap: onTap,
    );
  }

  Widget _menuDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 72,
      endIndent: 16,
      color: Color(0xFFE8ECE7),
    );
  }

  // --------------------------------------------------
  // EDIT PROFILE
  // --------------------------------------------------

  Future<void> _editProfile() async {
    final userRef = _db.collection('users').doc(_uid);
    final snapshot = await userRef.get();
    if (!mounted) return;

    final data = user;

    final usernameController = TextEditingController(
      text: _text(data['name'], ''),
    );
    var universityController = TextEditingController(text: data['university']);
    // UniversitySearchField(
    //   controller: universityController,
    // );
    final bioController = TextEditingController(
      text: _text(data['bio'], ''),
    );

    final formKey = GlobalKey<FormState>();
    bool saving = false;
    String? errorMessage;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> saveProfile() async {
              if (!formKey.currentState!.validate()) return;

              setDialogState(() {
                saving = true;
                errorMessage = null;
              });

              try {
                final username =
                    usernameController.text.trim().replaceFirst('@', '');

                // Check username uniqueness only if it changed.
                final oldUsername = _text(data['username'], '');
                if (username.toLowerCase() != oldUsername.toLowerCase()) {
                  final duplicate = await _db
                      .collection('users')
                      .where('userId', isEqualTo: user['userId'])
                      .limit(1)
                      .get();

                  final duplicateExists = duplicate.docs.any(
                    (doc) => doc.id != _uid,
                  );

                  if (duplicateExists) {
                    setDialogState(() {
                      saving = false;
                      errorMessage = 'That username is already taken.';
                    });
                    return;
                  }
                }

                await userRef.set({
                  'name': username,
                  'usernameLower': username.toLowerCase(),
                  'university': universityController.text.trim(),
                  'bio': bioController.text.trim(),
                }, SetOptions(merge: true));
                final userData = <String, dynamic>{
                  'university': universityController.text.trim(),
                  'userId': user['userId'],
                  'name': username,
                  'email': user['email'],
                  // Do not save the password in Firestore.
                  'password': user['password'],
                  'createdAt': user['createdAt'],
                };
                saveUser(userData);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              } catch (e) {
                setDialogState(() {
                  saving = false;
                  errorMessage = 'Could not save your profile. Please retry.';
                });
              }
            }

            return AlertDialog(
              title: const Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixText: '@',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final username = (value ?? '').trim();
                          if (username.isEmpty) {
                            return 'Username is required';
                          }
                          if (username.length < 3) {
                            return 'Use at least 3 characters';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(username)) {
                            return 'Use letters, numbers, _ or .';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      UniversitySearchField(
                        controller: universityController,
                      ),
                      // TextFormField(
                      //   controller: universityController,
                      //   decoration: const InputDecoration(
                      //     labelText: 'University',
                      //     border: OutlineInputBorder(),
                      //   ),
                      //   validator: (value) => (value ?? '').trim().isEmpty
                      //       ? 'University is required'
                      //       : null,
                      // ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: bioController,
                        maxLines: 3,
                        maxLength: 150,
                        decoration: const InputDecoration(
                          labelText: 'Bio (optional)',
                          hintText: 'A little about you...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      saving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving ? null : saveProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    usernameController.dispose();
    universityController.dispose();
    bioController.dispose();
  }

  // --------------------------------------------------
  // MY LISTINGS
  // --------------------------------------------------

  Future<void> _openMyListings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellScreen(),
      ),
    );
  }

  // --------------------------------------------------
  // SAVED ITEMS
  // --------------------------------------------------

  Future<void> _openSavedItems() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SavedItemsScreen(
          uid: _uid,
          db: _db,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SETTINGS, HELP, ABOUT
  // --------------------------------------------------

  void _showSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email address'),
                subtitle: Text(_auth.currentUser?.email ?? 'Not available'),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Change password'),
                subtitle: const Text('Send a password reset email'),
                onTap: () async {
                  final email = _auth.currentUser?.email;
                  if (email == null || email.isEmpty) {
                    Navigator.pop(context);
                    _showMessage('No email address is available.');
                    return;
                  }

                  try {
                    await _auth.sendPasswordResetEmail(email: email);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _showMessage('Password reset email sent.');
                  } catch (_) {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _showMessage('Could not send the reset email.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'Need help with CampusMarket?\n\n'
          '• Make sure your university is selected correctly.\n'
          '• Add clear photos and accurate descriptions to listings.\n'
          '• Contact sellers through the in-app messaging feature.\n'
          '• Never share your password with another user.\n\n'
          'For this academic version, add your project team’s contact '
          'information here if support contact details are available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'CampusMarket',
      applicationVersion: '1.0.0',
      applicationLegalese: 'A student-focused secondhand marketplace.',
      children: const [
        SizedBox(height: 12),
        Text(
          'CampusMarket helps students list used items, discover products '
          'from their university community, and communicate directly '
          'with buyers and sellers. Payments are arranged independently '
          'between users.',
        ),
      ],
    );
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'Are you sure you want to log out of CampusMarket?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loggingOut = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await _auth.signOut();

      if (!mounted) return;

      // Replace this route with your app's actual login/signup route.
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loggingOut = false);
      _showMessage('Could not log out. Please try again.');
    }
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() {}),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _text(dynamic value, String fallback) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }
    return value.toString().trim();
  }
}

// ==================================================
// MY LISTINGS SCREEN
// ==================================================

// ==================================================
// SAVED ITEMS SCREEN
// ==================================================

class SavedItemsScreen extends StatelessWidget {
  final String uid;
  final FirebaseFirestore db;

  const SavedItemsScreen({
    super.key,
    required this.uid,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      appBar: AppBar(
        title: const Text('Saved Items'),
        backgroundColor: const Color(0xFFF7F8F5),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: db.collection('users').doc(uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return const Center(child: Text('Could not load saved items.'));
          }

          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rawIds = userSnapshot.data?.data()?['favoriteProductIds'];

          final ids =
              rawIds is List ? rawIds.whereType<String>().toList() : <String>[];

          if (ids.isEmpty) {
            return const _EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Nothing saved yet',
              subtitle: 'Tap the heart on a product to save it here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ids.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: db.collection('products').doc(ids[index]).get(),
                builder: (context, productSnapshot) {
                  if (!productSnapshot.hasData) {
                    return const ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('Loading product...'),
                    );
                  }

                  if (!productSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final product = productSnapshot.data!.data()!;
                  final name = (product['name'] ??
                          product['productName'] ??
                          'Untitled product')
                      .toString();
                  final price = product['price'];
                  final image = _productImage(product);

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: image.isEmpty
                            ? const Icon(Icons.image_outlined)
                            : Image.network(
                                image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_outlined),
                              ),
                      ),
                      title: Text(name),
                      subtitle: Text(
                        price == null ? 'Price not set' : '\$$price',
                      ),
                      trailing: IconButton(
                        tooltip: 'Remove from saved items',
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
                          await db.collection('users').doc(uid).update({
                            'favoriteProductIds':
                                FieldValue.arrayRemove([ids[index]]),
                          });
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ==================================================
// SHARED HELPERS
// ==================================================

String _productImage(Map<String, dynamic> product) {
  final imageUrl = product['imageUrl'];
  if (imageUrl is String && imageUrl.startsWith('http')) {
    return imageUrl;
  }

  final images = product['images'] ?? product['productImages'];

  if (images is List) {
    for (final image in images) {
      if (image is String && image.startsWith('http')) {
        return image;
      }
    }
  }

  return '';
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFE5EDE7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 42,
                color: const Color(0xFF315C4C),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
