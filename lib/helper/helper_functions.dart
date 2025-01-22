import 'package:flutter/material.dart'; 

// Display message to user

void displayMessage(String message, BuildContext context){
  showDialog(
    context: context,
    builder: (context)=> AlertDialog(
      title: Text(message, textAlign: TextAlign.center,), 
    )); 
}