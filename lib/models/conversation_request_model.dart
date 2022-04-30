import 'package:cryptography/cryptography.dart';
import 'package:secretic/models/conversation_model.dart';

class ConversationRequest {
  final String conversationID;
  final String recipientUID;
  final String? nickname;
  final DateTime timestamp;

  ConversationRequest({
    required this.timestamp,
    required this.conversationID,
    required this.recipientUID,
    this.nickname,
  });

  factory ConversationRequest.fromJSON(Map<String, Object?> map) {
    return ConversationRequest(
      timestamp: DateTime.parse(map['timestamp'].toString()),
      conversationID: map['conversationID'].toString(),
      nickname: map['nickname'].toString(),
      recipientUID: map['recipientUID'].toString(),
    );
  }

  Future<Map<String, Object?>> toJSON(DateTime lastMessage) async {
    Map<String, Object?> json = {
      'conversationID': conversationID,
      'nickname': nickname,
      'recipientUID': recipientUID,
      'timestamp': lastMessage.toIso8601String(),
    };
    return json;
  }

  Conversation toConversation(SecretKey key) {
    return Conversation(
        secure: true,
        lastMessage: DateTime.now(),
        nickname: nickname,
        displayContent: '',
        secretKey: key,
        conversationID: conversationID,
        recipientUID: recipientUID);
  }
}
