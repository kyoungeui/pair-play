import 'package:firebase_auth/firebase_auth.dart';
import 'package:pairplay/components/my_button.dart';
import 'package:pairplay/components/my_textfield.dart';
import 'package:pairplay/helper/helper_functions.dart';
import 'package:flutter/material.dart'; 

class LoginPage extends StatefulWidget {

  final void Function()? onTap; 

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

    // Login 
  void login() async{

    // Show Loading Circle 
    showDialog(
      context: context, 
      builder: (context) => const Center(
        child: CircularProgressIndicator(),)
      ); 
    
    // Sign In 
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
      if (context.mounted) {Navigator.pop(context);}
    } 
    on FirebaseAuthException catch(e){
      Navigator.pop(context); 
      displayMessage(e.code, context); 
    }
  }

    // text controllers
  final TextEditingController emailController = TextEditingController(); 
  final TextEditingController passwordController = TextEditingController(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, 
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          
              // Logo (Card Game)
              Icon(
                Icons.casino_rounded, 
                size:80, 
                //color: Theme.of(context).colorScheme.inversePrimary, 
                color: Colors.blueGrey
                ), 
          
              const SizedBox(height:25), 
          
              // App Name 
              Text(
                "P A I R P L A Y", 
                style: TextStyle(fontSize: 20, color: Colors.blueGrey),

              ),
          
              const SizedBox(height:50), 
          
              // Email 
              MyTextField(
                hintText: "Email", 
                obscureText: false, 
                controller: emailController,
              ), 

              const SizedBox(height:10), 

              // Password 
              MyTextField(
                hintText: "Password", 
                obscureText: true, 
                controller: passwordController,
              ),

              const SizedBox(height:10), 

              //Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Forgot Password?", 
                   style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary
                   ), ), 
                ],), 
              
              const SizedBox(height: 25,), 

              // Sign in Button
              MyButton(
                text: "Login", 
                onTap: login, 
                ), 
              
              const SizedBox(height: 25,), 

              // Register 
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text("Don't have an account?", style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary, 
                )), 
                GestureDetector(
                  onTap: widget.onTap,
                  child: 
                  Text("Register Here", 
                  style: TextStyle(fontWeight: FontWeight.bold))), 
              ],)
            ],
          ),
        ) ,),
    ); 
  }
}