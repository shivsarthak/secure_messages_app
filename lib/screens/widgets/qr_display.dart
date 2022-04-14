import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_messages/models/user_model.dart';
import 'package:secure_messages/services/authentication_service.dart';

class QRDisplay extends StatelessWidget {
  final UserModel? user;
  const QRDisplay(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QrImage(
      foregroundColor: Color.fromARGB(255, 34, 34, 34),
      data: jsonEncode(user != null ? user!.toJson() : {}),
      size: 200,
    );
  }
}
