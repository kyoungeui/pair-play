import 'package:flutter/material.dart';

class InstructionScreen extends StatefulWidget {
  const InstructionScreen({Key? key}) : super(key: key);

  @override
  State<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How to Play"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildTitle("🔥 Pair Play Game 🔥"),
                  const SizedBox(height: 20),
                  _buildCard(
                    "🎯 Objective",
                    "Win by outscoring your opponent in up to 3 rounds or reducing their coins to 0.",
                  ),
                  _buildCard(
                    "🃏 Card Values",
                    "- Each player gets 2 cards per round.\n"
                    "- Card value is calculated as:\n"
                    "  (Card 1 Value + Card 2 Value) % 10\n"
                    "- Example: Cards 7 and 5 = (7 + 5) % 10 = 2.",
                  ),
                  _buildCard(
                    "💎 Special Rule: Pairs",
                    "- A pair (two cards of the same value) always beats non-pairs.\n"
                    "- Higher pairs beat lower pairs.\n"
                    "- The strongest hand is a 10 pair.",
                  ),
                  _buildCard(
                    "⏱️ Rounds",
                    "- The game has up to 3 rounds.\n"
                    "- Tied rounds move to the next round.\n"
                    "- The player with the higher card value wins the round.",
                  ),
                  _buildCard(
                    "⚔️ Game Actions",
                    "1. Raise:\n   - Increase the bet by a specific amount (in hundreds).\n"
                    "2. Match:\n   - Match your opponent’s current bet.\n"
                    "3. Fold:\n   - Surrender the round and lose the coins you’ve bet.",
                  ),
                  _buildCard(
                    "🏆 Winning a Round",
                    "- Higher card value wins the round.\n"
                    "- Tied rounds move to the next round.",
                  ),
                  _buildCard(
                    "🚨 Game End",
                    "- The game ends when one player’s coins reach 0 or after 3 rounds.\n"
                    "- The player with the most coins wins.",
                  ),
                  _buildCard(
                    "🧠 Strategy Tips",
                    "- Raise aggressively with strong hands or pairs.\n"
                    "- Conserve your coins by folding weak hands.\n"
                    "- Watch the game patterns to outplay your opponent.",
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "✨ Good Luck! 🍀",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.yellow,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.yellowAccent,
        shadows: [
          Shadow(
            blurRadius: 10,
            color: Colors.orange,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String content) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.yellowAccent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
