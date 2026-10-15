// ============================================================================
//  MESSAGE LIST SCREEN — JSON-driven, no models, WhatsApp-style.
//  Two tabs: Buying / Selling. Tap a row → opens ChatScreen.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'chat_screen.dart'; // the chat screen from before

class MessagesScreen extends StatefulWidget {
  /// Current user JSON from preferences.
  final Map<String, dynamic> currentUser;

  const MessagesScreen({super.key, required this.currentUser});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final String _myUid = widget.currentUser['userId'].toString();

  late final CollectionReference _chatsRef = _db.collection('chats');

  StreamSubscription? _sub;

  List<Map<String, dynamic>> _allChats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _subscribeChats();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _partnerName(Map<String, dynamic> chat) {
    final buyerId = (chat['buyerId'] ?? '').toString();
    final isBuyer = buyerId == _myUid;

    final name = (isBuyer ? chat['sellerName'] : chat['buyerName'])?.toString();
    if (name != null && name.isNotEmpty) return name;

    // Fallback for old chats: fall back to the product title
    final productTitle = (chat['productTitle'] ?? '').toString();
    return productTitle.isEmpty ? 'User' : productTitle;
  }

  /* ---------- watch every chat this user is part of ---------- */
  void _subscribeChats() {
    _sub = _chatsRef
        .where('participants', arrayContains: _myUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .listen((snap) {
      final list = snap.docs.map((d) {
        final m = (d.data() as Map<String, dynamic>?) ?? {};
        return <String, dynamic>{'chatId': d.id, ...m};
      }).toList();

      if (!mounted) return;
      setState(() {
        _allChats = list;
        _loading = false;
      });
    }, onError: (_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  /* ---------- split into buying / selling for THIS user ---------- */
  List<Map<String, dynamic>> _filtered(String tag) {
    return _allChats.where((c) {
      final buyerId = (c['buyerId'] ?? '').toString();
      final isBuy = buyerId == _myUid;
      return tag == 'buy' ? isBuy : !isBuy;
    }).toList();
  }

  /* ---------- open the chat ---------- */
  void _openChat(Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chat['chatId'].toString(),
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  /* ---------- unread count for THIS user ---------- */
  int _myUnread(Map<String, dynamic> chat) {
    final unread = chat['unread'];
    if (unread is Map && unread[_myUid] is num) {
      return (unread[_myUid] as num).toInt();
    }
    return 0;
  }

  /* ---------- time label like WhatsApp ---------- */
  String _timeLabel(dynamic ts) {
    if (ts is! Timestamp) return '';
    final dt = ts.toDate();
    final now = DateTime.now();

    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day;

    if (isToday) return DateFormat('h:mm a').format(dt);
    if (isYesterday) return 'Yesterday';
    if (dt.year == now.year) return DateFormat('d MMM').format(dt);
    return DateFormat('d MMM yy').format(dt);
  }

  /* ---------- last message text ---------- */
  String _preview(Map<String, dynamic> chat) {
    final last = (chat['lastMessage'] ?? '').toString();
    if (last.isEmpty) return 'No messages yet';
    return last;
  }

  /* ---------- decode first product image (Base64) into bytes ---------- */
  _thumbBytes(Map<String, dynamic> chat) {
    final b64 = (chat['productImage'] ?? '').toString();
    if (b64.isEmpty) return null;
    try {
      var base = base64Decode(b64);
      return base;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Buying'),
              Tab(text: 'Selling'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildList(_filtered('buy'), 'No buying chats yet'),
                  _buildList(_filtered('sell'), 'No selling chats yet'),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> chats, String emptyText) {
    if (chats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: chats.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
      itemBuilder: (context, index) {
        final chat = chats[index];
        final unread = _myUnread(chat);
        final bytes = _thumbBytes(chat);
        final title = (chat['productTitle'] ?? '').toString();
        final lastMessageAt = chat['lastMessageAt'];

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: bytes != null ? MemoryImage(bytes) : null,
            child: bytes == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: Text(
            _partnerName(chat),
            // title.isEmpty ? 'Chat' : title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          subtitle: Text(
            _preview(chat),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unread > 0 ? Colors.black87 : Colors.black54,
              fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _timeLabel(lastMessageAt),
                style: TextStyle(
                  fontSize: 12,
                  color: unread > 0 ? Colors.green : Colors.black45,
                  fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              if (unread > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unread > 99 ? '99+' : unread.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox(height: 18),
            ],
          ),
          onTap: () => _openChat(chat),
        );
      },
    );
  }
}
