import 'package:flutter/cupertino.dart';
import 'package:secure_messages/models/chat_mesage_model.dart';
import 'package:secure_messages/models/conversation_model.dart';
import 'package:sqflite/sqflite.dart';

class StorageService with ChangeNotifier {
  static final StorageService _instance = StorageService._internal();
  late Database db;
  List<Conversation> conversations = [];
  factory StorageService() {
    return _instance;
  }

  StorageService._internal() {
    _init().then((value) async {
      db = value;
      conversations = await getConversations();
      notifyListeners();
    });
  }
  Future<Database> _init() async {
    var db = await openDatabase(
      'secure_messages.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE Conversations (
              id INTEGER PRIMARY KEY, 
              conversationID TEXT type NOT NULL,
              reciepientUID TEXT type NOT NULL,
              nickname TEXT,
              last_message INTEGER 
              )
            ''');
      },
    );

    return db;
  }

  Future<List<Conversation>> getConversations() async {
    var result = await db.rawQuery(
      'SELECT DISTINCT reciepientUID, conversationID, nickname , last_message FROM Conversations ORDER BY last_message DESC',
    );
    return result.map((e) => Conversation.fromJSON(e)).toList();
  }

  Future createConversation(Conversation conversation) async {
    await db.transaction((txn) async {
      await txn.insert(
        "Conversations",
        conversation.toJSON(DateTime.now().millisecondsSinceEpoch),
      );
      await txn.execute('''CREATE TABLE ${conversation.conversationID} (
              id INTEGER PRIMARY KEY, 
              messageData TEXT type NOT NULL,
              timestamp INTEGER 
              )
            ''');
    });

    notifyListeners();
  }

  Future<List<ChatMessage>> getConversationMessages(
    String conversationID, {
    int limit = 25,
    int offset = 0,
  }) async {
    var res = await db.rawQuery(
        'SELECT * FROM $conversationID ORDER BY timestamp DESC LIMIT $limit OFFSET $offset');
    return res.map((e) => ChatMessage.fromLocalJson(e)).toList();
  }

  Future addMessageToConversation(
    ChatMessage message,
  ) async {
    var res = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name = '${message.conversationID}'",
    );
    if (res.isEmpty) {
      Conversation conversation = Conversation(
        conversationID: message.conversationID,
        reciepientUID: message.senderUID,
      );
      await createConversation(conversation);
    } else {
      await db.insert(
        message.conversationID,
        message.toLocalJSON(),
      );
    }
    notifyListeners();
    return;
  }

  deleteData() async {
    await db.rawDelete('Delete from Conversations');
  }

  deleteConversation(Conversation conversation) async {
    await db.rawDelete('Delete from ${conversation.conversationID}');
  }
}
