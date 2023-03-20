import 'package:flutter/material.dart';
import '../api/api.dart';
import 'login.dart';

class RegisterPage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => RegisterPage());
  }

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  RegisterPage({Key? key}) : super(key: key);

  bool isPasswordValid(String password) => password.length == 6;

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
            padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/register.png',
                  width: 200,
                ),
                const SizedBox(
                  height: 80,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF6F35A5),
                          ),
                          hintText: 'First name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter first name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF6F35A5),
                          ),
                          hintText: 'Last name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter last name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.email,
                            color: Color(0xFF6F35A5),
                          ),
                          hintText: 'Email',
                        ),
                        validator: (value) {
                          if (!isEmailValid(value!)) {
                            return 'Email invalid';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passController,
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.password,
                            color: Color(0xFF6F35A5),
                          ),
                          hintText: 'Password',
                        ),
                        validator: (value) {
                          if (!isPasswordValid(value!)) {
                            return 'Password Invalid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            FocusManager.instance.primaryFocus!.unfocus();
                            if (_formKey.currentState!.validate()) {
                              var result = await Api().register(
                                  firstNameController.text,
                                  lastNameController.text,
                                  emailController.text,
                                  passController.text);
                              if (result) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const LoginPage();
                                    },
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Register Error'),
                                    duration: const Duration(seconds: 3),
                                    action: SnackBarAction(
                                      label: 'CLOSE',
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.app_registration_rounded),
                              SizedBox(
                                width: 20,
                              ),
                              Text('REGISTER')
                            ],
                          ))
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
