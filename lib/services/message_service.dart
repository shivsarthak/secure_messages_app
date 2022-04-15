import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:secretic/models/conversation_model.dart';
import 'package:secretic/models/local_mesage_model.dart';
import 'package:secretic/models/network_message_model.dart';
import 'package:secretic/services/authentication_service.dart';
import 'package:secretic/services/crypto_service.dart';
import 'package:secretic/services/storage_service.dart';

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
          NetworkMessage msg = NetworkMessage.fromJson(json);
          var localMessage = await CryptoService().decryptNetworkMessage(msg);

          await StorageService()
              .storeMessage(localMessage, msg.senderPubKeyString);
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

  messageStream() async {
    //TODO:Wait for uid to load
    String uid = GetIt.I<AuthenticationService>().user!.uid;
    return database.ref('users/$uid/new_messages').onChildAdded.listen(
      (event) async {
        CryptoService crypto = CryptoService();
        database
            .ref()
            .child("users/$uid/new_messages")
            .runTransaction((messages) {
          if (messages == null) {
            return Transaction.abort();
          }
          Map<String, dynamic> json = Map.from(event.snapshot.value as Map);
          NetworkMessage msg = NetworkMessage.fromJson(json);
          crypto.decryptNetworkMessage(msg).then((val) {
            StorageService().storeMessage(val, msg.senderPubKeyString);
          });

          return Transaction.success(null);
        });
      },
    );
  }
}
