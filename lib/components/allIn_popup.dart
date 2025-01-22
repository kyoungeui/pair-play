import 'package:flutter/material.dart';
import 'package:pairplay/providers/pair_play_provider.dart';
import 'package:provider/provider.dart'; 

class AllinPopup extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const AllinPopup({
    super.key, 
    required this.onAccept, 
    required this.onReject
  });

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
          border: Border.all(color: Colors.black,), 
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Will You Accept Opponent's ALL-IN?",
              style: TextStyle(
                color: Colors.black, 
                fontWeight: FontWeight.bold, 
                fontSize: 20, 
              ),
            ), 
            const SizedBox(height:20), 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: onAccept,
                  child: const Text("Accept")
                ), 
                TextButton(
                  onPressed: onReject,
                  child: const Text("Reject")
                ), 
              ],
            )
          ],
        ),
      ), 
    ); 
  }
}
