import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import 'package:secretic/models/conversation_request_model.dart';
import 'package:secretic/models/local_mesage_model.dart';
import 'package:secretic/models/conversation_model.dart';
import 'package:secretic/models/network_message_model.dart';
import 'package:secretic/services/authentication_service.dart';
import 'package:secretic/services/message_service.dart';

import 'package:sqflite/sqflite.dart';

class StorageService with ChangeNotifier {
  late Database db;
  List<Conversation> conversations = [];
  List<ConversationRequest> requests = [];

  Future createDatabase(Database db, int version) async {
    await db.execute('''CREATE TABLE Conversations (
              id INTEGER PRIMARY KEY, 
              conversationID TEXT type NOT NULL,
              recipientUID TEXT type NOT NULL,
              nickname TEXT,
              last_message TEXT,
              display_content TEXT,
              secure INTEGER not NULL,
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

    await db.execute('''CREATE TABLE Requests (
              id INTEGER PRIMARY KEY, 
              conversationID TEXT type NOT NULL,
              recipientUID TEXT type NOT NULL,
              nickname TEXT,
              timestamp TEXT
              )
            ''');
  }

  Future<StorageService> init() async {
    var database = await openDatabase('secure_messages.db',
        version: 5, onCreate: createDatabase,
        onUpgrade: (db, oldVersion, newVersion) async {
      //TODO: Change logic for backwords compatibility
      await deleteDatabase(db.path);
      await createDatabase(db, newVersion);
    });
    db = database;

    return this;
  }

  Future<SecretKey?> getSecretKey(String conversationID) async {
    var result = await db.rawQuery(
      '''SELECT secret_key
         FROM Conversations 
         WHERE conversationID = "$conversationID"
       ''',
    );
    if (result.isNotEmpty) {
      return SecretKey(base64Decode(result[0]['secret_key'].toString()));
    }
    return null;
  }

  Future getConversations() async {
    var result = await db.rawQuery(
      '''SELECT conversationID,
        recipientUID,
        nickname, 
        secure,
        last_message,
        display_content,
        secret_key
         FROM Conversations 
        ORDER BY last_message DESC
        ''',
    );

    var requestResults = await db.query('Requests', orderBy: "timestamp DESC");
    conversations = result.map((e) => Conversation.fromJSON(e)).toList();
    requests =
        requestResults.map((e) => ConversationRequest.fromJSON(e)).toList();
    notifyListeners();
  }

  Future<bool> conversationExists(String id) async {
    var result =
        await db.query('Conversations', where: 'conversationID = "$id"');
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future toggleSecureStatus(String conversationId) async {
    await db.update('Conversations', {'secure': true},
        where: 'conversationID = "$conversationId"');

    getConversations();
  }

  Future createConversation(Conversation conversation) async {
    var exists = await conversationExists(conversation.conversationID);
    if (!exists) {
      await db.insert(
          'Conversations', await conversation.toJSON(DateTime.now()));
      var networkMessage = NetworkMessage(
        conversationID: conversation.conversationID,
        encryptedMessage: '',
        handshakeState: HandshakeState.request,
        recieverUID: conversation.recipientUID,
        senderUID: GetIt.I.get<AuthenticationService>().user.uid,
        timestamp: DateTime.now(),
        type: ContentType.handshake,
      );
      await MessageService().sendMessage(networkMessage);
      await getConversations();
      notifyListeners();
    }
  }

  Future addToRequest(ConversationRequest request) async {
    await db.insert('Requests', await request.toJSON(DateTime.now()));
    await getConversations();
    notifyListeners();
  }

  Future approveRequest(
      ConversationRequest request, SecretKey key, String nickname) async {
    await db.transaction((txn) async {
      await txn.delete('Requests',
          where: 'conversationID = "${request.conversationID}"');
      var conversation = request.toConversation(key);
      conversation.setNickname(nickname);
      var data = await conversation.toJSON(DateTime.now());

      await txn.insert('Conversations', data);
      return txn;
    });
    var networkMessage = NetworkMessage(
      conversationID: request.conversationID,
      encryptedMessage: '',
      handshakeState: HandshakeState.accepted,
      recieverUID: request.recipientUID,
      senderUID: GetIt.I.get<AuthenticationService>().user.uid,
      timestamp: DateTime.now(),
      type: ContentType.handshake,
    );
    await MessageService().sendMessage(networkMessage);
    await getConversations();
  }

  Future storeMessage(LocalMessage message) async {
    var res = await db.rawQuery(
        "SELECT * from Conversations where conversationID = '${message.conversationID}'");
    if (res.isEmpty) {
      ConversationRequest request = ConversationRequest(
          conversationID: message.conversationID,
          recipientUID: message.senderUID,
          timestamp: message.timestamp);
      addToRequest(request);
    } else {
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

      await getConversations();
      return;
    }
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
    await db.rawDelete('Delete from Requests');
    await getConversations();
  }

  deleteConversation(String conversationID) async {
    await db.rawDelete(
        "Delete from Chat_Messages where conversationID = '$conversationID'");
  }
}
