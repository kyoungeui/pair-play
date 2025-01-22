import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pairplay/components/my_button.dart';
import 'package:pairplay/components/my_textfield.dart';
import 'package:pairplay/helper/helper_functions.dart';
import 'package:flutter/material.dart'; 

class RegisterPage extends StatefulWidget {

  final void Function()? onTap; 

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  // text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final TextEditingController emailController = TextEditingController(); 
  final TextEditingController passwordController = TextEditingController(); 

  // Register Method
  void register() async{

    // Show Loading Circle 
    showDialog(
      context: context, 
      builder: (context)=> Center(child: CircularProgressIndicator(),)); 

    // Ensure Passwords match 
    if(passwordController.text != confirmController.text){
      Navigator.pop(context); 

      // Error Message to User 
      displayMessage("Passwords Don't Match", context); 
    }
    else{
    // Create User 
    try{
      UserCredential? userCredential = 
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text, 
        password: passwordController.text); 

      // Create an User Document & Add to Firestore Cloud 
      createUserDocument(userCredential); 

      // Pop the Loading Circle 
      if (context.mounted){Navigator.pop(context);}

    } on FirebaseAuthException catch (e){
      // Pop the Loading Circle 
      Navigator.pop(context); 

      // Display Error 
      displayMessage(e.code, context); 
    }
    }
  }

  // Create an user document & collect them in firestore
  Future<void> createUserDocument(UserCredential? userCredential) async{
    if(userCredential != null && userCredential.user != null){
      await FirebaseFirestore.instance
      .collection("Users")
      .doc(userCredential.user!.email)
      .set({
        'email': userCredential.user!.email, 
        'username': usernameController.text, 
        'coin': 500, 
        'gem':0, 
        'trophy':0, 
      }); 
    }
  }

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
                color: Theme.of(context).colorScheme.inversePrimary, 
                ), 
          
              const SizedBox(height:25), 
          
              // App Name 
              Text(
                "P A I R P L A Y", 
                style: TextStyle(fontSize: 20), 
              ),
          
              const SizedBox(height:50), 
          
              // Username 
              MyTextField(
                hintText: "Username", 
                obscureText: false, 
                controller: usernameController,
              ), 

              const SizedBox(height:10), 

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

              // Confirm Password
              MyTextField(
                hintText: "Confirm Password", 
                obscureText: true, 
                controller: confirmController,
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

              // Register
              MyButton(
                text: "Register", 
                onTap: register, 
                ), 
              
              const SizedBox(height: 25,), 

              // Already have an account? Login Here 
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text("Already have an account? ", style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary, 
                )), 
                GestureDetector(
                  onTap: widget.onTap,
                  child: 
                  Text("Login Here", 
                  style: TextStyle(fontWeight: FontWeight.bold))), 
              ],)

            


          
          
            ],
          ),
        ) ,),
    ); 
  }
}