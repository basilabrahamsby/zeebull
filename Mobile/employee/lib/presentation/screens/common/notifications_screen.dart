
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../../../data/models/notification_model.dart'; // Ensure correct import

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all',
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).clearAll();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: ${provider.error}", style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchNotifications(),
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return const Center(child: Text("No notifications"));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchNotifications();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final note = provider.notifications[index];
                return _buildNotificationCard(context, note, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotification note, NotificationProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: note.isRead ? Colors.white : Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: _getIconForType(note.type),
        title: Text(
          note.title, 
          style: TextStyle(
            fontWeight: note.isRead ? FontWeight.normal : FontWeight.bold
          )
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(note.message),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(note.createdAt), 
              style: TextStyle(color: Colors.grey[500], fontSize: 12)
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          if (!note.isRead) {
            provider.markAsRead(note.id);
          }
          // Optionally navigate to details if entity_type is present
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hours ago";
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }

  Widget _getIconForType(String type) {
    IconData icon;
    Color color;
    switch (type.toLowerCase()) {
      case 'service':
      case 'assignment':
        icon = Icons.assignment;
        color = Colors.blue;
        break;
      case 'booking':
        icon = Icons.book_online;
        color = Colors.green;
        break;
      case 'finance':
      case 'expense':
        icon = Icons.account_balance_wallet;
        color = Colors.orange;
        break;
      case 'food_order':
        icon = Icons.restaurant;
        color = Colors.red;
        break;
      case 'info':
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color),
    );
  }
}
