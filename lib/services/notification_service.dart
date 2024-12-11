import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';
import 'package:comsafe/screens/incoming_call_screen.dart';
import 'navigation_service.dart';

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
      enableLights: true,
      showBadge: true,
      audioAttributesUsage: AudioAttributesUsage.voiceCommunication,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    NavigationService.navigateTo(
      IncomingCallScreen(
        callerName: 'Incoming Call',
        onAccept: () {
          // Handle call accept
          NavigationService.navigatorKey.currentState?.pop();
        },
        onDecline: () {
          // Handle call decline
          NavigationService.navigatorKey.currentState?.pop();
        },
      ),
    );
  }

  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> showCallNotification({
    required String callerName,
    required String callerId,
  }) async {
    final androidNotificationDetails = AndroidNotificationDetails(
      'calls_channel',
      'Incoming Calls',
      channelDescription: 'Used for incoming call notifications',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      sound: const RawResourceAndroidNotificationSound('incoming_call'),
      playSound: true,
      ongoing: true,
      autoCancel: false,
      visibility: NotificationVisibility.public,
      ticker: 'Incoming Call',
      additionalFlags: Int32List.fromList(<int>[
        4,    // FLAG_INSISTENT
        32,   // FLAG_HIGH_PRIORITY
        128,  // FLAG_ONGOING_EVENT
        1024, // FLAG_NO_CLEAR
      ]),
    );

    await _localNotifications.show(
      callerId.hashCode,
      'Incoming Call',
      callerName,
      NotificationDetails(android: androidNotificationDetails),
    );
  }
} 