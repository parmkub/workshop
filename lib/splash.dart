import 'package:flutter/material.dart';
import '../../../api/api.dart';
import 'device_list.dart';
import 'login.dart';
import 'splashscreen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<Widget> loadFromFuture() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (await Api().getToken()) {
      if (Api().hasToken()) {
        return Future.value(const DeviceList());
      }
    }
    return Future.value(const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      navigateAfterFuture: loadFromFuture(),
      title: const Text(
        'INTERNET of THINGS',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
      ),
      loadingText: const Text(
        'Loading',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
      ),
      loadingTextPadding: const EdgeInsets.all(2),
      useLoader: true,
      image: Image.asset('assets/splashscreen.png'),
      backgroundColor: Colors.orange.shade600,
      styleTextUnderTheLoader: const TextStyle(
        color: Colors.deepPurple,
      ),
      photoSize: 100.0,
      loaderColor: Colors.white,
    );
  }
}
