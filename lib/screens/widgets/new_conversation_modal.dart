import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:secure_messages/models/conversation_model.dart';
import 'package:secure_messages/services/storage_service.dart';

import '../../services/authentication_service.dart';

class NewConversationModal extends StatefulWidget {
  const NewConversationModal({Key? key}) : super(key: key);

  @override
  State<NewConversationModal> createState() => _NewConversationModalState();
}

class _NewConversationModalState extends State<NewConversationModal> {
  String uid = GetIt.I<AuthenticationService>().user!.uid;
  final uidField = TextEditingController();
  final nickField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    StorageService store = GetIt.I<StorageService>();

    return AlertDialog(
      title: Text("Start a new conversation"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: uidField,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: "Unique user ID",
            ),
          ),
          TextField(
            controller: nickField,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: "Nickname",
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              Conversation conversation = Conversation(
                  conversationID: uid + uidField.text,
                  reciepientUID: uidField.text,
                  nickname: nickField.text);
              await store.createConversation(conversation);
              Navigator.of(context).pop();
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }
}
