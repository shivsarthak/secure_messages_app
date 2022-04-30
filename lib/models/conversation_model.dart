import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class Conversation {
  final String conversationID;
  final String recipientUID;
  final String? nickname;
  final bool secure;
  final DateTime lastMessage;
  final String displayContent;
  final SecretKey secretKey;

  Conversation({
    required this.secure,
    required this.lastMessage,
    required this.displayContent,
    required this.secretKey,
    required this.conversationID,
    required this.recipientUID,
    this.nickname,
  });

  factory Conversation.fromJSON(Map<String, Object?> map) {
    final key = SecretKey(base64Decode(map['secret_key'].toString()));

    return Conversation(
      displayContent: map['display_content'].toString(),
      lastMessage: DateTime.parse(map['last_message'].toString()),
      secure: map['secure'] == 1,
      secretKey: key,
      conversationID: map['conversationID'].toString(),
      nickname: map['nickname'].toString(),
      recipientUID: map['recipientUID'].toString(),
    );
  }

  Future<Map<String, Object?>> toJSON(DateTime lastMessage) async {
    Map<String, Object?> json = {
      'secure': secure ? 1 : 0,
      'conversationID': conversationID,
      'nickname': nickname,
      'recipientUID': recipientUID,
      'last_message': lastMessage.toIso8601String(),
      'secret_key': base64.encode(await secretKey.extractBytes())
    };
    return json;
  }
}
