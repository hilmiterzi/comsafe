const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendGroupCall = functions.https.onRequest(async (req, res) => {
  try {
    const { callId } = req.body;
    
    const message = {
      topic: 'all_users',
      notification: {
        title: 'Incoming Group Call',
        body: 'Someone is calling you',
      },
      data: {
        type: 'group_call',
        callId: callId,
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'calls_channel',
          priority: 'max',
        },
      },
    };

    await admin.messaging().send(message);
    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({ error: error.message });
  }
}); 