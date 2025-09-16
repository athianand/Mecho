package com.mecho.mecho

import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d("FCM", "Message from: ${remoteMessage.from}")
        remoteMessage.notification?.let {
            Log.d("FCM", "Notification: ${it.title} - ${it.body}")
        }
    }

    override fun onNewToken(token: String) {
        Log.d("FCM", "New token: $token")
        // TODO: send this token to your server if needed
    }
}
