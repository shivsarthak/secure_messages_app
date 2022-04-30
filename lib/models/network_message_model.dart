import 'package:cryptography/cryptography.dart';
import 'package:get_it/get_it.dart';

import 'package:secretic/models/local_mesage_model.dart';

import 'package:secretic/services/crypto_service.dart';

enum ContentType { message, handshake }
enum HandshakeState { request, accepted, none }

class NetworkMessage {
  final String encryptedMessage;
  final String conversationID;
  final String senderUID;
  final String recieverUID;
  final DateTime timestamp;
  final ContentType type;
  final HandshakeState handshakeState;

  NetworkMessage({
    required this.handshakeState,
    required this.type,
    required this.conversationID,
    required this.timestamp,
    required this.senderUID,
    required this.recieverUID,
    required this.encryptedMessage,
  });

  factory NetworkMessage.fromJson(Map<String, dynamic> json) {
    return NetworkMessage(
      type: ContentType.values.byName(json['type']),
      handshakeState: HandshakeState.values.byName(json['handshake_state']),
      conversationID: json['cid'].toString(),
      timestamp: DateTime.parse(json['timestamp'].toString()),
      senderUID: json['suid'],
      recieverUID: json['ruid'],
      encryptedMessage: json['encrypted_message'],
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> messageData = {
      'handshake_state': handshakeState.name,
      'type': type.name,
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
