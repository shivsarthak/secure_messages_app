import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:secretic/models/conversation_model.dart';
import 'package:secretic/models/user_model.dart';
import 'package:secretic/services/authentication_service.dart';
import 'package:secretic/services/crypto_service.dart';
import 'package:secretic/services/storage_service.dart';

class AddUserDialog extends StatefulWidget {
  final UserModel user;
  const AddUserDialog({Key? key, required this.user}) : super(key: key);

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  bool loading = false;
  Future approve() async {
    setState(() {
      loading = true;
    });
    var usersList = [
      GetIt.I<AuthenticationService>().user.uid,
      widget.user.uid
    ];
    usersList.sort();
    var key = await GetIt.I
        .get<CryptoService>()
        .sharedSecretKey(widget.user.publicKey);
    Conversation conversation = Conversation(
      nickname: widget.user.nickname,
      secure: false,
      secretKey: key,
      conversationID: usersList.join(''),
      recipientUID: widget.user.uid,
      displayContent: '',
      lastMessage: DateTime.now(),
    );

    await GetIt.I.get<StorageService>().createConversation(conversation);
    setState(() {
      loading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Add Conversation'),
      content: SingleChildScrollView(
        child: ListBody(
          children: const <Widget>[
            Text('This is a demo alert dialog.'),
            Text('Would you like to approve of this message?'),
          ],
        ),
      ),
      actions: <Widget>[
        if (!loading)
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        if (!loading)
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              approve();
            },
          ),
        if (loading) CircularProgressIndicator()
      ],
    );
  }
}

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  UserModel? userData;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan a User Code")),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              allowDuplicates: false,
              onDetect: (qr, args) {
                if (qr.rawValue == null) {
                  print("Failed to scan barcode");
                } else {
                  try {
                    userData =
                        UserModel.fromJson(jsonDecode(qr.rawValue ?? ''));
                  } catch (e) {
                    print(e);
                  }
                  if (userData != null) {
                    Navigator.of(context).pop(userData);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
