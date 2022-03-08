import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  SimpleKeyPair? dhKeyPair;
  final algorithm = X25519();
  final storage = FlutterSecureStorage();
  CryptoService() {
    _init();
  }

  _init() async {
    if (await storage.containsKey(key: "secure_messaging_key_pair")) {
      storage.read(key: "secure_messaging_key_pair");
    } else {
      var newPair = await algorithm.newKeyPair();
      await newPair.extractPublicKey();
    }
  }
}
