import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for calls
    await _createCallNotificationChannel();

    _isInitialized = true;
  }

  Future<void> _createCallNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'calls_channel',
      'Incoming Calls',
      description: 'Used for incoming call notifications',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('incoming_call'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> showCallNotification({
    required String callerName,
    required String callerId,
  }) async {
    await _localNotifications.show(
      callerId.hashCode,
      'Incoming Call',
      callerName,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'calls_channel',
          'Incoming Calls',
          channelDescription: 'Used for incoming call notifications',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          sound: const RawResourceAndroidNotificationSound('incoming_call'),
          playSound: true,
          ongoing: true,
          category: AndroidNotificationCategory.call,
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction('answer', 'Answer'),
            const AndroidNotificationAction('decline', 'Decline'),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'incoming_call.aiff',
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
      payload: callerId,
    );
  }
} 