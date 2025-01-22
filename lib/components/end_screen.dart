import 'package:flutter/material.dart';
import 'package:pairplay/main.dart';
import 'package:pairplay/pages/home_page.dart'; 

class EndScreen extends StatelessWidget {

  final String playerStatus; 
  final int earnedCoin; 
  final int earnedTrophies; 
  final Color messageColor; 

  const EndScreen ({Key? key,
   required this.playerStatus, 
   required this.earnedCoin, 
   required this.earnedTrophies, 
   required this.messageColor, 
   }): super(key: key); 


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.5, 
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary, 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: messageColor,), 
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Victory / Defeat / Draw 
            Text(
              playerStatus,
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: messageColor, 
                fontWeight: FontWeight.bold, 
                fontSize: 40, // Can be Fixed 
              ), 
            ), 

            const SizedBox(height: 50), 

            Text(
              "Coin: ${earnedCoin.toString()}",
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: messageColor, 
                fontWeight: FontWeight.bold, 
                fontSize: 20, // Can be Fixed 
              ), 
              ), 

            const SizedBox(height: 10,), 

            Text(
              "Trophies: ${earnedTrophies.toString()}",
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: messageColor, 
                fontWeight: FontWeight.bold, 
                fontSize: 20, // Can be Fixed 
              ), 
              ), 
            
            const SizedBox(height: 20,), 
            
            //Return Home Button 
            TextButton(onPressed: ()=>
            Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
            ), child: const Text("Return")), 
          ],)
        ),); 
  }
}