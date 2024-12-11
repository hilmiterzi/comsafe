import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CallsService {
  static final CallsService _instance = CallsService._internal();
  late final DatabaseReference _database;
  static const String CHANNEL_NAME = 'comsafe_channel_1';

  factory CallsService() {
    return _instance;
  }

  CallsService._internal() {
    print('🔥 Setting Database URL');
    FirebaseDatabase.instance.databaseURL = 'https://generation-671ae-default-rtdb.europe-west1.firebasedatabase.app';
    _database = FirebaseDatabase.instance.ref();
    print('✅ Database initialized with URL: ${FirebaseDatabase.instance.databaseURL}');
  }

  Future<void> startGroupCall() async {
    print('📞 Starting group call');
    final deviceId = await _deviceId;
    
    try {
      // Clean up old calls first
      final snapshot = await _database.child('calls').get();
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        print('🧹 Cleaning up old calls');
        await _database.child('calls').child(CHANNEL_NAME).update({
          'status': 'ended'
        });
      }

      print('🆔 Creating new call with channel: $CHANNEL_NAME');
      await _database.child('calls').child(CHANNEL_NAME).set({
        'channelName': CHANNEL_NAME,
        'initiator': deviceId,
        'timestamp': ServerValue.timestamp,
        'status': 'active',
        'participants': {
          deviceId: 'initiator'
        }
      });
      print('✅ Call created successfully');
    } catch (e) {
      print('❌ Error: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> joinCall(String callId) async {
    print('👋 Joining call: $callId');
    final deviceId = await _deviceId;
    try {
      await _database.child('calls').child(CHANNEL_NAME).child('participants').update({
        deviceId: 'joined'
      });
      print('✅ Joined call successfully');
    } catch (e) {
      print('❌ Error joining call: $e');
    }
  }

  Stream<Map<String, dynamic>> listenForCalls() {
    print('👂 Starting to listen for calls');
    
    final controller = StreamController<Map<String, dynamic>>();
    
    _deviceId.then((deviceId) {
      print('📱 Using device ID: $deviceId');
      
      _database.child('calls').child(CHANNEL_NAME).onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data == null) {
          print('📭 No calls found');
          controller.add({});
          return;
        }
        
        print('📬 Received call data: $data');
        
        // Check if this is an active call and we're not already a participant
        if (data['status'] == 'active' && 
            data['participants'] is Map) {
          final participants = data['participants'] as Map;
          
          // If we're not the initiator and not already joined
          if (data['initiator'] != deviceId && !participants.containsKey(deviceId)) {
            controller.add({CHANNEL_NAME: Map<String, dynamic>.from(data)});
            print('📱 Active call available for joining');
          } else {
            controller.add({});
            print('📱 Already in call or initiated call');
          }
        } else {
          controller.add({});
          print('📭 No active calls for this device');
        }
      }, onError: (error) {
        print('❌ Error in database listener: $error');
        controller.add({});
      });
    });
    
    return controller.stream;
  }

  Future<void> declineCall(String callId) async {
    try {
      await _database.child('calls').child(CHANNEL_NAME).update({
        'status': 'declined'
      });
      print('✅ Call declined successfully');
    } catch (e) {
      print('❌ Error declining call: $e');
    }
  }

  Future<String> get _deviceId async {
    final token = await FirebaseMessaging.instance.getToken();
    print('📱 Device Token: $token');
    return token ?? 'unknown';
  }
} 