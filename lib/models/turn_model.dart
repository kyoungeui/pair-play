
import 'package:pairplay/models/player_model.dart';


class Turn {

  // List of Players Playing the Game 
  final List<PlayerModel> players; 

  // this variable change
  int previousRound; 
  int currentRound; 
  int index; 
  PlayerModel currentPlayer; 
  int drawCount; 
  int actionCount; 
  int turnCount; 
  bool roundEnded; 
  int gameCount; 

  Turn({
  required this.players,
  required PlayerModel currentPlayer,
  this.turnCount = 0,
  int? startingIndex,
  this.drawCount = 0,
  this.actionCount = 0,
  this.previousRound = 0,
  this.currentRound = 1,
  this.roundEnded = false,
  this.gameCount =0, 
}) : index = startingIndex ?? players.indexOf(currentPlayer),
     currentPlayer = currentPlayer;
    
  // changing the turn 
 void nextTurn() {
  // Increment the index, wrapping around to ensure it stays within the bounds of the player list
  index = (index + 1) % players.length;
  // Set the current player based on the updated index
  currentPlayer = players[index];
  // Reset counts for the new turn
  drawCount = 0;
  actionCount = 0;

  print("Next turn: index=$index, currentPlayer=${currentPlayer.name}");
}

  PlayerModel get otherPlayer{
    return players.firstWhere((p) => p!= currentPlayer); 
  }
}