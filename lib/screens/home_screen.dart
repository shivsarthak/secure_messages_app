import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:secretic/models/conversation_model.dart';
import 'package:secretic/models/user_model.dart';
import 'package:secretic/screens/chat_screen.dart';

import 'package:secretic/screens/widgets/new_conversation_modal.dart';
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
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: grey,
        appBar: _appBar(_scaffoldKey),
        body: _body(),
        drawer: _drawer(),
        floatingActionButton: _fab(context),
      ),
    );
  }

  Drawer _drawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text("test@test.com"),
            accountName: Text("Test"),
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text("Clear Conversations"),
            onTap: () async {
              await _store.deleteData();
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () async {},
          ),
        ],
      ),
    );
  }

  AppBar _appBar(GlobalKey<ScaffoldState> _scaffoldKey) {
    return AppBar(
      backgroundColor: Colors.transparent,
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
            confirmAddUserDialog(context, value);
          }
        });
      },
    );
  }

  Widget _body() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: primaryGradient,
          ),
        ),
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
    return ListTile(
      onLongPress: () {
        GetIt.I.get<StorageService>().deleteConversation(conversation);
      },
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatScreen(conversation)));
      },
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: white,
      ),
      title: Text(
        "John Doe",
        style:
            TextStyle(color: white, fontWeight: FontWeight.w700, fontSize: 14),
      ),
      subtitle: Text(
        "hey Buddy how have you been ?",
        style:
            TextStyle(color: white, fontWeight: FontWeight.w400, fontSize: 12),
      ),
      trailing: Text(
        '5:45 pm',
        style:
            TextStyle(color: white, fontWeight: FontWeight.w400, fontSize: 10),
      ),
    );
  }
}
