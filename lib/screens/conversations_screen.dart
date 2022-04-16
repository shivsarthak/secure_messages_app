import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'package:secretic/models/conversation_model.dart';
import 'package:secretic/models/user_model.dart';
import 'package:secretic/screens/chat_screen.dart';
import 'package:secretic/screens/widgets/new_conversation_modal.dart';
import 'package:secretic/services/storage_service.dart';
import 'package:secretic/styles.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with AutomaticKeepAliveClientMixin {
  List<Conversation> _conversations = [];
  final StorageService _store = GetIt.I.get<StorageService>();
  @override
  void initState() {
    super.initState();

    _store.addListener(() {
      setState(() {
        _conversations = _store.conversations;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: white,
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
        elevation: 0,
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
          Icons.qr_code_scanner_outlined,
          color: Colors.white,
        ),
        onPressed: () async {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => QRScanScreen()))
              .then((value) {
            if (value.runtimeType == UserModel) {
              confirmAddUserDialog(context, value);
            }
          });
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
        GetIt.I.get<StorageService>().deleteConversation(conversation);
      },
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatScreen(conversation)));
      },
      leading: Icon(Icons.person),
      title: Text(conversation.recipientUID),
    );
  }
}
