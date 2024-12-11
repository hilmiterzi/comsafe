import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:comsafe/screens/video_call_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    // Request permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notificationsPlugin.initialize(initSettings);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.data['type'] == 'call') {
        handleCallNotification(message.data['callId']);
      }
    });

    // Handle when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && message.data['type'] == 'call') {
        handleCallNotification(message.data['callId']);
      }
    });

    // Handle when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['type'] == 'call') {
        handleCallNotification(message.data['callId']);
      }
    });
  }

  Future<void> showCallNotification({
    required String callerName,
    required String callerId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'calls_channel',
      'Incoming Calls',
      channelDescription: 'Notifications for incoming calls',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Incoming Call',
      callerName,
      details,
      payload: callerId,
    );
  }

  Future<String?> getDeviceToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  Future<void> handleCallNotification(String callId) async {
    print('📱 Handling call notification for call: $callId');
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          channelName: callId,
          isInitiator: false,
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  if (message.data['type'] == 'call') {
    NotificationService.instance.handleCallNotification(message.data['callId']);
  }
} 