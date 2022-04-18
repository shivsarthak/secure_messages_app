import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:secretic/screens/profile_screen.dart';
import 'package:secretic/services/storage_service.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text("test@test.com"),
            accountName: Text("Test"),
          ),
          ListTile(
            leading: Icon(Icons.qr_code),
            title: Text("Show User Code"),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text("Clear Conversations"),
            onTap: () async {
              final StorageService _store = GetIt.I.get<StorageService>();
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
}
