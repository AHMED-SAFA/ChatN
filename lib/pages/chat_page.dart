import 'dart:io';
import 'package:chat/models/message.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/media_service.dart';
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
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.loggedInUserName,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late AuthService _authService;
  final GetIt _getIt = GetIt.instance;
  late MediaService _mediaService;
  ChatUser? currentUser, otherUser;
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _mediaService = _getIt.get<MediaService>();
    currentUser = ChatUser(
      id: _authService.user!.uid,
      // firstName: _authService.user!.displayName,
      firstName: widget.loggedInUserName,
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
      inputOptions: InputOptions(
        alwaysShowSend: true,
        trailing: [
          _mediaMessageButton(),
        ],
      ),
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias?.first.type == MediaType.image) {
        Message message = Message(
          senderID: currentUser!.id,
          senderName: widget.loggedInUserName,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .add(message.toJson());
      }
    } else {
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

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String? imageUrl = await _mediaService.uploadImageToChat(
              file: file, chatId: widget.chatId);

          if (imageUrl != null) {
            ChatMessage chatMessage = ChatMessage(
              createdAt: DateTime.now(),
              user: currentUser!,
              medias: [
                ChatMedia(url: imageUrl, fileName: "", type: MediaType.image),
              ],
            );
            _sendMessage(chatMessage);
          }
        }
      },
      icon: Icon(Icons.attachment),
      color: Colors.black,
    );
  }
}
