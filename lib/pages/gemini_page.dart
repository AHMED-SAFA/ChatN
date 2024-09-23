import 'dart:convert';
import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/cloud_service.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  ChatUser? myself;
  ChatUser bot = ChatUser(id: "2", firstName: "Gemini");
  List<ChatMessage> allMassages = [];
  List<ChatUser> typing = [];
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late CloudService _cloudService;
  late String _loggedInUserId;
  Map<String, dynamic>? _loggedInUserData;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();

    _authService = _getIt.get<AuthService>();
    _cloudService = _getIt.get<CloudService>();
    _loggedInUserId = _authService.user!.uid;
    _fetchLoggedInUserData();
  }

  final geminiAPi =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyCl4sUoR_sCsn7nGbEu9jCXMnOKHQ2uGlA";
  final header = {'Content-Type': 'application/json'};

  Future<void> _fetchLoggedInUserData() async {
    _loggedInUserData =
        await _cloudService.fetchLoggedInUserData(userId: _loggedInUserId);
    await _fetchRegisteredUsers();
    // Initialize muself after fetching the logged-in user data
    setState(() {
      myself = ChatUser(
        id: _loggedInUserId,
        firstName: _loggedInUserData?['name'],
      );
    });
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

  getData(ChatMessage m) async {
    typing.add(bot);
    allMassages.insert(0, m);
    setState(() {});
    var data = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };

    await http
        .post(Uri.parse(geminiAPi), headers: header, body: jsonEncode(data))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);
        print(result["candidates"][0]["content"]["parts"][0]["text"]);
        ChatMessage m1 = ChatMessage(
          user: bot,
          createdAt: DateTime.now(),
          text: result["candidates"][0]["content"]["parts"][0]["text"],
        );
        allMassages.insert(0, m1);
      } else {
        print("Error occurred");
      }
    }).catchError((e) {});
    typing.remove(bot);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: myself == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : DashChat(
              messageOptions: const MessageOptions(
                  showTime: true,
                  textColor: Colors.white,
                  containerColor: Colors.black,
                  showOtherUsersName: true),
              typingUsers: typing,
              currentUser: myself!,
              onSend: (ChatMessage m) {
                getData(m);
              },
              messages: allMassages,
            ),
    );
  }
}
