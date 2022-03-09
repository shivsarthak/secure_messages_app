class Conversation {
  final String conversationID;
  final String recipientUID;
  final String? nickname;

  Conversation({
    required this.conversationID,
    required this.recipientUID,
    this.nickname,
  });

  factory Conversation.fromJSON(Map<String, Object?> map) {
    return Conversation(
      conversationID: map['conversationID'].toString(),
      nickname: map['nickname'].toString(),
      recipientUID: map['recipientUID'].toString(),
    );
  }

  Map<String, Object?> toJSON(int lastMessage) {
    Map<String, Object?> json = {
      'conversationID': conversationID,
      'nickname': nickname,
      'recipientUID': recipientUID,
      'last_message': lastMessage,
    };
    return json;
  }
}
