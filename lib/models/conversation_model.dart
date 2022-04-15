import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';

class Conversation {
  final String conversationID;
  final String recipientUID;
  final String? nickname;
  final SimplePublicKey publicKey;
  final SecretKey secretKey;

  Conversation({
    required this.secretKey,
    required this.conversationID,
    required this.recipientUID,
    required this.publicKey,
    this.nickname,
  });

  factory Conversation.fromJSON(Map<String, Object?> map) {
    final key = SecretKey(base64Decode(map['secret_key'].toString()));
    print(map['secret_key'].toString());
    return Conversation(
      secretKey: key,
      conversationID: map['conversationID'].toString(),
      nickname: map['nickname'].toString(),
      publicKey: SimplePublicKey(base64Decode(map['pubKey'].toString()),
          type: KeyPairType.x25519),
      recipientUID: map['recipientUID'].toString(),
    );
  }

  Future<Map<String, Object?>> toJSON(int lastMessage) async {
    Map<String, Object?> json = {
      'conversationID': conversationID,
      'nickname': nickname,
      'recipientUID': recipientUID,
      'last_message': lastMessage,
      'pub_key': base64.encode(publicKey.bytes),
      'secret_key': base64.encode(await secretKey.extractBytes())
    };
    return json;
  }
}
