import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pairplay/components/card_list.dart';
import 'package:pairplay/components/deck_pile.dart';
import 'package:pairplay/components/raise_slider.dart';
import 'package:pairplay/models/player_model.dart';
import 'package:pairplay/providers/pair_play_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameBoard extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (currentUser?.email == null) {
      throw Exception("No email found for current user.");
    }
    return FirebaseFirestore.instance.collection("Users").doc(currentUser!.email).get();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PairPlayProvider>(
      builder: (context, model, child) {
        if (model.currentDeck == null) {
          return Center(child: CircularProgressIndicator());
        }
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CardList(player: model.players[1]), // Computer's cards
                ),
                InfoBox(player: model.players[1]),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await model.drawCards(model.turn.currentPlayer);
                      },
                      child: DeckPile(remaining: model.currentDeck!.remaining),
                    ),
                    const SizedBox(width: 10),

                    Column(children: [
                    betCoinBox(context, "AI", model.players[1].betCoin, Colors.redAccent),
                    const SizedBox(height:13), 
                    betCoinBox(context, model.players[0].name, model.players[0].betCoin, Colors.blueGrey),
                    ],),
                  ],
                ),
                const SizedBox(height: 20),
                InfoBox(player: model.players[0]),
                const SizedBox(height: 10),
                CardList(player: model.players[0]), // Player's cards
                const SizedBox(height: 10),
                actionButtons(context, model.players[0], model.players[1]), // Three buttons 
              ],
            ),
          ),
        );
      },
    );
  }

  Widget betCoinBox(BuildContext context, String playerName, int betCoin, Color borderColor) {
    return Container(
        width: 113,
        height: 73,
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Text(
                    playerName,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                    betCoin.toString(),
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                ),
            ],
        ),
    );
}


// Expanded 를 쓰면 화면을 꽉 채울 수 있음 
Widget actionButtons(BuildContext context, PlayerModel humanPlayer, PlayerModel aiPlayer) {
  bool activateAllIn = (aiPlayer.betCoin - humanPlayer.betCoin) >= humanPlayer.coin;

  return Padding(
    padding: const EdgeInsets.all(8.0), // Adds padding around the entire row
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: activateAllIn ? [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {context.read<PairPlayProvider>().match();},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                side: BorderSide(color: Colors.black, width: 1.5),
              ),
              child: const Text("ALL-IN"),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {context.read<PairPlayProvider>().fold();},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                side: BorderSide(color: Colors.black, width: 1.5),
              ),
              child: const Text("DIE"),
            ),
          ),
        ),
      ] : [
        Expanded( // RAISE button
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      content: ChangeNotifierProvider<PairPlayProvider>.value(
                        value: Provider.of<PairPlayProvider>(context, listen: false),
                        child: RaiseSlider(player: humanPlayer, otherPlayer: aiPlayer),
                      )
                    );
                  }
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                side: BorderSide(color: Colors.black, width: 1.5),
              ),
              child: const Text("RAISE"),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {context.read<PairPlayProvider>().match();},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                side: BorderSide(color: Colors.black, width: 1.5),
              ),
              child: const Text("CALL"),
            ),
          ),
        ), 
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {context.read<PairPlayProvider>().fold();},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                side: BorderSide(color: Colors.black, width: 1.5),
              ),
              child: const Text("FOLD"),
            ),
          ),
        ),
      ],
    ),
  );
}
}

class InfoBox extends StatefulWidget {
  final PlayerModel player;

  InfoBox({Key? key, required this.player}) : super(key: key);

  @override
  _InfoBoxState createState() => _InfoBoxState();
}

class _InfoBoxState extends State<InfoBox> {
  Timer? _timer;
  bool _showAction = true; 

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showAction = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant InfoBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.player.lastAction != oldWidget.player.lastAction) {
      _showAction = true;
      _timer?.cancel();
      _timer = Timer(Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _showAction = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Row(
        children: [
          Text(widget.player.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          const Icon(Icons.monetization_on, color: Colors.yellow),
          const SizedBox(width: 5),
          Text(widget.player.coin.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          Text(describeAction(widget.player.lastAction), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String describeAction(PlayerAction action) {
    switch (action) {
      case PlayerAction.raised:
        return "${widget.player.name} Raised!";
      case PlayerAction.called:
        return "${widget.player.name} Matched!";
      case PlayerAction.folded:
        return "${widget.player.name} Folded!";
      case PlayerAction.allIn: 
      return "${widget.player.name} ALL-IN!";
      default:
        return "";
    }
  }
}