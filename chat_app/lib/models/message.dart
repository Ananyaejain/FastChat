import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  String? senderID;
  String? content;
  MessageType? messageType;
  Timestamp? sentAt;

  Message({
    required this.content,
    required this.messageType,
    required this.senderID,
    required this.sentAt,
  });
  
  Message.fromJson({required Map<String, dynamic> json}){
    content = json['content'];
    messageType = MessageType.values.byName(json['messageType']);
    senderID = json['senderID'];
    sentAt = json['sentAt'];
  }
  
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    data['senderID'] = senderID;
    data['sentAt'] = sentAt;
    data['messageType'] = messageType!.name;
    return data;
}
}
