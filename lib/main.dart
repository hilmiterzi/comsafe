import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/navigation_service.dart';
import 'screens/incoming_call_screen.dart';
import 'screens/video_call_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();
  
  if (message.data['type'] == 'group_call') {
    NavigationService.navigateTo(
      IncomingCallScreen(
        callerName: 'Group Call',
        onAccept: () {
          final callId = message.data['callId'];
          NavigationService.navigateTo(
            VideoCallScreen(
              channelName: callId,
              isInitiator: false,
            ),
          );
        },
        onDecline: () => NavigationService.navigatorKey.currentState?.pop(),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationService = NotificationService();
  await notificationService.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.data['type'] == 'group_call') {
      NavigationService.navigateTo(
        IncomingCallScreen(
          callerName: 'Group Call',
          onAccept: () {
            final callId = message.data['callId'];
            NavigationService.navigateTo(
              VideoCallScreen(
                channelName: callId,
                isInitiator: false,
              ),
            );
          },
          onDecline: () => NavigationService.navigatorKey.currentState?.pop(),
        ),
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'ComSafe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

