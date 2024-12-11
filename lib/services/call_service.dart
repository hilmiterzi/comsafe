import 'package:firebase_messaging/firebase_messaging.dart';

class CallService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  
  Future<String?> getDeviceToken() async {
    return await firebaseMessaging.getToken();
  }

  // Listen for incoming call notifications
  void listenForCalls() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'video_call') {
        // Show incoming call UI
        // Join Agora channel using message.data['channelName']
      }
    });
  }
} 