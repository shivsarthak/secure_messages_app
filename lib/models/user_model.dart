import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class UserModel {
  final String uid;
  String? nickname;
  final SimplePublicKey publicKey;

  UserModel(this.uid, this.nickname, this.publicKey);

  setNickname(String name) {
    nickname = name;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      json['uid'],
      json['nickname'],
      SimplePublicKey(
        base64.decode(json['pub_key']),
        type: KeyPairType.x25519,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'uid': uid,
      'nickname': nickname,
      'pub_key': base64.encode(publicKey.bytes),
    };
    return json;
  }
}
