import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  late User user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthenticationService> init() async {
    User? currUser = _auth.currentUser;
    if (currUser != null) {
      user = currUser;
      return this;
    }
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    user = userCredential.user!;
    return this;
  }
}
