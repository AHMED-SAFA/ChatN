import 'package:chat/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NotificationService _notificationService;

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _notificationService = _getIt.get<NotificationService>();

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
          ? const Center(
              child: CircularProgressIndicator(),
            )
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
        String notificationId = notification['id'];

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
                try {
                  String receiverId = _authService.user!.uid;
                  await _notificationService.deleteNotification(
                    receiverId: receiverId,
                    notificationId: notificationId,
                  );
                  setState(() {
                    _notifications.removeAt(index);
                  });
                  showToast(
                    'Notification Deleted!',
                    context: context,
                    animation: StyledToastAnimation.scale,
                    reverseAnimation: StyledToastAnimation.fade,
                    position: StyledToastPosition.bottom,
                    animDuration: Duration(seconds: 1),
                    duration: Duration(seconds: 4),
                    curve: Curves.elasticOut,
                    reverseCurve: Curves.linear,
                  );
                } catch (e) {
                  showToast(
                    'Notification could not delete!',
                    context: context,
                    animation: StyledToastAnimation.scale,
                    reverseAnimation: StyledToastAnimation.fade,
                    position: StyledToastPosition.bottom,
                    animDuration: Duration(seconds: 1),
                    duration: Duration(seconds: 4),
                    curve: Curves.elasticOut,
                    reverseCurve: Curves.linear,
                  );
                }
              },
              icon: const Icon(Icons.delete),
            ),
          ),
        );
      },
    );
  }
}
