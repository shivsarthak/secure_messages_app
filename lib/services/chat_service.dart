import 'package:flutter/cupertino.dart';

import 'package:secure_messages/models/chat_mesage_model.dart';
import 'package:secure_messages/models/conversation_model.dart';
import 'package:secure_messages/services/message_service.dart';
import 'package:secure_messages/services/storage_service.dart';

class ChatService extends ChangeNotifier {
  bool _disposed = false;
  final Conversation conversation;
  List<ChatMessage> messages = [];
  late String uid;
  MessageService messageService = MessageService();
  StorageService storageService = StorageService();

  ChatService(this.conversation) {
    storageService
        .getConversationMessages(conversation.conversationID)
        .then((value) {
      messages = value;
      notifyListeners();
    });
    storageService.addListener(() {
      storageService
          .getConversationMessages(conversation.conversationID)
          .then((value) {
        messages = value;
        notifyListeners();
      });
    });
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    storageService.removeListener(() {});
    super.dispose();
  }

  Future sendMessage(ChatMessage message) async {
    messages.insert(0, message);
    notifyListeners();
    await messageService.sendMessage(message);
    notifyListeners();
  }
}
