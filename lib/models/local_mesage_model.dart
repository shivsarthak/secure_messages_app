import 'dart:convert';

import 'package:get_it/get_it.dart';

import 'package:secretic/enums/message_content_type.dart';
import 'package:secretic/enums/message_type.dart';
import 'package:secretic/services/authentication_service.dart';

class LocalMessage {
  final String messageContent;
  final String conversationID;
  final String senderUID;
  final String recieverUID;
  final MessageType messageType;
  final DateTime timestamp;

  LocalMessage({
    required this.conversationID,
    required this.timestamp,
    required this.senderUID,
    required this.recieverUID,
    required this.messageContent,
    required this.messageType,
  });

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> messageData = {
      'cid': conversationID,
      'timestamp': timestamp.toIso8601String(),
      'suid': senderUID,
      'ruid': recieverUID,
      'content': messageContent,
    };
    return messageData;
  }

  factory LocalMessage.fromJson(Map<String, dynamic> json) {
    String uid = GetIt.I<AuthenticationService>().user!.uid;
    return LocalMessage(
      conversationID: json['cid'].toString(),
      timestamp: DateTime.parse(json['timestamp'].toString()),
      senderUID: json['suid'],
      recieverUID: json['ruid'],
      messageContent: json['content'],
      messageType:
          (uid == json['suid']) ? MessageType.sent : MessageType.received,
    );
  }

  factory LocalMessage.fromLocalJson(Map<String, Object?> data) {
    Map<String, dynamic> json = jsonDecode(data['messageData'].toString());
    String uid = GetIt.I<AuthenticationService>().user!.uid;
    return LocalMessage(
      conversationID: data['conversationID'].toString(),
      //TODO:Future

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
      'timestamp': timestamp.toIso8601String(),
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
