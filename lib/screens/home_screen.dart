import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'package:secretic/models/conversation_model.dart';
import 'package:secretic/models/conversation_request_model.dart';
import 'package:secretic/models/user_model.dart';
import 'package:secretic/screens/chat_screen.dart';
import 'package:secretic/screens/widgets/drawer.dart';

import 'package:secretic/screens/widgets/new_conversation_modal.dart';
import 'package:secretic/services/crypto_service.dart';
import 'package:secretic/services/storage_service.dart';
import 'package:secretic/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  List<Conversation> _conversations = [];
  List<ConversationRequest> _requests = [];
  final StorageService _store = GetIt.I.get<StorageService>();

  @override
  void initState() {
    super.initState();
    _store.getConversations();
    _store.addListener(() {
      setState(() {
        _conversations = _store.conversations;
        _requests = _store.requests;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: white,
        appBar: _appBar(_scaffoldKey),
        body: _body(),
        drawer: CustomDrawer(),
        floatingActionButton: _fab(context),
      ),
    );
  }

  AppBar _appBar(GlobalKey<ScaffoldState> _scaffoldKey) {
    return AppBar(
      backgroundColor: grey,
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
      ),
      title: Text(
        "Conversations",
        style: TextStyle(color: white),
      ),
      bottom: TabBar(tabs: [
        Tab(
          text: "Messages",
        ),
        Tab(
          text: "Requests",
        ),
      ]),
    );
  }

  FloatingActionButton _fab(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: accentColor,
      child: Icon(
        Icons.qr_code_scanner_outlined,
        color: white,
      ),
      onPressed: () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => QRScanScreen()))
            .then((value) {
          if (value.runtimeType == UserModel) {
            showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AddUserDialog(user: value);
                });
          }
        });
      },
    );
  }

  Widget _body() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TabBarView(children: [
            ListView.separated(
                itemBuilder: ((context, index) =>
                    ConversationTile(_conversations[index])),
                separatorBuilder: (BuildContext context, int index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Divider(
                        color: accentGrey.withOpacity(0.3),
                        thickness: 0.5,
                      ),
                    ),
                itemCount: _conversations.length),
            ListView.separated(
                itemBuilder: ((context, index) =>
                    RequestTile(_requests[index])),
                separatorBuilder: (BuildContext context, int index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Divider(
                        color: accentGrey.withOpacity(0.3),
                        thickness: 0.5,
                      ),
                    ),
                itemCount: _requests.length),
          ]),
        ),
      ],
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
    final f = DateFormat('hh:mm a');
    return ListTile(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatScreen(conversation)));
      },
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: grey,
      ),
      title: Text(
        conversation.nickname ?? conversation.recipientUID,
        style:
            TextStyle(color: grey, fontWeight: FontWeight.w700, fontSize: 14),
      ),
      subtitle: Text(
        conversation.displayContent,
        style:
            TextStyle(color: grey, fontWeight: FontWeight.w400, fontSize: 12),
      ),
      trailing: Text(
        f.format(conversation.lastMessage),
        style:
            TextStyle(color: grey, fontWeight: FontWeight.w400, fontSize: 10),
      ),
    );
  }
}

class RequestTile extends StatelessWidget {
  final ConversationRequest conversation;
  const RequestTile(
    this.conversation, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('hh:mm a');
    return ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: grey,
        ),
        title: Text(
          conversation.recipientUID,
          style:
              TextStyle(color: grey, fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          f.format(conversation.timestamp),
          style:
              TextStyle(color: grey, fontWeight: FontWeight.w400, fontSize: 10),
        ),
        trailing: GestureDetector(
          onTap: () async {
            Navigator.of(context)
                .push<UserModel?>(
                    MaterialPageRoute(builder: (context) => QRScanScreen()))
                .then((value) async {
              if (value != null) {
                var secretKey = await GetIt.I
                    .get<CryptoService>()
                    .sharedSecretKey(value.publicKey);
                await GetIt.I
                    .get<StorageService>()
                    .approveRequest(conversation, secretKey, value.nickname!);
              }
            });
          },
          child: Icon(
            Icons.qr_code_scanner,
            color: grey,
          ),
        ));
  }
}
