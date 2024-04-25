// ignore_for_file: unused_import, prefer_const_constructors, non_constant_identifier_names

import 'package:calculatorapp/pages/home.dart';
import 'package:calculatorapp/pages/login_or_register_oages.dart';
import 'package:calculatorapp/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //user is logged in
            if (snapshot.hasData) {
              return HomePage();
            
            //user is not logged in
            } else {
              return LoginOrRegisterPage();
            }
          }),
    );
  }
}

//class Auth {
//  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//  User? get currentUser => _firebaseAuth.currentUser;

//  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

//  Future<void> signInWithEmailAndPassword({
//   required String email,
//    required String password,
//  }) async {
//    await _firebaseAuth.signInWithEmailAndPassword
//    (
//      email: email, 
//      password: password
//      );
//  }

//  Future<void> createUserWithEmailAndPassword({
//    required String email,
//    required String password,
//  }) async {
//    await _firebaseAuth.createUserWithEmailAndPassword
//    (
//      email: email, 
//      password: password
//      );
//  }


//Future<void> signOut () async {
//  await _firebaseAuth.signOut();
//}

//}



