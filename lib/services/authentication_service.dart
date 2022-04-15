import 'package:firebase_auth/firebase_auth.dart';
import 'package:secretic/services/message_service.dart';

class AuthenticationService {
  bool isAuthenticated = false;
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthenticationService() {
    checkAuth(_auth).then((value) {
      user = value;
      MessageService().getAllNewMessages(user!.uid);
    });
  }
  Future<User> checkAuth(FirebaseAuth auth) async {
    User? user = auth.currentUser;
    if (user != null) {
      isAuthenticated = true;
      return user;
    }
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    return userCredential.user!;
  }
}
