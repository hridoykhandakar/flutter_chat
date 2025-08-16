import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/material.dart';

final User? loginUser = FirebaseAuth.instance.currentUser;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  static const String id = "chat_screen";
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String messageText;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  void logOut() async {
    final shouldLogout = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "conform Logout",
            style: TextStyle(color: Colors.black54),
          ),
          content: Text("Are you sure you want to logout"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  initState() {
    super.initState();
    messageStream();
    // Scroll to bottom after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _getValue() {
    messageText = _messageController.text;
  }

  void messageStream() async {
    await for (var snapshot
        in _firestore
            .collection("messages")
            .orderBy('timestamp', descending: true)
            .snapshots()) {}
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: logOut, icon: Icon(Icons.close))],
        title: Text("⚡Chat"),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MessageStream(
              firestore: _firestore,
              scrollController: _scrollController,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Messages",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 80,
                  child: TextButton(
                    onPressed: () async {
                      _getValue();
                      final messageText = _messageController.text.trim();
                      if (messageText.isEmpty) return null;

                      try {
                        await _firestore.collection("messages").add({
                          "text": messageText.trim(),
                          "sender": loginUser?.email,
                          "timestamp": FieldValue.serverTimestamp(),
                        });
                        _messageController.clear();
                        // Auto-scroll to bottom after sending message
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });
                      } catch (e) {
                        print(e);
                      }
                    },

                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blueAccent,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      "Send",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({
    super.key,
    required FirebaseFirestore firestore,
    required ScrollController scrollController,
  }) : _firestore = firestore,
       _scrollController = scrollController;

  final FirebaseFirestore _firestore;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("messages")
          .orderBy(
            'timestamp',
            descending: false,
          ) // Changed to false to show newest at bottom
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          List<Widget> messageWidgets = [];
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              final currentUser = loginUser?.email;
              final text = data["text"];
              final user = data["sender"];
              final messageWidget = ChatBubble(
                message: text,
                sender: user,
                isSendByMe: currentUser == user,
              );
              messageWidgets.add(messageWidget);
            }
          }

          // Auto-scroll to bottom when new messages arrive
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          return Expanded(
            child: ListView(
              controller: _scrollController, // Added scroll controller
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              children: messageWidgets,
            ),
          );
        }
        return Text("nothing to show");
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final String sender;
  final bool isSendByMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.sender,
    required this.isSendByMe,
  });
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSendByMe ? Alignment.topRight : Alignment.topLeft,
      child: Column(
        crossAxisAlignment: isSendByMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(sender, style: TextStyle(fontSize: 14, color: Colors.black45)),
          Container(
            decoration: BoxDecoration(
              color: isSendByMe ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: isSendByMe ? Radius.circular(16) : Radius.circular(4),
                topRight: isSendByMe ? Radius.circular(4) : Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isSendByMe ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
