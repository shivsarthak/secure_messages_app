import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:secretic/models/user_model.dart';
import 'package:secretic/services/authentication_service.dart';

class QRDisplay extends StatelessWidget {
  const QRDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserModel user = GetIt.I<AuthenticationService>().userModel;
    return QrImage(
      foregroundColor: Color.fromARGB(255, 34, 34, 34),
      data: jsonEncode(user.toJson()),
      size: 200,
    );
  }
}
