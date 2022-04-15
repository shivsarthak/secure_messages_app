import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
                publicKey: user.publicKey,
                secretKey: key,
                conversationID: usersList.join(''),
                recipientUID: user.uid,
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

  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.firstWhere((element) {
      try {
        userData = UserModel.fromJson(jsonDecode(element.code ?? ''));
      } catch (e) {
        //Error Occured
      }
      if (userData != null) {
        return true;
      }
      return false;
    }).then((value) {
      Navigator.of(context).pop(userData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan a User Code")),
      body: Column(
        children: [
          Expanded(
              child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
                borderRadius: 20, borderColor: Colors.blue, borderWidth: 5),
          )),
        ],
      ),
    );
  }
}
