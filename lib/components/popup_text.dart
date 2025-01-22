import 'package:flutter/material.dart';

class PopupText extends StatelessWidget {
  final String message;
  final Color messageColor; 
  final double horizontal; 
  final double vertical; 

  const PopupText({Key? key, required this.message, required this.messageColor, required this.horizontal, required this.vertical}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * horizontal,
        height: MediaQuery.of(context).size.height * vertical, 
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary, 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: messageColor,), 
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: messageColor, 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

