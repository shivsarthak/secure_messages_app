import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:secretic/models/user_model.dart';
import 'package:secretic/screens/widgets/qr_display.dart';
import 'package:secretic/services/authentication_service.dart';
import 'package:secretic/services/crypto_service.dart';
import 'package:secretic/styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  AuthenticationService user = GetIt.I<AuthenticationService>();

  bool _isEditingText = false;
  late TextEditingController _editingController;
  String initialText = "";

  @override
  void initState() {
    _editingController = TextEditingController(text: initialText);
    initialText = user.userModel.nickname ?? 'User';
    super.initState();
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  Widget _editTitleTextField() {
    if (_isEditingText) {
      return Center(
        child: TextField(
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
          onSubmitted: (newValue) {
            setState(() {
              initialText = newValue;
              user.updateNickname(newValue).then((value) {
                _isEditingText = false;
              });
            });
          },
          autofocus: true,
          controller: _editingController,
        ),
      );
    }

    return InkWell(
        onTap: () {
          setState(() {
            _isEditingText = true;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(initialText,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w600)),
            SizedBox(width: 12),
            Icon(
              Icons.edit,
              color: Colors.white70,
              size: 18,
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: black,
        appBar: AppBar(
          title: Text("Profile"),
          backgroundColor: grey,
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _editTitleTextField(),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(width: 4, color: Colors.white),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24)),
                      child: Center(child: QRDisplay()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                "Share this QR code to connect",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
