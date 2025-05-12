// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  // Method to subscribe to the group topic
  Future<void> subscribeToGroup(String groupId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic('group_$groupId');
    print('Subscribed to group topic: group_$groupId');
  }

  // You can add more methods here for handling notifications
}