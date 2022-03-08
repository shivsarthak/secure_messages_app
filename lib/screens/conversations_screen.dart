import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'package:secure_messages/models/conversation_model.dart';
import 'package:secure_messages/screens/chat_screen.dart';
import 'package:secure_messages/screens/widgets/new_conversation_modal.dart';
import 'package:secure_messages/services/storage_service.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<Conversation> _conversations = [];
  late StorageService _store;
  @override
  void initState() {
    super.initState();
    StorageService _store = GetIt.I<StorageService>();
    _store.addListener(() {
      setState(() {
        _conversations = _store.conversations;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _store = GetIt.I<StorageService>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversations"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _store.deleteData();
            },
          )
        ],
      ),
      body: Consumer(
        builder: (BuildContext context, value, Widget? child) {
          return Column(
            children: _conversations.map((e) => ConversationTile(e)).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.person_add,
          color: Colors.white,
        ),
        onPressed: () {
          showDialog(
              context: context, builder: (context) => NewConversationModal());
        },
      ),
    );
  }
}

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  const ConversationTile(
    this.conversation, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () {
        GetIt.I<StorageService>().deleteConversation(conversation);
      },
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatScreen(conversation)));
      },
      leading: Icon(Icons.person),
      title: Text(conversation.reciepientUID),
    );
  }
}
