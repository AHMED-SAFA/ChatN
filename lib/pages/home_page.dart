import 'package:chat/services/auth_service.dart';
import 'package:chat/services/navigation_service.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/chat_service.dart';
import '../services/cloud_service.dart';
import 'chat_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late CloudService _cloudService;
  late ChatService _chatService;
  late String _loggedInUserId;
  Map<String, dynamic>? _loggedInUserData;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    // _notificationService = _getIt.get<NotificationService>();
    _cloudService = _getIt.get<CloudService>();
    _chatService = _getIt.get<ChatService>();
    _loggedInUserId = _authService.user!.uid;
    _fetchLoggedInUserData();
  }

  Future<void> _fetchUsers() async {
    if (_loggedInUserData != null) {
      String department = _loggedInUserData!['department'];

      _users = await _cloudService.fetchRegisteredUsers(
        department: department,
        loggedInUserId: _loggedInUserId,
      );

      setState(() {});
    }
  }

  Future<void> _refreshUsers() async {
    await _fetchUsers();
  }

  Future<void> _fetchLoggedInUserData() async {
    _loggedInUserData =
        await _cloudService.fetchLoggedInUserData(userId: _loggedInUserId);
    await _fetchUsers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _loggedInUserData != null
              ? '${_loggedInUserData!['name']}(${_loggedInUserData!['department']})'
              : 'Person',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _homeUI(),
    );
  }

  Widget _homeUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        child: _availableList(),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _loggedInUserData != null
                      ? "Welcome ${_loggedInUserData!['name']}"
                      : 'Person',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              _navigationService.pushNamed('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              bool result = await _authService.logout();
              if (result) {
                _navigationService.pushReplacementNamed("/login");
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel_presentation_outlined),
            title: const Text('Delete account'),
            onTap: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await _cloudService.deleteUserAccount(user.uid);
                _navigationService.pushReplacementNamed("/login");
                DelightToastBar(
                  builder: (context) => const ToastCard(
                    leading: Icon(
                      Icons.offline_pin_rounded,
                      size: 28,
                    ),
                    title: Text(
                      "Your account removed successfully",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ).show(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _availableList() {
    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: _users.isEmpty
          ? const Center(child: Text('No users found.'))
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['profileImageUrl']),
                  ),
                  title: Text(user['name']),
                  onTap: () async {
                    String chatId = await _chatService.createOrGetChat(
                      userId1: _loggedInUserId,
                      name1: _loggedInUserData!['name'],
                      userId2: user['userId'],
                      name2: user['name'],
                    );

                    _navigationService.push(
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          loggedInUserName: _loggedInUserData!['name'],
                          otherUserName: user['name'],
                          chatId: chatId,
                          currentUserId: _loggedInUserId,
                          otherUserId: user['userId'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
