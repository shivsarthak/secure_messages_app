import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:secure_messages/models/user_model.dart';
import 'package:secure_messages/screens/widgets/qr_display.dart';
import 'package:secure_messages/services/authentication_service.dart';
import 'package:secure_messages/services/crypto_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  UserModel? user;

  Future<UserModel> _initUser() async {
    CryptoService instance = CryptoService();
    SimplePublicKey key = await instance.keyPair.extractPublicKey();
    UserModel user =
        UserModel(GetIt.I<AuthenticationService>().user!.uid, '', key);
    return user;
  }

  @override
  void initState() {
    _initUser().then((value) {
      setState(() {
        user = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 24),
          Text(
            "Your User Code",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QRDisplay(user),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
