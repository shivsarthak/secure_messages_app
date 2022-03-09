import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:secure_messages/models/chat_mesage_model.dart';
import 'package:secure_messages/services/authentication_service.dart';
import 'package:secure_messages/services/storage_service.dart';

class MessageService {
  final FirebaseDatabase database = FirebaseDatabase.instance;

  Future<void> getAllNewMessages(String uid) async {
    Map<String, dynamic>? _messages;

    await database
        .ref()
        .child("users/$uid/new_messages")
        .runTransaction((messages) {
      if (messages == null) {
        return Transaction.abort();
      }
      _messages = Map<String, dynamic>.from(messages as Map);
      return Transaction.success(null);
    }).then((value) {
      if (_messages != null) {
        _messages!.forEach((key, value) async {
          Map<String, dynamic> json = Map.from(value as Map);
          ChatMessage msg = ChatMessage.fromJson(json);

          await StorageService().storeMessage(msg);
        });
      }
    });
  }

  Future<String?> sendMessage(ChatMessage message) async {
    String? messageID = database
        .ref()
        .child("users/${message.recieverUID}/new_messages")
        .push()
        .key;
    message.messageID = messageID;
    await database
        .ref()
        .child("users/${message.recieverUID}/new_messages/$messageID")
        .set(message.toJSON());
    await StorageService().storeMessage(message);
    return messageID;
  }

  messageStream() async {
    //TODO:Wait for uid to load
    String uid = GetIt.I<AuthenticationService>().user!.uid;
    return database.ref('users/$uid/new_messages').onChildAdded.listen(
      (event) async {
        database
            .ref()
            .child("users/$uid/new_messages")
            .runTransaction((messages) {
          if (messages == null) {
            return Transaction.abort();
          }
          Map<String, dynamic> json = Map.from(event.snapshot.value as Map);
          ChatMessage msg = ChatMessage.fromJson(json);
          StorageService().storeMessage(msg);
          return Transaction.success(null);
        });
      },
    );
  }
}
