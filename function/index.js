const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notifyMechanicsOnRequest = functions.firestore
  .document("Requests/{requestId}")
  .onCreate(async (snap) => {
    const request = snap.data();

    // Get all mechanics with FCM token
    const mechanicsSnapshot = await admin.firestore()
      .collection("mechanicdetails")
      .get();

    const tokens = [];
    mechanicsSnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.fcmToken) {
        tokens.push(data.fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log("No mechanic tokens available");
      return null;
    }

    const message = {
      notification: {
        title: "New Service Request 🚗",
        body: `Request from ${request.userName} at ${request.location}`,
      },
      tokens: tokens,
    };

    try {
      const response = await admin.messaging().sendMulticast(message);
      console.log(`Notifications sent: ${response.successCount}`);
      return response;
    } catch (error) {
      console.error("Error sending notifications:", error);
      return null;
    }
  });
