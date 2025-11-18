import 'package:cutomer_app/Notification/Notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'NotificationModel.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // Simulate loading notifications (can be replaced with API call)
  void fetchNotifications() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }

  // When a new push notification arrives
  void handleNotification(RemoteMessage message) {
    final newNotification = NotificationModel(
      title: message.notification?.title ?? "No Title",
      body: message.notification?.body ?? "No Body",
      type: message.data['type'] ?? 'general',
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Add new notification to top of list
    notifications.insert(0, newNotification);

    // Increase unread count
    unreadCount.value++;

    // ✅ Navigate to Notifications screen only if not already there
    if (Get.currentRoute != '/NotificationScreen') {
      Get.to(() => NotificationScreen());
    }
  }

  // Remove a specific notification
  void removeNotification(int index) {
    final removed = notifications[index];
    notifications.removeAt(index);
    if (!removed.isRead) {
      unreadCount.value =
          (unreadCount.value - 1).clamp(0, notifications.length);
    }
  }

  // ✅ Mark all notifications as read (called when Notification screen opens)
  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    unreadCount.value = 0;
  }
}
