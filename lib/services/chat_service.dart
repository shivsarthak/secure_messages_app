import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import 'package:secretic/models/local_mesage_model.dart';
import 'package:secretic/models/conversation_model.dart';
import 'package:secretic/models/network_message_model.dart';
import 'package:secretic/services/message_service.dart';
import 'package:secretic/services/storage_service.dart';

class ChatService extends ChangeNotifier {
  bool _disposed = false;
  final Conversation conversation;
  List<LocalMessage> messages = [];
  late String uid;
  MessageService messageService = MessageService();
  StorageService storageService = GetIt.I.get<StorageService>();

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

  Future sendMessageToConversation(LocalMessage message) async {
    messages.insert(0, message);
    notifyListeners();
    await _sendMessage(message);
    notifyListeners();
  }

  Future _sendMessage(LocalMessage message) async {
    var encryptedNetworkMessage =
        await NetworkMessage.fromLocalmessage(message, conversation.secretKey);
    await GetIt.I.get<StorageService>().storeMessage(message, '');
    messageService.sendMessage(encryptedNetworkMessage);
  }
}
