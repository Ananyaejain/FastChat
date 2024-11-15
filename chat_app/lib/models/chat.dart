import 'package:chat_app/models/message.dart';

class Chat {
  String? id;
  List<String>? participants;
  List<Message>? messages;

  Chat({
    required this.id,
    required this.messages,
    required this.participants,
  });

  Chat.fromJson({required Map<String, dynamic> json}) {
    id = json['id'];
    messages = List<Message>.from(
        json['messages'].map((m) => Message.fromJson(json: m))
    );
    participants = List<String>.from(json['participants']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['participants'] = participants;
    data['messages'] = messages?.map((m) => m.toJson());
    return data;
  }
}
