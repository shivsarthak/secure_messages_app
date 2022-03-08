class Conversation {
  final String conversationID;
  final String reciepientUID;
  final String? nickname;

  Conversation({
    required this.conversationID,
    required this.reciepientUID,
    this.nickname,
  });

  factory Conversation.fromJSON(Map<String, Object?> map) {
    return Conversation(
      conversationID: map['conversationID'].toString(),
      nickname: map['nickname'].toString(),
      reciepientUID: map['reciepientUID'].toString(),
    );
  }

  Map<String, Object?> toJSON(int lastMessage) {
    Map<String, Object?> json = {
      'conversationID': conversationID,
      'nickname': nickname,
      'reciepientUID': reciepientUID,
      'last_message': lastMessage,
    };
    return json;
  }
}
