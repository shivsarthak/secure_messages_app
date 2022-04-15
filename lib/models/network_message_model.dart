import 'package:cryptography/cryptography.dart';
import 'package:get_it/get_it.dart';

import 'package:secretic/models/local_mesage_model.dart';

import 'package:secretic/services/crypto_service.dart';

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

  static Future<NetworkMessage> fromLocalmessage(
      LocalMessage message, SecretKey secretKey) async {
    CryptoService cryptoService = GetIt.I.get<CryptoService>();

    return await cryptoService.encryptLocalMessage(message, secretKey);
  }
}
