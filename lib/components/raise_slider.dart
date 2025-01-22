import 'package:flutter/material.dart';
import 'package:pairplay/models/player_model.dart';
import 'package:pairplay/providers/pair_play_provider.dart';
import 'package:provider/provider.dart';

class RaiseSlider extends StatefulWidget {
  final PlayerModel player;
  final PlayerModel otherPlayer;
  const RaiseSlider({Key? key, required this.player, required this.otherPlayer}) : super(key: key);

  @override
  State<RaiseSlider> createState() => _RaiseSliderState();
}

class _RaiseSliderState extends State<RaiseSlider> {
  double _currentValue = 0;

  @override
  Widget build(BuildContext context) {
    // Calculate the maximum raise amount based on player coins
    final int max = (widget.player.coin - (widget.otherPlayer.betCoin - widget.player.betCoin));
    final int maxRoundedDown = (max ~/ 100) * 100; // Round down to nearest 100
    final int divisions = maxRoundedDown > 0 ? maxRoundedDown ~/ 100 : 1;

    bool isAllIn = (_currentValue == max.toDouble());
    bool isMatch = (_currentValue == 0);

    String displayText = isMatch ? "MATCH" : isAllIn ? "ALL-IN" : "Raised Value: ${_currentValue.toStringAsFixed(0)}";

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, // Adjusted width for better fitting
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black), // Adjust the color as needed
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              displayText,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 50),
            Slider(
              value: _currentValue,
              min: 0,
              max: maxRoundedDown.toDouble(),
              divisions: divisions,
              label: _currentValue.toStringAsFixed(0),
              onChanged: (double value) {
                setState(() {
                  _currentValue = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () => raisedCoins(context),
                  child: const Text("Raise"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void raisedCoins(BuildContext context) {
    final provider = Provider.of<PairPlayProvider>(context, listen: false);
    provider.raise(_currentValue.toInt()); // Always use the raise function
    Navigator.of(context). pop();
  }
}
