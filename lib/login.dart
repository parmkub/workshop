import 'package:flutter/material.dart';
import '../api/api.dart';
import 'device_list.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => const LoginPage());
  }

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formState = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool showPass = false;

  bool isEmailValid(String email) {
    RegExp regex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/login.png',
                  width: 200,
                ),
                Form(
                  key: _formState,
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        validator: (value) {
                          print(value);
                          if (isEmailValid(value!)) {
                            return null;
                          }
                          return 'Error Email';
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          hintText: 'Email',
                        ),
                      ),
                      TextFormField(
                        controller: passwordController,
                        validator: (value) {
                          print(value);
                          if (value!.isNotEmpty) {
                            return null;
                          }
                          return 'Error Password';
                        },
                        obscureText: !showPass,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.password),
                          hintText: 'Password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showPass = !showPass;
                              });
                            },
                            icon: Icon(
                              showPass
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    FocusManager.instance.primaryFocus!.unfocus();
                    if (_formState.currentState!.validate()) {
                      if (await Api().login(
                          emailController.text, passwordController.text)) {
                        print('LOGIN SUCCESS');
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => const DeviceList()));
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('LOGIN FAILED'),
                          duration: Duration(seconds: 3),
                        ));
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.login),
                      Text('LOGIN'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      RegisterPage.route(),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.app_registration),
                      Text("REGISTER"),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
