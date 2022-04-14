import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:get_it/get_it.dart';

import 'package:secure_messages/enums/message_type.dart';
import 'package:secure_messages/models/local_mesage_model.dart';

import 'package:secure_messages/services/authentication_service.dart';
import 'package:secure_messages/services/crypto_service.dart';

class NetworkMessage {
  final String senderPubKeyString;
  final String encryptedMessage;
  final String conversationID;
  final String senderUID;
  final String recieverUID;
  final DateTime timestamp;

  NetworkMessage({
    required this.senderPubKeyString,
    required this.conversationID,
    required this.timestamp,
    required this.senderUID,
    required this.recieverUID,
    required this.encryptedMessage,
  });

  factory NetworkMessage.fromJson(Map<String, dynamic> json) {
    return NetworkMessage(
      senderPubKeyString: json['sender_pub_key'],
      conversationID: json['cid'].toString(),
      timestamp: DateTime.parse(json['timestamp'].toString()),
      senderUID: json['suid'],
      recieverUID: json['ruid'],
      encryptedMessage: json['encrypted_message'],
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> messageData = {
      'sender_pub_key': senderPubKeyString,
      'cid': conversationID,
      'timestamp': timestamp.toIso8601String(),
      'suid': senderUID,
      'ruid': recieverUID,
      'encrypted_message': encryptedMessage,
    };
    return messageData;
  }

  static Future<NetworkMessage> fromChatmessage(
      LocalMessage message, SecretKey secretKey) async {
    CryptoService cryptoService = CryptoService();

    var cipherText = await cryptoService.encryption.encrypt(
      utf8.encode(message.messageContent),
      secretKey: secretKey,
    );

    return NetworkMessage(
      senderPubKeyString: base64.encode(cryptoService.publicKey.bytes),
      conversationID: message.conversationID,
      timestamp: message.timestamp,
      senderUID: message.senderUID,
      recieverUID: message.recieverUID,
      encryptedMessage: base64.encode(cipherText.concatenation()),
    );
  }
}
