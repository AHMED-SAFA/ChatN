import 'package:chat/services/auth_service.dart';
import 'package:chat/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/cloud_service.dart';

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
  late String _loggedInUserId;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _cloudService = _getIt.get<CloudService>();
    _loggedInUserId = _authService.user!.uid;
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    _users = await _cloudService.fetchRegisteredUsers(
        loggedInUserId: _loggedInUserId);
    setState(() {});
  }

  Future<void> _refreshUsers() async {
    await _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatN"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              bool result = await _authService.logout();
              if (result) _navigationService.pushReplacementNamed("/login");
            },
          ),
        ],
      ),
      drawer: _buildDrawer(), // Add the drawer here
      body: _homeUI(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Center(
              child: Text(
                'ChatN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
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
        ],
      ),
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
                );
              },
            ),
    );
  }
  //   if (_users.isEmpty) {
  //     return const Center(child: Text('No users found.'));
  //   }
  //
  //   return ListView.builder(
  //     itemCount: _users.length,
  //     itemBuilder: (context, index) {
  //       final user = _users[index];
  //       return ListTile(
  //         leading: CircleAvatar(
  //           backgroundImage: NetworkImage(user['profileImageUrl']),
  //         ),
  //         title: Text(user['name']),
  //       );
  //     },
  //   );
  // }
}
