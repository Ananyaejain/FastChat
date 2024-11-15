import 'dart:convert';
import 'dart:io';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/access_firebase_token.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'dart:developer';

import 'package:http/http.dart';

class PushNotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final GetIt getIt = GetIt.instance;
  late AuthService _authService;

  PushNotificationService() {
    _authService = getIt.get<AuthService>();
  }

  Future<String> getFirebaseMessagingToken() async {
    await messaging.requestPermission();

    final pushToken = await messaging.getToken();
    if (pushToken != null) {
      return pushToken;
      log(pushToken);
    }
    return 'error';
  }

  Future<void> sendPushNotification(UserProfile user, String msg,
      String? senderName) async {
    try {
      final body = {
        "message": {
          "token": user.pushToken,
          "notification": {
            "title": senderName, //our name should be send
            "body": msg,
          },
        }
      };

      // Firebase Project > Project Settings > General Tab > Project ID
      const projectID = 'chatapp-14d95';

      // get firebase admin token
      final bearerToken = await NotificationAccessToken.getToken;

      log('bearerToken: $bearerToken');

      // handle null token
      if (bearerToken == null) return;

      var res = await post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
        },
        body: jsonEncode(body),
      );

      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }
}