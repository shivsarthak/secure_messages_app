import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:secretic/screens/home_screen.dart';
import 'package:secretic/services/authentication_service.dart';
import 'package:secretic/services/message_service.dart';
import 'package:secretic/services/storage_service.dart';
import 'package:secretic/styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool loaded = false, splash = false;

  @override
  void initState() {
    GetIt.I.allReady().then((_) {
      MessageService()
          .getAllNewMessages(GetIt.I.get<AuthenticationService>().user.uid)
          .then((_) {
        MessageService().messageStream().then((_) {
          GetIt.I.get<StorageService>().getConversations().then((value) {
            setState(() {
              loaded = true;
            });
          });
        });
      });
    });
    Future.delayed(Duration(seconds: 3)).then((_) {
      setState(() {
        splash = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (splash && loaded) {
      return HomeScreen();
    } else {
      return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: white),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: SizedBox()),
                  Text(
                    "Secretum Messenger",
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 32),
                  CircularProgressIndicator(),
                  Expanded(child: SizedBox()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 3,
                          width: 300,
                          child: SvgPicture.asset(
                              'assets/encryption_illustration.svg')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
