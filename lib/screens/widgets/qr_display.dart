import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:secretic/models/user_model.dart';

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
