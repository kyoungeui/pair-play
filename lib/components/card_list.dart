import 'package:pairplay/components/playing_card.dart';
import 'package:pairplay/components/constants.dart';
import 'package:pairplay/models/card_model.dart';
import 'package:pairplay/models/player_model.dart';
import 'package:flutter/material.dart';

class CardList extends StatelessWidget {
  final double size;
  final PlayerModel player;
  final Function(CardModel)? onPlayCard;

  const CardList({
    Key? key,
    required this.player,
    this.size = 1,
    this.onPlayCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: CARD_HEIGHT * size,
      width: double.infinity,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min, // Center the cards
          children: player.cards.map((card) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding between cards
              child: PlayingCard(
                card: card,
                size: size,
                //visible: player.isHuman, 
                //visible: true,
                onPlayCard: onPlayCard,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
