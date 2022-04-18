import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:secretic/models/local_mesage_model.dart';
import 'package:secretic/models/conversation_model.dart';

import 'package:secretic/services/crypto_service.dart';
import 'package:sqflite/sqflite.dart';

class StorageService with ChangeNotifier {
  late Database db;
  List<Conversation> conversations = [];

  Future<StorageService> init() async {
    var database = await openDatabase(
      'secure_messages_a.db',
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE Conversations (
              id INTEGER PRIMARY KEY, 
              conversationID TEXT type NOT NULL,
              recipientUID TEXT type NOT NULL,
              nickname TEXT,
              last_message TEXT,
              display_content TEXT,
              pub_key TEXT,
              secret_key TEXT
              )
            ''');

        await db.execute('''CREATE TABLE Chat_Messages (
              id INTEGER PRIMARY KEY, 
              conversationID TEXT type NOT NULL,
              timestamp TEXT type NOT NULL,
              messageData TEXT
              )
            ''');
      },
    );
    db = database;

    return this;
  }

  Future<List<Conversation>> getConversations() async {
    var result = await db.rawQuery(
      '''SELECT conversationID,
        recipientUID,
        nickname , 
        last_message,
        display_content,
        secret_key,
        pub_key FROM Conversations 
        ORDER BY last_message DESC''',
    );
    conversations = result.map((e) => Conversation.fromJSON(e)).toList();
    notifyListeners();
    return conversations;
  }

  Future createConversation(Conversation conversation) async {
    await db.insert('Conversations', await conversation.toJSON(DateTime.now()));
    getConversations();
    notifyListeners();
  }

  Future storeMessage(LocalMessage message, String senderPubKey) async {
    var res = await db.rawQuery(
        "SELECT * from Conversations where conversationID = '${message.conversationID}'");
    if (res.isEmpty) {
      var pubKey = SimplePublicKey(base64.decode(senderPubKey),
          type: KeyPairType.x25519);
      CryptoService crypto = GetIt.I.get<CryptoService>();
      var secretKey = await crypto.sharedSecretKey(pubKey);

      Conversation conversation = Conversation(
          secretKey: secretKey,
          conversationID: message.conversationID,
          recipientUID: message.senderUID,
          publicKey: pubKey,
          displayContent: message.messageContent,
          lastMessage: message.timestamp);
      createConversation(conversation);
    }
    await db.transaction((txn) async {
      await txn.insert(
        "Chat_Messages",
        message.toLocalJSON(),
      );
      await txn.update(
          'Conversations',
          {
            'display_content': message.messageContent,
            'last_message': message.timestamp.toIso8601String()
          },
          where: 'conversationID = "${message.conversationID}"');
    });

    getConversations();
    return;
  }

  Future<List<LocalMessage>> getConversationMessages(
    String conversationID, {
    int limit = 25,
    int offset = 0,
  }) async {
    var res = await db.rawQuery('''SELECT * FROM Chat_Messages 
        where conversationID = '$conversationID'
        ORDER BY timestamp DESC 
        LIMIT $limit OFFSET $offset''');
    return res.map((e) => LocalMessage.fromLocalJson(e)).toList();
  }

  deleteData() async {
    await db.rawDelete('Delete from Conversations');
    await db.rawDelete('Delete from Chat_Messages');
    await getConversations();
  }

  deleteConversation(Conversation conversation) async {
    await db.rawDelete(
        "Delete from Chat_Messages where conversationID = '${conversation.conversationID}'");
  }
}
