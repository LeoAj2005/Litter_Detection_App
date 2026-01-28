import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    // FIX: Using POSITIONAL arguments for v17 compatibility
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    const channel = AndroidNotificationChannel(
      'detection_channel',
      'Litter Detections',
      description: 'Notifications when litter is detected',
      importance: Importance.max,
      playSound: true,
    );

    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'detection_channel',
      'Litter Detections',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    // FIX: Using POSITIONAL arguments (id, title, body, details)
    await _notifications.show(
      0,      // id
      title,  // title
      body,   // body
      details // notificationDetails
    );
  }
}