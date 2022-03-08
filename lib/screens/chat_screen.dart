import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:secure_messages/enums/message_content_type.dart';
import 'package:secure_messages/enums/message_type.dart';
import 'package:secure_messages/models/chat_mesage_model.dart';
import 'package:secure_messages/models/conversation_model.dart';
import 'package:secure_messages/services/chat_service.dart';

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
  String uid = GetIt.I<AuthenticationService>().user!.uid;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ChatService(widget.conversation),
      builder: (context, _) => Scaffold(
        backgroundColor: Color(0xfff5f5f5),
        appBar: _appBar(context),
        body: _appBody(context),
      ),
    );
  }

  Column _appBody(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _ConversationSpace(),
        Container(
          padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
          height: 60,
          width: double.infinity,
          color: Colors.white,
          child: Row(
            children: <Widget>[
              // GestureDetector(
              //   onTap: () {},
              //   child: Container(
              //     height: 30,
              //     width: 30,
              //     decoration: BoxDecoration(
              //       color: Colors.lightBlue,
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //     child: Icon(
              //       Icons.add,
              //       color: Colors.white,
              //       size: 20,
              //     ),
              //   ),
              // ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      hintText: "Write message...",
                      hintStyle: TextStyle(color: Colors.black54),
                      border: InputBorder.none),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              FloatingActionButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    ChatMessage message = ChatMessage(
                      contentType: MessageContentType.text,
                      conversationID: widget.conversation.conversationID,
                      messageContent: controller.text,
                      messageType: MessageType.sent,
                      recieverUID: widget.conversation.reciepientUID,
                      senderUID: uid,
                      timestamp: DateTime.now(),
                    );
                    controller.clear();
                    Provider.of<ChatService>(context, listen: false)
                        .sendMessage(message);
                  }
                },
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 18,
                ),
                backgroundColor: Colors.blue,
                elevation: 0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
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
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 2,
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://randomuser.me/api/portraits/men/5.jpg"),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "Online",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.settings,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 2 / 3),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue,
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
                      Text(
                        service.messages[index].timestamp.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        service.messages[index].timestamp.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 2 / 3),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            service.messages[index].messageContent,
                            style: TextStyle(color: Colors.grey),
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