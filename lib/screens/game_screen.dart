import 'package:flutter/material.dart';
import 'package:pairplay/components/game_board.dart';
import 'package:pairplay/providers/pair_play_provider.dart';
import 'package:provider/provider.dart';
import 'package:pairplay/models/player_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final PairPlayProvider _gameProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameProvider = Provider.of<PairPlayProvider>(context, listen: false);
      _initializeGame();
    });
  }

  void _initializeGame() {
    final players = [
      PlayerModel(name: "KY", isHuman: true, previousWinner: true),
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
              color: Colors.black, // Black background
              borderRadius: BorderRadius.circular(15), // Rounded corners
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "WARNING",
                  style: TextStyle(
                    color: Colors.white, // Red title text
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "If you leave now, you will lose your coins and trophies. Are you sure you want to exit?",
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
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Exit Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.pop(context); // Exit the game screen
                      },
                      child: const Text(
                        "Exit",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            top: 20,
            right: 20,
            child: TextButton(
              onPressed: _showExitWarningDialog, // Show warning dialog
              style: TextButton.styleFrom(
                backgroundColor: Colors.black, // Black background
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
              child: const Text(
                "EXIT",
                style: TextStyle(
                  color: Colors.white, // White text
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
