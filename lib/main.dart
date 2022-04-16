import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:secretic/firebase_options.dart';
import 'package:secretic/screens/home_screen.dart';
import 'package:secretic/screens/splash_screen.dart';
import 'package:secretic/services/authentication_service.dart';
import 'package:secretic/services/crypto_service.dart';
import 'package:secretic/services/message_service.dart';
import 'package:secretic/services/storage_service.dart';
import 'package:secretic/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  GetIt.I.registerSingletonAsync<AuthenticationService>(
      () async => AuthenticationService().init());
  GetIt.I.registerSingletonAsync<CryptoService>(
      () async => CryptoService().init());
  GetIt.I.registerSingletonAsync<StorageService>(
      () async => StorageService().init());
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme(
              background: white,
              brightness: Brightness.dark,
              error: accentColor,
              onBackground: white,
              onError: white,
              onPrimary: white,
              onSecondary: white,
              onSurface: white,
              primary: primaryColor,
              secondary: accentColor,
              surface: accentGrey),
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
          )),
      debugShowCheckedModeBanner: false,
      title: 'Secretic',
      home: FutureBuilder(
          future: GetIt.I.allReady(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              MessageService().getAllNewMessages(
                  GetIt.I.get<AuthenticationService>().user.uid);
              MessageService().messageStream();
              GetIt.I.get<StorageService>().getConversations();
              return HomeScreen();
            }
            return SplashScreen();
          })),
    );
  }
}
