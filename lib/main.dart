import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:secure_messages/firebase_options.dart';
import 'package:secure_messages/screens/home_screen.dart';
import 'package:secure_messages/services/authentication_service.dart';
import 'package:secure_messages/services/crypto_service.dart';
import 'package:secure_messages/services/message_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  GetIt.I.registerSingleton<AuthenticationService>(AuthenticationService());
  CryptoService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MessageService().messageStream();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Messaging',
      home: HomeScreen(),
    );
  }
}
