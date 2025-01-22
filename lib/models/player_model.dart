
import 'package:pairplay/models/card_model.dart'; 

enum PlayerAction{none, raised, called, folded, allIn}

class PlayerModel {

  
  final String name; //Player Name 
  final bool isHuman; // Differentiates Human & AI
  int coin; // Player Coin 
  int betCoin; // Player betted coin 
  List<CardModel> cards; // Player's hand 
  bool previousWinner; // decides which player will start first at the next round 
  bool playerFolded; // checks whether the player folded 
  PlayerAction lastAction = PlayerAction.none; 
  

  // Player Constructor 
  PlayerModel({
  required this.name, 
  this.isHuman = false, 
  this.cards = const[],
  this.coin = 4900, // total coin 
  this. betCoin =100, // bet coin (every new game, players need to bet 100)
  this.previousWinner = false,
  this.playerFolded = false, 
  }
  ); 
  

  addCards(List<CardModel> newcards){
    // add current cards & newcards (combining 2 lists)
    cards = [...cards, ...newcards]; 
  }

  // remove a card 
  removeCard(CardModel card){
    cards.removeWhere((c)=>c.value == card.value && c.suit==card.suit); 
  }

  // Ask Bot Or Human 
  bool get isBot{return !isHuman;}
}