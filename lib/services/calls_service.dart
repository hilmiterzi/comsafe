import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CallsService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  // Get device ID from FCM token
  Future<String> get _deviceId async {
    return await FirebaseMessaging.instance.getToken() ?? 'unknown';
  }

  // Listen for incoming calls
  Stream<Map<String, dynamic>> listenForCalls() {
    return _database.child('calls').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {};
      return Map<String, dynamic>.from(data);
    });
  }

  // Start a group call
  Future<void> startGroupCall() async {
    final callId = DateTime.now().millisecondsSinceEpoch.toString();
    final deviceId = await _deviceId;
    
    await _database.child('calls').set({
      'callId': callId,
      'initiator': deviceId,
      'timestamp': ServerValue.timestamp,
      'status': 'active',
      'participants': {
        deviceId: 'initiator'
      }
    });
  }

  // Join a call
  Future<void> joinCall(String callId) async {
    final deviceId = await _deviceId;
    await _database.child('calls/participants/$deviceId').set('joined');
  }

  // End call
  Future<void> endCall(String callId) async {
    await _database.child('calls').remove();
  }
} 