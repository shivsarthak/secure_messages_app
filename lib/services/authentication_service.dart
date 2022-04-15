import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

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
    GetIt.instance.signalReady(this);

    return this;
  }
}
