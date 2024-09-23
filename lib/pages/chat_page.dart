import 'dart:io';
import 'package:chat/models/message.dart';
import 'package:chat/services/activeUser_service.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/media_service.dart';
import 'package:chat/services/notification_service.dart';
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
  late ChatService _chatService;
  late NotificationService _notificationService;
  late ActiveUserService _activeUserService;
  late MediaService _mediaService;
  final GetIt _getIt = GetIt.instance;
  ChatUser? currentUser, otherUser;
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _chatService = _getIt.get<ChatService>();
    _activeUserService = _getIt.get<ActiveUserService>();
    _mediaService = _getIt.get<MediaService>();
    _notificationService = _getIt.get<NotificationService>();

    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: widget.loggedInUserName,
    );
    otherUser = ChatUser(
      id: widget.otherUserId,
      firstName: widget.otherUserName,
    );

    _getMessages();
  }

  Future<void> _getMessages() async {
    _chatService.getMessages(widget.chatId).listen((QuerySnapshot snapshot) {
      List<ChatMessage> loadedMessages = snapshot.docs.map((doc) {
        Message message = Message.fromJson(doc.data() as Map<String, dynamic>);

        if (message.messageType == MessageType.Text) {
          return ChatMessage(
            user: message.senderID == widget.currentUserId
                ? currentUser!
                : otherUser!,
            text: message.content!,
            createdAt: message.sentAt!.toDate(),
          );
        } else {
          return ChatMessage(
            user: message.senderID == widget.currentUserId
                ? currentUser!
                : otherUser!,
            medias: [
              ChatMedia(
                url: message.content!,
                fileName: "",
                type: MediaType.image,
              ),
            ],
            createdAt: message.sentAt!.toDate(),
          );
        }
      }).toList();

      setState(() {
        messages = loadedMessages;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: DashChat(
        currentUser: currentUser!,
        messages: messages,
        onSend: _sendMessage,
        inputOptions: InputOptions(
          trailing: [
            _mediaMessageButton(),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    Message? message;

    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        message = Message(
          senderID: currentUser!.id,
          senderName: widget.loggedInUserName,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
      }
    } else {
      // Handle the text message case
      message = Message(
        senderID: currentUser!.id,
        senderName: widget.loggedInUserName,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
    }
    if (message != null) {
      await _chatService.addMessage(
        chatId: widget.chatId,
        message: message,
      );

      // Check if the other user is active
      bool isOtherUserActive = await _activeUserService.getActiveUsersStatus(
        userID: widget.otherUserId,
      );

      // Store notification only if the user is inactive
      if (!isOtherUserActive) {
        await _notificationService.storeNotificationForMessage(
          chatId: widget.chatId,
          loggedInUserId: widget.currentUserId,
          loggedInUserName: widget.loggedInUserName,
          receiverId: widget.otherUserId,
        );
      }
    } else {
      throw Exception("Failed to create message. Please try again.");
    }
  }

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String? downloadImgUrl =
              await _mediaService.uploadImageToStorageFromChatUpload(
            file: file,
            chatId: widget.chatId,
          );

          if (downloadImgUrl != null) {
            ChatMessage chatMessage = ChatMessage(
              user: currentUser!,
              createdAt: DateTime.now(),
              medias: [
                ChatMedia(
                  url: downloadImgUrl,
                  fileName: "",
                  type: MediaType.image,
                ),
              ],
            );
            _sendMessage(chatMessage);
          }
        }
      },
      icon: const Icon(Icons.attachment),
      color: Colors.black,
    );
  }
}
