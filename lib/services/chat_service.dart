import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:secure_messages/models/chat_mesage_model.dart';
import 'package:secure_messages/models/conversation_model.dart';
import 'package:secure_messages/services/message_service.dart';
import 'package:secure_messages/services/storage_service.dart';

class ChatService extends ChangeNotifier {
  final Conversation conversation;
  List<ChatMessage> messages = [];
  late String uid;
  MessageService messageService = MessageService();
  late StorageService storageService;

  ChatService(this.conversation) {
    storageService = GetIt.I<StorageService>();

    storageService
        .getConversationMessages(conversation.conversationID)
        .then((value) {
      messages = value;
      notifyListeners();
    });
  }

  Future sendMessage(ChatMessage message) async {
    messages.insert(0, message);
    notifyListeners();
    await messageService.sendMessage(message);
    notifyListeners();
  }
}
