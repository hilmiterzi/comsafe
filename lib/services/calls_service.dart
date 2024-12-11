import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CallsService {
  static final CallsService _instance = CallsService._internal();
  late final DatabaseReference _database;

  factory CallsService() {
    return _instance;
  }

  CallsService._internal() {
    print('🔥 Setting Database URL');
    FirebaseDatabase.instance.databaseURL = 'https://generation-671ae-default-rtdb.europe-west1.firebasedatabase.app';
    _database = FirebaseDatabase.instance.ref();
    print('✅ Database initialized with URL: ${FirebaseDatabase.instance.databaseURL}');
  }

  // Get device ID from FCM token
  Future<String> get _deviceId async {
    final token = await FirebaseMessaging.instance.getToken();
    print('📱 Device Token: $token');
    return token ?? 'unknown';
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
    print('📞 Starting group call');
    final callId = DateTime.now().millisecondsSinceEpoch.toString();
    final deviceId = await _deviceId;
    
    print('🆔 Creating call with ID: $callId');
    try {
      await _database.child('calls').set({
        'callId': callId,
        'initiator': deviceId,
        'timestamp': ServerValue.timestamp,
        'status': 'active',
        'participants': {
          deviceId: 'initiator'
        }
      });
      print('✅ Call created successfully');
      
      // Send notification to all users
      await FirebaseMessaging.instance.subscribeToTopic('all_users');
      print('📱 Sending notification to all users');
    } catch (e) {
      print('❌ Error: $e');
    }
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

  // Decline call
  Future<void> declineCall(String callId) async {
    try {
      await _database.child('calls').child(callId).update({
        'status': 'declined'
      });
      print('✅ Call declined successfully');
    } catch (e) {
      print('❌ Error declining call: $e');
    }
  }
} 