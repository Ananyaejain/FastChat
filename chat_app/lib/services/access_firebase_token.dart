import 'dart:developer';

import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  //to generate token only once for an app run
  static Future<String?> get getToken async => _token ?? await _getAccessToken();

  // to get admin bearer token
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      final client = await clientViaServiceAccount(
        // To get Admin Json File: Go to Firebase > Project Settings > Service Accounts
        // > Click on 'Generate new private key' Btn & Json file will be downloaded

        // Paste Your Generated Json File Content
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "chatapp-14d95",
          "private_key_id": "c6bb5c2c81e0a913ca01d53b1ea9caf413c94135",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCTTpB/nW0mQvBr\nMqe9PMOR7+qXLlJNrUZUOBDjTaUpdTS6QCBSD7pjrga7rxKcXHWulR2oWMn+Cdh4\nyQKO03fHjV9KJ282f3jwJWbzKBsVA6zZJ8O5kbyOOSKjrOG3w6VNVo0Xnt9tCqo8\nk4hwpNpfPtJJtoucd2nkHagp5msg+fjck0kBof9gcv2YJ8XZrv3HydZOvQMGVJnX\nEVFCEX2xb9bZqQmo6sKpLU5QJE7orK12vuPYET8KKumSbloyE08N7G1TZRlI5w2T\nnq12NqKOBoji20rMIsdphiRIVGjC3tNyCp/hRB0703KOWM95XhfRw6kh00/OE7s2\n9/a75HKtAgMBAAECggEAIp7gnamXdVperGcZnsN4+GPhZ/oyTEDI6nLJ305InsOF\n6q83GWpKZXKJcRNuxZKCcw9nSsFhaeQQ/SRLBlvjhyIuDtzRScbwWsqDlWrr4Ia+\nWUQ7/zFmFiwN/NddLmYcQ96vZumHO9a5l2aaNtU74I5AeKQfUF0NZVhmBUD7FSLn\ndBstCL9cjXItQy1BUUgQz41KVi0AQEvuxwA6K38iuN4Bi8PDxX7Ezh4/yagwkUHJ\nNihWAqYIXxMcoKGpaRfz5gWfTlxNHmjHFX+/9RH/ahrEP2kQq6L0V6Q274G3mbN/\nbleucCLTK8WhjIyiJ5c+i3wPb0LPL64BbRODeRJ2oQKBgQDPdu8YVhCNRT9oQDCp\n8BoKuN7laNKfnGULeFymkTxkVmFBAZr5Hsvilecs/5HQa2R0xF+0p2V2X/FwgMGz\nIVIoc9NxJeQeZeYr+iSsJ/pS66zPGLltYaJFmrkOdJea6MBYjK5hcMLT0BEyl/68\nvsZZc3ak8htu4CFD9xoK4V1aoQKBgQC1xMhiBHfh+R4W9/cq1CGIGY6phbcXNVzD\ncbT5vfQL+NjrYnw9njn6apaexGNFk+z66DzeY+gpS1Fumjof9DLhVjlBpr5nviUv\nOpXKfpbZ2yoSxbXQdQIWo0il/jVbxElZp1OyRBdG19lHyIsAEIjO1MtXUxyNsMS0\nNBaSNtSIjQKBgGFqUkiWGP2Mt4JHKdKR6FiCiD8mYkgKErQ5FyArcDUZDl+M1m0F\nlezWQI+zjY9U7f2aO+pC8/SKhn8yJkHrcn2GLZGiniPb6yFZOqEPwI3xFdrEnEUN\nJDoUtbJg8tMNWUv6+uLMJN96gqjEEBwmZFKaUeqPuGvumBAm1janrcMhAoGAeWAH\ntnvpWXmyAABgibbRFUKLouNpGRRG9zNMd5/CAOSQZM2EzNiFOpRGM4pMB7/5dKnz\nS0VHV5u1qrdNrNyxxQqAfThM2JV92wWx1F+nd54DgDmJaMNZO6iY8E7JbpepqzYy\ni00whdvIeUiOmOJxmDs79PnIjUzGbNaDY+s9DFkCgYEAl3MTGkN+3TLpA8QV1Ypc\n1FJiQ5cBhjXPMDjhqfDV/WlACEynN7ocbBMYlJiMyazLartDotdKPw3CdExT/C4Q\nmCDw6YBmZByy1SAX/rBkuad+q5+u01R6Vjv8TQp12iZ2l+xEBlg56IvCWSl9QI0q\nO3Rgdfh2aDFLIvllF6gG3mE=\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-m33r8@chatapp-14d95.iam.gserviceaccount.com",
          "client_id": "104430565507686008040",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-m33r8%40chatapp-14d95.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;

      return _token;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}