import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mis_lab3/widgets/button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mis_lab3/constants/constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  bool spinner = false;

  @override
  Widget build(BuildContext context) {
    _auth.userChanges().listen((User? user) {
      if (user != null) {
        Navigator.pushNamed(context, '/home');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Најава',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(
                height: 30.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kInputField.copyWith(hintText: 'Внесете е-мејл')),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration:
                      kInputField.copyWith(hintText: 'Внесете лозинка')),
              const SizedBox(
                height: 18.0,
              ),
              Button(
                  title: 'Најави се',
                  color: Colors.teal,
                  onPressed: () async {
                    setState(() {
                      spinner = true;
                    });

                    try {
                      await _auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      Navigator.pushNamed(context, '/home');

                      setState(() {
                        spinner = false;
                      });
                    } catch (e) {
                      print(e);
                    }
                  }),
              Button(
                  title: 'Регистрирај се',
                  color: Colors.blueGrey,
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
