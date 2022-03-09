import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:secure_messages/enums/message_content_type.dart';
import 'package:secure_messages/enums/message_type.dart';
import 'package:secure_messages/services/authentication_service.dart';

class ChatMessage {
  String? messageID;
  final String messageContent;
  final String conversationID;
  final MessageContentType contentType;
  final String senderUID;
  final String recieverUID;
  final MessageType messageType;
  final DateTime timestamp;

  ChatMessage({
    this.messageID,
    required this.conversationID,
    required this.timestamp,
    required this.contentType,
    required this.senderUID,
    required this.recieverUID,
    required this.messageContent,
    required this.messageType,
  });

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> messageData = {
      'mid': messageID,
      'cid': conversationID,
      'timestamp': timestamp.toIso8601String(),
      'ctype': contentType.toString(),
      'suid': senderUID,
      'ruid': recieverUID,
      'content': messageContent,
    };
    return messageData;
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    String uid = GetIt.I<AuthenticationService>().user!.uid;
    return ChatMessage(
      messageID: json['mid'].toString(),
      conversationID: json['cid'].toString(),
      timestamp: DateTime.parse(json['timestamp'].toString()),
      contentType: MessageContentType.text,
      senderUID: json['suid'],
      recieverUID: json['ruid'],
      messageContent: json['content'],
      messageType:
          (uid == json['suid']) ? MessageType.sent : MessageType.received,
    );
  }

  factory ChatMessage.fromLocalJson(Map<String, Object?> data) {
    Map<String, dynamic> json = jsonDecode(data['messageData'].toString());
    String uid = GetIt.I<AuthenticationService>().user!.uid;
    return ChatMessage(
      messageID: json['mid'],
      conversationID: data['conversationID'].toString(),
      //TODO:Future
      contentType: MessageContentType.text,
      senderUID: json['suid'],
      recieverUID: json['ruid'],
      messageContent: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      messageType:
          (uid == json['suid']) ? MessageType.sent : MessageType.received,
    );
  }
  Map<String, dynamic> toLocalJSON() {
    Map<String, dynamic> messageData = {
      'mid': messageID,
      'timestamp': timestamp.toIso8601String(),
      'ctype': (contentType == MessageContentType.text) ? "TEXT" : "other",
      'suid': senderUID,
      'ruid': recieverUID,
      'content': messageContent,
    };
    Map<String, dynamic> json = {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'messageData': jsonEncode(messageData),
      'conversationID': conversationID,
    };

    return json;
  }
}
