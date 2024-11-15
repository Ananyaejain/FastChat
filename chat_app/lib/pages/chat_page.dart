import 'dart:io';

import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/pushNotification_service.dart';
import 'package:chat_app/services/stroage_service.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({
    super.key,
    required this.chatUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late PushNotificationService _pushNotificationService;
  ChatUser? currUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _databaseService = getIt.get<DatabaseService>();
    _storageService = getIt.get<StorageService>();
    _mediaService = getIt.get<MediaService>();
    _pushNotificationService = getIt.get<PushNotificationService>();
    currUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
    );
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name!,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUser.name!),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _databaseService.getChatData(currUser!.id, otherUser!.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        Chat? chat = snapshot.data?.data();
        List<ChatMessage> messages = [];
        if (chat != null && chat.messages != null) {
          messages = _getChatMessagesList(chat.messages!);
        }
        return DashChat(
          messageOptions: const MessageOptions(
            showOtherUsersAvatar: true,
            showTime: true,
          ),
          inputOptions: InputOptions(
            alwaysShowSend: true,
            leading: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: Theme.of(context).primaryColor,
                  ))
            ],
            trailing: [
              mediaMessageButton(),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.keyboard_voice,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          currentUser: currUser!,
          onSend: _sendMessage,
          messages: messages,
        );
      },
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      Message message = Message(
        content: chatMessage.medias!.first.url,
        messageType: MessageType.Image,
        senderID: chatMessage.user.id,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessage(
        currUser!.id,
        otherUser!.id,
        message,
      );
      await _pushNotificationService.sendPushNotification(
        widget.chatUser,
        "Sent an Image",
        currUser!.firstName,
      );
    } else {
      Message message = Message(
        content: chatMessage.text,
        messageType: MessageType.Text,
        senderID: currUser!.id,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessage(
        currUser!.id,
        otherUser!.id,
        message,
      );
      await _pushNotificationService.sendPushNotification(
        widget.chatUser,
        chatMessage.text,
        currUser!.firstName,
      );
    }
  }

  List<ChatMessage> _getChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
            user: m.senderID == currUser!.id ? currUser! : otherUser!,
            createdAt: m.sentAt!.toDate(),
            medias: [
              ChatMedia(
                url: m.content!,
                fileName: '',
                type: MediaType.image,
              ),
            ]);
      } else {
        return ChatMessage(
          text: m.content!,
          user: m.senderID == currUser!.id ? currUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String chatID = generateChatID(
            uid1: currUser!.id,
            uid2: otherUser!.id,
          );
          String? downloadURL = await _storageService.uploadImageToChat(
            file: file,
            chatID: chatID,
          );
          if (downloadURL != null) {
            ChatMessage chatMessage = ChatMessage(
              user: currUser!,
              createdAt: DateTime.now(),
              medias: [
                ChatMedia(
                  url: downloadURL,
                  fileName: "",
                  type: MediaType.image,
                ),
              ],
            );
            await _sendMessage(chatMessage);
          }
        }
      },
      icon: Icon(Icons.image),
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
