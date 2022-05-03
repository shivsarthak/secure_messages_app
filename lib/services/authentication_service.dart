import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:secretic/models/user_model.dart';
import 'package:secretic/services/crypto_service.dart';

class AuthenticationService with ChangeNotifier {
  late User user;
  late UserModel userModel;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future updateNickname(String nickname) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: 'nickname_secretic', value: nickname);
    userModel.setNickname(nickname);
    notifyListeners();
  }

  Future<AuthenticationService> init() async {
    User? currUser = _auth.currentUser;
    if (currUser != null) {
      user = currUser;
      userModel = await getUserModel();
      return this;
    }
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    user = userCredential.user!;
    userModel = await getUserModel();
    return this;
  }

  Future<UserModel> getUserModel() async {
    final storage = FlutterSecureStorage();
    var nickname = await storage.read(key: 'nickname_secretic');
    if (await storage.containsKey(key: 'nickname_secretic')) {
      print(nickname);
    } else {
      print("nickname not found");
    }
    return UserModel(
        user.uid, nickname ?? 'User', GetIt.I.get<CryptoService>().publicKey);
  }
}
