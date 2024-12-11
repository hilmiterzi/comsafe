class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CallsService _callsService = CallsService();
  StreamSubscription? _callSubscription;

  @override
  void initState() {
    super.initState();
    _listenForCalls();
  }

  void _listenForCalls() {
    _callSubscription = _callsService.listenForCalls().listen((callData) {
      if (callData.isNotEmpty && callData['status'] == 'active') {
        // Show incoming call screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomingCallScreen(
              callerName: 'Group Call',
              onAccept: () => _joinCall(callData['callId']),
              onDecline: () => Navigator.pop(context),
            ),
          ),
        );
      }
    });
  }

  Future<void> _startCall() async {
    await _callsService.startGroupCall();
  }

  Future<void> _joinCall(String callId) async {
    await _callsService.joinCall(callId);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          channelName: callId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Call App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _startCall,
              icon: Icon(Icons.call),
              label: Text('Start Group Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 