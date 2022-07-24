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
  GetIt.I.registerSingletonAsync<StorageService>(
      () async => await StorageService().init());
  GetIt.I.registerSingletonAsync<CryptoService>(
      () async => await CryptoService().init());
  GetIt.I.registerSingletonAsync<AuthenticationService>(
      () async => await AuthenticationService().init(),
      dependsOn: [CryptoService]);

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
      home: SplashScreen(),
    );
  }
}
