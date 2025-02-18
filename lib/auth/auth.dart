import 'package:firebase_auth/firebase_auth.dart';
import 'package:pairplay/auth/login_or_register.dart';
import 'package:pairplay/pages/home_page.dart';
import 'package:flutter/material.dart'; 

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Listen to the Stream 
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot){
          // User is logged in 
          if (snapshot.hasData){return HomePage();}
          // User is NOT logged in 
          else{return const LoginOrRegister(); }
        }),);
  }
}