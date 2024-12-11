import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/settings.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final bool isInitiator;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.isInitiator,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _isInitialized = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    print('🎥 Initializing VideoCallScreen with channel: ${widget.channelName}');
    initAgora();
  }

  Future<void> initAgora() async {
    try {
      print('📱 Requesting permissions');
      await [Permission.microphone, Permission.camera].request();

      print('🚀 Creating RtcEngine');
      _engine = createAgoraRtcEngine();
      
      print('🔧 Initializing RtcEngine');
      await _engine.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      print('📹 Enabling video');
      await _engine.enableVideo();
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      
      print('🎥 Starting preview');
      await _engine.startPreview();

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            print('🎉 Local user ${connection.localUid} joined channel ${connection.channelId}');
            setState(() {
              _localUserJoined = true;
            });
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            print('👥 Remote user $remoteUid joined channel ${connection.channelId}');
            setState(() {
              _remoteUid = remoteUid;
            });
          },
          onUserOffline: (connection, remoteUid, reason) {
            print('👋 Remote user $remoteUid left channel ${connection.channelId}');
            setState(() {
              _remoteUid = null;
            });
          },
          onError: (err, msg) {
            print('❌ Error $err: $msg');
          },
          onConnectionStateChanged: (connection, state, reason) {
            print('🔌 Connection state changed: $state, reason: $reason');
          },
        ),
      );

      print('🔑 Joining channel: ${widget.channelName}');
      await _engine.joinChannel(
        token: token, // Make sure this is your valid token
        channelId: widget.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );

      setState(() {
        _isInitialized = true;
      });
      print('✅ Agora initialization complete');
    } catch (e, stackTrace) {
      print('❌ Error initializing Agora: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    print('🧹 Disposing VideoCallScreen');
    _disposeAgora();
    super.dispose();
  }

  Future<void> _disposeAgora() async {
    try {
      await _engine.leaveChannel();
      await _engine.release();
      print('👋 Left channel and released engine');
    } catch (e) {
      print('❌ Error disposing Agora: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video
            Center(
              child: _remoteVideo(),
            ),
            // Local video
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 120,
                height: 160,
                margin: const EdgeInsets.all(8),
                child: _localVideo(),
              ),
            ),
            // Controls
            Align(
              alignment: Alignment.bottomCenter,
              child: _toolbar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _localVideo() {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_localUserJoined) {
      return const Center(child: Text('Joining...'));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      ),
    );
  }

  Widget _remoteVideo() {
    if (!_isInitialized) {
      return const Center(child: Text('Initializing...'));
    }
    if (_remoteUid == null) {
      return const Center(child: Text('Waiting for others to join...'));
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: RtcConnection(channelId: widget.channelName),
      ),
    );
  }

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () async {
              await _disposeAgora();
              if (mounted) Navigator.pop(context);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
          ),
        ],
      ),
    );
  }
} 