import 'package:flutter/material.dart';
import 'package:pairplay/providers/pair_play_provider.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:pairplay/models/player_model.dart';
import 'package:pairplay/components/game_board.dart';


class SinglePage extends StatefulWidget {
  const SinglePage({super.key});

  @override
  State<SinglePage> createState() => _SinglePageState();
}

class _SinglePageState extends State<SinglePage> {

  late final PairPlayProvider _gameProvider; 

  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Gets the User Details 
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (currentUser?.email == null) {
      throw Exception("No email found for current user.");
    }
    return FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUser!.email)
      .get();
  }

  // Initial State 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameProvider = Provider.of<PairPlayProvider>(context, listen: false);
      _initializeGame();
    });
  }

  // Initialize the Game 
  void _initializeGame() async{

    DocumentSnapshot<Map<String, dynamic>> userDoc = await getUserDetails();
    Map<String, dynamic>? userData = userDoc.data();
    String player = userData?['username']?.toUpperCase() ?? 'PLAYER'; // Convert username to uppercase
    
    final players = [
      PlayerModel(name: player, isHuman: true, previousWinner: true),
      PlayerModel(name: "AI", isHuman: false, previousWinner: false),
    ];

    _gameProvider.setBoard(players); // Automatically set up the game board
  }

  void _showExitWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface, 
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "W A R N I N G",
                  style: TextStyle(
                    color: Colors.black, // Red title text
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "If you leave now, you will lose all of your coins and trophies. Are you sure you want to exit?",
                  style: TextStyle(
                    color: Colors.white, // Red content text
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Continue Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Exit Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.pushNamed(context, '/home_page'); // Exit the game screen
                      },
                      child: const Text(
                        "Exit",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // GameBoard takes the full screen
          GameBoard(),
          // Exit Button positioned at the top-right corner
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
            onPressed: _showExitWarningDialog,
            icon: Icon(Icons.exit_to_app), // Using an exit icon
          ),
          ),
        ],
      ),
    );
  }
}