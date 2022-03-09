class UserModel {
  final String uid;
  final String? nickname;

  UserModel(this.uid, this.nickname);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(json['uid'], json['nickname']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'uid': uid,
      'nickname': nickname,
    };
    return json;
  }
}
