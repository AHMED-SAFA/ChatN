import 'package:chat/services/notification_service.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/cloud_service.dart';
import '../services/navigation_service.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late NotificationService _notificationService;
  late CloudService _cloudService;
  late ChatService _chatService;

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _notificationService = _getIt.get<NotificationService>();
    _cloudService = _getIt.get<CloudService>();
    _chatService = _getIt.get<ChatService>();

    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      String receiverId = _authService.user!.uid;
      List<Map<String, dynamic>> notifications = await _notificationService
          .retrieveNotifications(receiverId: receiverId);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error retrieving notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _viewNotifications(),
    );
  }

  Widget _viewNotifications() {
    if (_notifications.isEmpty) {
      return const Center(child: Text("No notifications available."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              notification['senderName'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Received at: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(notification['timestamp'])}",
            ),
            trailing: IconButton(
              onPressed: () async {

              },
              icon: const Icon(Icons.delete),
            ),
          ),
        );
      },
    );
  }
}
