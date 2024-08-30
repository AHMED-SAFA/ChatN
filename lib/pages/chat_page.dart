import 'package:chat/models/message.dart';
import 'package:chat/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String loggedInUserName;

  const ChatPage({
    Key? key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.loggedInUserName,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late AuthService _authService;
  final GetIt _getIt = GetIt.instance;
  ChatUser? currentUser, otherUser;
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
    );
    otherUser = ChatUser(
      id: widget.otherUserId,
      firstName: widget.otherUserName,
    );
    _loadMessages();
  }

  void _loadMessages() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        messages = snapshot.docs.map((doc) {
          final messageData = doc.data();
          return ChatMessage(
            user: messageData['senderID'] == currentUser!.id
                ? currentUser!
                : otherUser!,
            text: messageData['content'],
            createdAt: (messageData['sentAt'] as Timestamp).toDate(),
          );
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: _chatUI(),
    );
  }

  Widget _chatUI() {
    return DashChat(
      currentUser: currentUser!,
      onSend: _sendMessage,
      messages: messages,
      messageOptions: const MessageOptions(showTime: true),
      inputOptions: const InputOptions(alwaysShowSend: true),
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    Message message = Message(
      senderID: currentUser!.id,
      senderName: widget.loggedInUserName,
      content: chatMessage.text,
      messageType: MessageType.Text,
      sentAt: Timestamp.fromDate(chatMessage.createdAt),
    );

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(message.toJson());
  }
}
