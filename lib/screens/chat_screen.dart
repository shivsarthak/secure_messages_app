import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:secretic/enums/message_type.dart';
import 'package:secretic/models/local_mesage_model.dart';
import 'package:secretic/models/conversation_model.dart';
import 'package:secretic/services/chat_service.dart';
import 'package:secretic/services/crypto_service.dart';
import 'package:secretic/styles.dart';

import '../services/authentication_service.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  const ChatScreen(
    this.conversation, {
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String uid = GetIt.I<AuthenticationService>().user.uid;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ChatService(widget.conversation),
      builder: (context, _) => Scaffold(
        backgroundColor: grey,
        appBar: _appBar(context),
        body: _appBody(context),
      ),
    );
  }

  Widget _appBody(BuildContext context) {
    TextEditingController controller = TextEditingController();
    final ChatService chatService =
        Provider.of<ChatService>(context, listen: true);
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(gradient: primaryGradient),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            _ConversationSpace(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: grey,
                        border: Border.all(
                          width: 1,
                          color: primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(24)),
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                                hintText: "Message...",
                                hintStyle: TextStyle(color: white),
                                border: InputBorder.none),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      LocalMessage message = LocalMessage(
                        conversationID: widget.conversation.conversationID,
                        messageContent: controller.text,
                        messageType: MessageType.sent,
                        recieverUID: widget.conversation.recipientUID,
                        senderUID: uid,
                        timestamp: DateTime.now(),
                      );
                      controller.clear();
                      chatService.sendMessageToConversation(message);
                    }
                  },
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                  backgroundColor: accentColor,
                  elevation: 0,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: lighterGrey,
      flexibleSpace: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: white,
                ),
              ),
              SizedBox(
                width: 2,
              ),
              CircleAvatar(
                backgroundColor: white,
                maxRadius: 20,
              ),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "John Doe",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: white),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "Online",
                      style: TextStyle(color: accentGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Icon(
              //   Icons.settings,
              //   color: Colors.black54,
              // ),
            ],
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          itemBuilder: (BuildContext context) {
            return {'Clear Conversation', 'Settings'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}

class _ConversationSpace extends StatefulWidget {
  const _ConversationSpace({
    Key? key,
  }) : super(key: key);

  @override
  State<_ConversationSpace> createState() => _ConversationSpaceState();
}

class _ConversationSpaceState extends State<_ConversationSpace> {
  @override
  Widget build(BuildContext context) {
    final f = DateFormat('hh:mm a');
    return Expanded(
      child: Consumer<ChatService>(
        builder: (BuildContext context, service, Widget? child) {
          return ListView.builder(
            itemCount: service.messages.length,
            reverse: true,
            itemBuilder: (context, index) {
              if (service.messages[index].messageType == MessageType.received) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 2 / 3),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: lighterGrey,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            service.messages[index].messageContent,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 24),
                      Text(
                        f.format(service.messages[index].timestamp),
                        style: TextStyle(fontSize: 10, color: white),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        f.format(service.messages[index].timestamp),
                        style: TextStyle(fontSize: 10, color: white),
                      ),
                      SizedBox(width: 24),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 2 / 3),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: secondaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            service.messages[index].messageContent,
                            style: TextStyle(color: white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
