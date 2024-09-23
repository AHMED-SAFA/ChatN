import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/activeUser_service.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/cloud_service.dart';
import 'package:http/http.dart' as http;

class GptPage extends StatefulWidget {
  const GptPage({
    super.key,
  });

  @override
  State<GptPage> createState() => _GptPageState();
}

class _GptPageState extends State<GptPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late CloudService _cloudService;
  late ChatService _chatService;
  late ActiveUserService _activeUserService;
  ChatUser? currentUser, gptBot;
  List<ChatMessage> allMessages = [];
  late String _loggedInUserId;
  Map<String, dynamic>? _loggedInUserData;
  List<Map<String, dynamic>> _users = [];

  final geminiAPi =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyCl4sUoR_sCsn7nGbEu9jCXMnOKHQ2uGlA';

  final header = {'Content-Type: application/json'};

  var data = {
    "contents": [
      {
        "parts": [
          {"text": "Explain how AI works"}
        ]
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _cloudService = _getIt.get<CloudService>();
    _chatService = _getIt.get<ChatService>();
    _activeUserService = _getIt.get<ActiveUserService>();
    _fetchLoggedInUserData();

    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _loggedInUserData?['name'],
    );
    gptBot = ChatUser(
      id: 'gptbotid',
      firstName: 'GPT',
    );
  }

  Future<void> _fetchLoggedInUserData() async {
    _loggedInUserData =
        await _cloudService.fetchLoggedInUserData(userId: _loggedInUserId);
    await _fetchRegisteredUsers();
    setState(() {});
  }

  Future<void> _fetchRegisteredUsers() async {
    if (_loggedInUserData != null) {
      String department = _loggedInUserData?['department'];

      _users = await _cloudService.fetchRegisteredUsers(
        department: department,
        loggedInUserId: _loggedInUserId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "GPT",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 10,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: DashChat(
        currentUser: currentUser!,
        messages: allMessages,
        onSend: (ChatMessage m) {},
      ),
    );
  }
}
