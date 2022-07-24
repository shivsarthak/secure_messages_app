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

Future<void> confirmAddUserDialog(BuildContext context, UserModel user) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
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
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Approve'),
            onPressed: () async {
              var usersList = [
                GetIt.I<AuthenticationService>().user.uid,
                user.uid
              ];
              usersList.sort();
              var key = await GetIt.I
                  .get<CryptoService>()
                  .sharedSecretKey(user.publicKey);
              Conversation conversation = Conversation(
                secure: false,
                secretKey: key,
                conversationID: usersList.join(''),
                recipientUID: user.uid,
                displayContent: '',
                lastMessage: DateTime.now(),
              );

              await GetIt.I
                  .get<StorageService>()
                  .createConversation(conversation);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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
