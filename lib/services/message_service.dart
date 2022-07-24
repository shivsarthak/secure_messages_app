import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:secretic/models/conversation_request_model.dart';

import 'package:secretic/models/network_message_model.dart';
import 'package:secretic/services/authentication_service.dart';
import 'package:secretic/services/crypto_service.dart';
import 'package:secretic/services/storage_service.dart';

class MessageService {
  final FirebaseDatabase database = FirebaseDatabase.instance;

  Future handleMessage(NetworkMessage msg) async {
    StorageService storageService = GetIt.I.get<StorageService>();
    if (msg.type == ContentType.message) {
      var sharedKey = await storageService.getSecretKey(msg.conversationID);

      if (sharedKey != null) {
        var localMessage = await GetIt.I
            .get<CryptoService>()
            .decryptNetworkMessage(msg, sharedKey);

        storageService.storeMessage(localMessage);
      } else {
        throw UnimplementedError('No Shared Key found');
      }
    } else if (msg.type == ContentType.handshake) {
      switch (msg.handshakeState) {
        case HandshakeState.request:
          ConversationRequest request = ConversationRequest(
              timestamp: msg.timestamp,
              conversationID: msg.conversationID,
              recipientUID: msg.senderUID);
          await storageService.addToRequest(request);
          break;
        case HandshakeState.accepted:
          await storageService.toggleSecureStatus(msg.conversationID);
          break;
        case HandshakeState.none:
          // TODO: Handle this case.
          break;
      }
    }
  }

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
          NetworkMessage msg = NetworkMessage.fromJson(json);
          await handleMessage(msg);
        });
      }
    });
  }

  Future<String?> sendMessage(NetworkMessage message) async {
    String? messageID = database
        .ref()
        .child("users/${message.recieverUID}/new_messages")
        .push()
        .key;

    await database
        .ref()
        .child("users/${message.recieverUID}/new_messages/$messageID")
        .set(message.toJSON());

    return messageID;
  }

  Future messageStream() async {
    String uid = GetIt.I<AuthenticationService>().user.uid;
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
          NetworkMessage msg = NetworkMessage.fromJson(json);
          handleMessage(msg);
          return Transaction.success(null);
        });
      },
    );
  }
}
