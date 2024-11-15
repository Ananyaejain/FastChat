import 'package:chat_app/consts.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/pushNotification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late PushNotificationService _pushNotificationService;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _alertService = getIt.get<AlertService>();
    _databaseService = getIt.get<DatabaseService>();
    _navigationService = getIt.get<NavigationService>();
    _pushNotificationService = getIt.get<PushNotificationService>();
    updatePushToken();
  }

  void updatePushToken() async {
    await _databaseService.updatePushToken(
        await _pushNotificationService.getFirebaseMessagingToken());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        actions: [
          IconButton(
            onPressed: () async {
              bool result = await _authService.logout();
              if (result) {
                _alertService.showToast(
                  text: 'Successfully logged out!',
                  icon: Icons.check,
                );
                _navigationService.pushReplacementNamed(LoginRoute);
              }
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 15,
        ),
        child: _chatsList(),
      ),
    );
  }

  Widget _chatsList() {
    return StreamBuilder(
        stream: _databaseService.getUserProfiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load data'),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final users = snapshot.data!.docs;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index].data();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: ChatTile(
                    userProfile: user,
                    onTap: () async {
                      final chatExists = await _databaseService.doesChatExist(
                        _authService.user!.uid,
                        user.uid!,
                      );
                      if (!chatExists) {
                        await _databaseService.createNewChat(
                          _authService.user!.uid,
                          user.uid!,
                        );
                      }
                      _navigationService.push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ChatPage(chatUser: user);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
