import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:secretic/models/user_model.dart';
import 'package:secretic/services/authentication_service.dart';

class QRDisplay extends StatefulWidget {
  const QRDisplay({Key? key}) : super(key: key);

  @override
  State<QRDisplay> createState() => _QRDisplayState();
}

class _QRDisplayState extends State<QRDisplay> {
  AuthenticationService _user = GetIt.I<AuthenticationService>();
  late UserModel user;
  @override
  void initState() {
    user = _user.userModel;
    _user.addListener(() {
      setState(() {
        user = _user.userModel;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _user.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QrImage(
      foregroundColor: Color.fromARGB(255, 34, 34, 34),
      data: jsonEncode(user.toJson()),
      size: 200,
    );
  }
}
