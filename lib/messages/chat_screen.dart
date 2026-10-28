// ============================================================================
//  CHAT FEATURE — JSON in / JSON out. No models. No image compression.
//  Images are read as-is and Base64-encoded straight into Firestore.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:campusmarket/constant/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// ============================================================================
//  IMAGE HELPER — raw file → Base64, no compression, size-guarded
// ============================================================================

class ImageService {
  /// Firestore's hard document limit is 1 MiB. Base64 adds ~33%, so a raw
  /// image must stay under roughly 700 KB or the write is rejected.
  static const int _maxRawBytes = 700 * 1024;

  /// Read the picked file exactly as it is and Base64-encode it.
  /// Throws a readable error if it won't fit in a Firestore document.
  static Future<String> toBase64(File file) async {
    final bytes = await file.readAsBytes();

    if (bytes.length > _maxRawBytes) {
      final kb = (bytes.length / 1024).toStringAsFixed(0);
      throw Exception(
        'Image is ${kb}KB. Firestore caps a document at 1MB, so this '
        'cannot be sent without compression. Pick a smaller image.',
      );
    }
    return base64Encode(bytes);
  }
}

// ============================================================================
//  CHAT SERVICE — takes and returns plain JSON maps
// ============================================================================

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Deterministic id → same two users on the same product always resolve
  /// to the SAME chat, from whichever side opens it first.
  String buildChatId(String productId, String uidA, String uidB) {
    final pair = <String>[uidA, uidB]..sort();
    return '${productId}_${pair[0]}_${pair[1]}';
  }

  /// Pull the uid straight out of the cached user JSON.
  static String uidOf(Map<String, dynamic> userJson) =>
      (userJson['userId'] ?? '').toString();

  /// Open (create if missing) the chat for a product.
  /// `product` is the raw product JSON; `currentUser` is the raw user JSON.
  Future<String> openChat({
    required Map<String, dynamic> product,
    required Map<String, dynamic> currentUser,
  }) async {
    final me = uidOf(currentUser);

    // product.user.userId is the seller; fall back to top-level userId.
    final seller = (product['user'] is Map
            ? (product['user']['userId'] ?? '')
            : (product['userId'] ?? ''))
        .toString();
    final productId = (product['productId'] ?? '').toString();

    if (me.isEmpty) throw Exception('Not signed in');
    if (seller.isEmpty) throw Exception('Product has no owner');
    if (me == seller) throw Exception('You cannot message yourself');

    final chatId = buildChatId(productId, me, seller);
    final ref = _db.collection('chats').doc(chatId);
    final snap = await ref.get();

    if (!snap.exists) {
      // `images` is an array of Base64 strings in your product JSON.
      final images = (product['images'] as List?) ?? const [];
      final firstImage =
          images.isNotEmpty ? images.first?.toString() ?? '' : '';
      final sellerMap =
          product['user'] is Map ? product['user'] as Map : const {};
      final buyerName = (currentUser['name'] ?? '').toString();
      final sellerName =
          (sellerMap['name'] ?? product['sellerName'] ?? '').toString();
      await ref.set({
        'productImage': firstImage,
        'buyerName': buyerName, // 👈 add
        'sellerName': sellerName, // 👈 add
        'buyerId': me,
        'chatId': chatId,
        'participants': [me, seller],
        'participantsMap': {me: true, seller: true},
        'productId': productId,
        'productTitle': (product['name'] ?? '').toString(),
        // 'productImage': firstImage,
        // 'buyerId': me,
        'sellerId': seller,
        'buyerTag': 'buy', // 👈 buyer's message-list filter tag
        'sellerTag': 'sell', // 👈 seller's message-list filter tag
        'lastMessage': '',
        'lastMessageType': 'text',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': '',
        'unread': {me: 0, seller: 0},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();

    await _db.runTransaction((tx) async {
      tx.set(msgRef, {
        'messageId': msgRef.id,
        'senderId': senderId,
        'type': 'text',
        'text': trimmed,
        'imageBase64': null,
        'createdAt': FieldValue.serverTimestamp(),
        'clientId': '${senderId}_${DateTime.now().millisecondsSinceEpoch}',
        'readBy': {senderId: true},
      });
      tx.update(chatRef, {
        'lastMessage': trimmed,
        'lastMessageType': 'text',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
        'unread.$receiverId': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Raw Base64, no compression. Throws if the image exceeds the limit.
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required File image,
  }) async {
    final base64Image = await ImageService.toBase64(image);

    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();

    await _db.runTransaction((tx) async {
      tx.set(msgRef, {
        'messageId': msgRef.id,
        'senderId': senderId,
        'type': 'image',
        'text': null,
        'imageBase64': base64Image, // 👈 stored inline, unmodified
        'createdAt': FieldValue.serverTimestamp(),
        'clientId': '${senderId}_${DateTime.now().millisecondsSinceEpoch}',
        'readBy': {senderId: true},
      });
      tx.update(chatRef, {
        'lastMessage': '📷 Photo',
        'lastMessageType': 'image',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
        'unread.$receiverId': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> markChatRead({
    required String chatId,
    required String userId,
  }) {
    return _db.collection('chats').doc(chatId).update({'unread.$userId': 0});
  }
}

// ============================================================================
//  PRODUCT DETAIL BUTTON — pass in the product JSON
// ============================================================================

class MessageOwnerButton extends StatefulWidget {
  /// The full product JSON you already have on the detail screen.
  final Map<String, dynamic> product;

  /// The current user JSON from preferences.
  final Map<String, dynamic> currentUser;

  const MessageOwnerButton({
    super.key,
    required this.product,
    required this.currentUser,
  });

  @override
  State<MessageOwnerButton> createState() => _MessageOwnerButtonState();
}

class _MessageOwnerButtonState extends State<MessageOwnerButton> {
  final ChatService _service = ChatService();
  bool _loading = false;

  Future<void> _onPress() async {
    setState(() => _loading = true);
    try {
      final chatId = await _service.openChat(
        product: widget.product,
        currentUser: widget.currentUser,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            currentUser: widget.currentUser,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ChatService.uidOf(widget.currentUser);
    final seller = (widget.product['user'] is Map
            ? (widget.product['user']['userId'] ?? '')
            : (widget.product['userId'] ?? ''))
        .toString();

    if (me.isEmpty || me == seller) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _onPress,
        icon: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chat_bubble_outline),
        label: const Text('Send Message to Owner'),
      ),
    );
  }
}

// ============================================================================
//  CHAT SCREEN — works from product detail AND the message list
// ============================================================================

class ChatScreen extends StatefulWidget {
  final String chatId;

  /// The current user JSON from preferences (for the uid).
  final Map<String, dynamic> currentUser;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const int _pageSize = 30;

  final ChatService _service = ChatService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  late final String _myUid = ChatService.uidOf(widget.currentUser);

  late final CollectionReference _messagesRef =
      _db.collection('chats').doc(widget.chatId).collection('messages');

  // All state is plain JSON — no models.
  Map<String, dynamic>? _chat;
  List<Map<String, dynamic>> _messages = [];
  String _buyerId = '';
  String _partnerId = '';
  String _myTag = 'buy';

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _sending = false;
  DocumentSnapshot? _lastDoc;

  StreamSubscription? _chatSub;
  StreamSubscription? _msgSub;

  @override
  void initState() {
    super.initState();
    _subscribeChat();
    _subscribeMessages();
    _markRead();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    _msgSub?.cancel();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadOlder();
    }
  }

  /* ---------- watch the chat doc (product / partner / tag) ---------- */
  void _subscribeChat() {
    _chatSub =
        _db.collection('chats').doc(widget.chatId).snapshots().listen((snap) {
      if (!snap.exists) return;
      final d = (snap.data() as Map<String, dynamic>?) ?? {};

      final parts = List<String>.from(d['participants'] ?? const []);
      final buyer = (d['buyerId'] ?? '').toString();
      final partner = parts.firstWhere((p) => p != _myUid, orElse: () => '');

      // Tag for THIS user: buyer sees buyerTag, seller sees sellerTag.
      final tag = (buyer == _myUid
              ? (d['buyerTag'] ?? 'buy')
              : (d['sellerTag'] ?? 'sell'))
          .toString();

      if (!mounted) return;
      setState(() {
        _chat = d;
        _buyerId = buyer;
        _partnerId = partner;
        _myTag = tag;
      });
    });
  }

  /* ---------- watch the newest page of messages ---------- */
  void _subscribeMessages() {
    _msgSub = _messagesRef
        .orderBy('createdAt', descending: true)
        .limit(_pageSize)
        .snapshots()
        .listen((snap) {
      final list = snap.docs.map((d) {
        final m = (d.data() as Map<String, dynamic>?) ?? {};
        return <String, dynamic>{'id': d.id, ...m};
      }).toList();

      if (!mounted) return;
      setState(() {
        _messages = list;
        _lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
        _hasMore = snap.docs.length == _pageSize;
        _loading = false;
      });
    }, onError: (_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  /* ---------- load older messages ---------- */
  Future<void> _loadOlder() async {
    if (_loadingMore || !_hasMore || _lastDoc == null) return;
    setState(() => _loadingMore = true);
    try {
      final snap = await _messagesRef
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(_pageSize)
          .get();

      final older = snap.docs.map((d) {
        final m = (d.data() as Map<String, dynamic>?) ?? {};
        return <String, dynamic>{'id': d.id, ...m};
      }).toList();

      if (!mounted) return;
      setState(() {
        _messages = [..._messages, ...older];
        if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;
        _hasMore = snap.docs.length == _pageSize;
      });
    } catch (_) {
      // stop paging on error
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _markRead() {
    if (_myUid.isEmpty) return;
    _service
        .markChatRead(chatId: widget.chatId, userId: _myUid)
        .catchError((_) {});
  }

  /* ---------- send text ---------- */
  Future<void> _sendText() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending || _partnerId.isEmpty || _myUid.isEmpty) {
      return;
    }
    _textController.clear();
    setState(() => _sending = true);
    try {
      await _service.sendTextMessage(
        chatId: widget.chatId,
        senderId: _myUid,
        receiverId: _partnerId,
        text: text,
      );
      _scrollToBottom();
    } catch (e) {
      _snack('Send failed: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /* ---------- send image (raw, no compression) ---------- */
  Future<void> _pickAndSendImage(ImageSource source) async {
    if (_partnerId.isEmpty) return;
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    setState(() => _sending = true);
    try {
      await _service.sendImageMessage(
        chatId: widget.chatId,
        senderId: _myUid,
        receiverId: _partnerId,
        image: File(picked.path),
      );
      _scrollToBottom();
    } catch (e) {
      _snack('Image failed: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  /* ---------- build ---------- */
  @override
  Widget build(BuildContext context) {
    final isBuy = _myTag == 'buy';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (_chat?['productTitle'] ?? '').toString().isEmpty
                  ? 'Chat'
                  : _chat!['productTitle'].toString(),
              style: const TextStyle(fontSize: 16),
            ),
            if (_chat != null)
              Text(
                isBuy ? 'Buying' : 'Selling', // 👈 per-user tag
                style: TextStyle(
                  fontSize: 12,
                  color: isBuy ? Colors.blueAccent : Colors.green,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true, // newest at the bottom
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: _messages.length + (_loadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          final m = _messages[index];
                          final isMine = (m['senderId'] ?? '') == _myUid;
                          return _buildBubble(m, isMine, _messages, index);
                        },
                      ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No messages yet.\nSay hello 👋',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> m, bool isMine,
      List<Map<String, dynamic>> messages, int ind) {
    final type = (m['type'] ?? 'text').toString();
    final text = m['text'];
    final b64 = m['imageBase64'];
    final createdAt = m['createdAt'];

    String timeLabel = '';
    if (createdAt is Timestamp) {
      timeLabel = DateFormat('h:mm a').format(createdAt.toDate());
    }

    return Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTapDown: (d) async {
            final overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;

            final selected = await showMenu<String>(
              context: context,
              position: RelativeRect.fromRect(
                d.globalPosition & const Size(1, 1),
                Offset.zero & overlay.size,
              ),
              items: [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: whiteColor)),
                ),
              ],
            );
            print(selected);
            if (selected == 'delete') {
              setState(() => messages = [...messages]
                ..removeWhere((x) => x['id'] == m['id']));
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            decoration: BoxDecoration(
              color: isMine ? Colors.blueAccent : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (type == 'image' && b64 is String && b64.isNotEmpty)
                  _buildImage(b64)
                else
                  Text(
                    (text ?? '').toString(),
                    style: TextStyle(
                      color: isMine ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  timeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMine ? Colors.white70 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildImage(String b64) {
    try {
      final bytes = base64Decode(b64);
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          bytes,
          width: 200,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 40),
        ),
      );
    } catch (_) {
      return const Icon(Icons.broken_image, size: 40);
    }
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _sending ? null : _showImageOptions,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendText(),
              ),
            ),
            IconButton(
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              onPressed: _sending ? null : _sendText,
            ),
          ],
        ),
      ),
    );
  }
}
