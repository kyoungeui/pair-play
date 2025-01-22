
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pairplay/components/end_screen.dart';
import 'package:pairplay/components/popup_text.dart';
import 'package:pairplay/main.dart';
import 'package:pairplay/models/deck_model.dart';
import 'package:pairplay/models/player_model.dart';
import 'package:pairplay/models/turn_model.dart';
import 'package:pairplay/services/deck_service.dart';
import 'dart:math'; 
 

abstract class GameProvider with ChangeNotifier{

  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (currentUser?.email == null) {
      throw Exception("No email found for current user.");
    }
    return FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUser!.email)
      .get();
  }

  GameProvider(){
    _service = DeckService();
    }

  late DeckService _service; 
  late Turn _turn; 
  Turn get turn => _turn; 

  // proxy to get access to the Deck as Public 
  DeckModel? _currentDeck; 
  DeckModel? get currentDeck => _currentDeck; 

  List<PlayerModel> _players = []; 
  List<PlayerModel> get players => _players; 
 

  // Sets Up The Board 
  Future<void> setBoard(List<PlayerModel> players) async{

  // Debug: Print out who the previous winner is
  for (var player in players) {
    print("${player.name} - Previous Winner: ${player.previousWinner}");
  }

    final deck = await _service.newCustomDeck(); 
    _currentDeck = deck; // set our deck 
    _players = players; // set players 

    // Player plays first if he won the previous round 
    final startingPlayer = players[0].previousWinner? players[0]:players[1]; 
    final startingIndex = players.indexOf(startingPlayer);

    // Turn Model 
    _turn = Turn(
    players: players, 
    currentPlayer: startingPlayer, 
    startingIndex: startingIndex);

    // Deal cards one at a time to each player
    for (int i = 0; i < 2; i++) { // Number of cards to deal
    for (var player in players) {
      await Future.delayed(const Duration(milliseconds: 500)); // Delay between each card
      await drawCards(player, count: 1, allowAnyTime: true); // Draw one card at a time
      notifyListeners(); // Notify to update UI
    }
  }
    // reveal only player's card
    revealAllCards(players[0]); 

    //round change 
    textPopUpEffects(); 
    notifyListeners();

    if(startingPlayer.isBot){
      print("AI starting first, Bot Turn"); 
      await botTurn(); 
    }
  }

   // Draws the Cards 
  Future<void> drawCards(PlayerModel player, {int count =1, bool allowAnyTime=false}) async{

    // No Deck Or Cannot Draw Card 
    if (currentDeck == null){return;}
    if(!canDrawCard && !allowAnyTime){return;}
    final draw = await _service.drawCards(_currentDeck!, count:count); 

    // add the cards 
    player.addCards(draw.cards); 
    _turn.drawCount += count; 
    currentDeck!.remaining = draw.remaining; 
    notifyListeners(); 
  }

  // Reveal All Cards 
  void revealAllCards(PlayerModel player){
    for (var card in player.cards){
      card.isRevealed = true; 
    }
    notifyListeners(); 
  }

  // Reveal One Card Randomly 
  void revealOneRandomCard(PlayerModel player) {
  final hiddenCards = player.cards.where((card) => !card.isRevealed).toList();
  if (hiddenCards.isNotEmpty) {
    final random = Random();
    final randomCard = hiddenCards[random.nextInt(hiddenCards.length)];
    randomCard.isRevealed = true; // Reveal the chosen card
    notifyListeners(); // Notify UI to update
  }
}

  // only draw 2
  bool get canDrawCard{
    return turn.drawCount < 2; 
  }

  // Game is Over turn.currentPlayer.name 
  //  case 1) AI or Player's coin = 0 / case 2) remaining deck is 0 
  bool get gameIsOver{
    return (players[0].coin==0) || (players[1].coin==0) || (currentDeck!.remaining==0) || (turn.gameCount == 10); 
  }

  // Check whether the All-In Happened 
  bool get checkAllIn{
  return ((players[0].coin ==0) || players[1].coin ==0); 
  }

  // Handles Round Counting, "ALL IN", "Not Enough Coin", WIN, LOSE, VICTORY, etc
  Future<void> textPopUpEffects() async {
    
  print("Current Round: ${turn.currentRound}, Previous Round: ${turn.previousRound}");

  // Helper function to show popup messages
  Future<void> showPopup(String message, Color messageColor, {int delay = 1}) async {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => PopupText(message: message, messageColor: messageColor, horizontal: 0.6, vertical: 0.1,),
    );
    await Future.delayed(Duration(seconds: delay));
    Navigator.of(navigatorKey.currentContext!).pop();
  }

   // Show ALL IN message
  if (players[0].coin == 0 || players[1].coin == 0) {
    await showPopup("ALL IN!", Colors.amber, delay: 1);
    notifyListeners();
  }

  // Show round message
  if (turn.currentRound - turn.previousRound == 1) {
    final roundMessages = ["ROUND 1", "ROUND 2", "FINAL ROUND"];
    if (turn.currentRound >= 1 && turn.currentRound <= 3) {
      await showPopup(roundMessages[turn.currentRound - 1], Colors.black, delay: 1);
    }
    turn.previousRound++; 
    notifyListeners();
  }

  // Show round result message
  if (turn.roundEnded) {
    final message = players[0].previousWinner ? "YOU WIN" : "YOU LOSE";
    await showPopup(message, Colors.blueGrey, delay: 1);
    notifyListeners();
  }
}

  // resets the whole round state for the next game 
  void resetRound(){
    print("Resetting Round"); 
    // Reset Player States 
    for (var player in players){
      player.betCoin = 100; 
      player.coin -= player.betCoin; 
      player.cards.clear(); 
      player.playerFolded =false; 
      player.lastAction = PlayerAction.none; 
    }
    // reset draw & action counts 
    _turn.drawCount = 0; 
    _turn.actionCount = 0; 
    _turn.currentRound = 1; 
    _turn.previousRound =0;  
    _turn.turnCount=0; 
    _turn.roundEnded = false; 
    notifyListeners(); 
  }
  
  // raise the coin (For Human - All In Incorporated)
  void raise(int raisedAmount){

    // If raised amount is 0, then automatically match 
    if(raisedAmount ==0){
      match(); 
    }
    // Player decided to Raise certain amount 
    else{

    // total raised amount 
    int totalRaisedAmount = (turn.otherPlayer.betCoin - turn.currentPlayer.betCoin) + raisedAmount; 
    turn.currentPlayer.coin -= totalRaisedAmount; 
    turn.currentPlayer.betCoin += totalRaisedAmount; 

    if(turn.currentPlayer.coin ==0){
      turn.currentPlayer.lastAction = PlayerAction.allIn; 
      textPopUpEffects(); 
      notifyListeners(); 
    }
    else{
      turn.currentPlayer.lastAction = PlayerAction.raised; 
    }
    turn.turnCount++; 
    notifyListeners(); 
    endTurn(); 
    }
  }

  // Raise the Coin (For AI)

 void raiseAI() {
  print("AI attempting to raise...");
  final player = turn.currentPlayer;
  if (!player.isBot) {
    print("Error: Non-AI player is trying to act in AI turn.");
    return;
  }
  final random = Random();
  final percentage = 10 + random.nextInt(41); // 10-50 Random

  int raiseAmount = ((player.coin * percentage) / 100).floor();
  raiseAmount -= raiseAmount % 100;

  if (raiseAmount > 0 && raiseAmount <= player.coin) {
    print("AI raising by $raiseAmount.");
    raise(raiseAmount);
  } 
  else {
    print("AI cannot raise, defaulting to match.");
    match();
  }
}

  // Error Handle Function 
  int cardValue(String value){
    switch (value) {
      case "A":
        return 1; // Ace as 1
      default:
        return int.tryParse(value) ?? 0; // Convert numeric values or default to 0
    }
  }

  // Calculates Players' Deck 
  int calculateValue(PlayerModel player){

    // Pair 
    if (player.cards[0].value == player.cards[1].value){
      return (cardValue(player.cards[0].value) + cardValue(player.cards[1].value)) % 10 + 10; 
    }
    // Non-Pair
    else{
      return (cardValue(player.cards[0].value) + cardValue(player.cards[1].value)) % 10;

    }
  }

  // Determines the Winner & Starts a New Round 
  void determineWinner(){
  bool playerWin = true;

  // Fetch current and other players
  final currentPlayer = turn.currentPlayer;
  final otherPlayer = turn.otherPlayer;

  // Calculate values
  int currentPlayerValue = calculateValue(currentPlayer);
  int otherPlayerValue = calculateValue(otherPlayer);

  // Debugging Information
  print("Current Player Value: $currentPlayerValue, Other Player Value: $otherPlayerValue");
  print("Current Player Folded: ${currentPlayer.playerFolded}, Other Player Folded: ${otherPlayer.playerFolded}");

  // Fold Case
  if (currentPlayer.playerFolded) {
    print("${currentPlayer.name} Folded");
    playerWin = false;
  } 
  else if (otherPlayer.playerFolded) {
    print("${otherPlayer.name} Folded");
    playerWin = true;
  } 
  else if (currentPlayerValue > otherPlayerValue) {
    print("${currentPlayer.name} Won by Value");
    playerWin = true;
  } 
  else if (currentPlayerValue < otherPlayerValue) {
    print("${otherPlayer.name} Won by Value");
    playerWin = false;
  } 
  else if(currentPlayerValue == otherPlayerValue){
    playerWin = true; 
  }
  // Adjust Coins and Winner Status
  if (playerWin) {
    print("${currentPlayer.name} Won. Adjusting Coins...");
    currentPlayer.coin += currentPlayer.betCoin + otherPlayer.betCoin;
    currentPlayer.previousWinner = true;
    otherPlayer.previousWinner = false;
  } else {
    print("${otherPlayer.name} Won. Adjusting Coins...");
    otherPlayer.coin += currentPlayer.betCoin + otherPlayer.betCoin;
    currentPlayer.previousWinner = false;
    otherPlayer.previousWinner = true;
  }
}

  // Handles the Tie Breaker 
  void tieBreaker(){

  }

  // Sets For the Next Round 
  Future<void> allSet() async{

    revealAllCards(players[0]); 
    await Future.delayed(const Duration(seconds: 1)); // Simulate AI thinking
    revealAllCards(players[1]);
    await Future.delayed(const Duration(seconds: 1)); // Simulate AI thinking

    determineWinner(); 
    turn.gameCount ++; 

    if(gameIsOver == true){print("Game Over is True");}
    else{print("Game Over is False");}

    // Game Is Not Over 
    if (gameIsOver == false){

      //Update the Turn Round & GameCount (10번 게임이 진행되면 끝)
      turn.roundEnded = true; 

      // You Win & You Lose 가 있어야 함 
      textPopUpEffects();

      // Round Reset 
      resetRound(); 

      // 새롭게 보드 생성 
      setBoard(players); 
    }
    // Game Over 
    else{
      // Update the Coin for the user 
      summarizeGame(); 

      // Pop Up Effect for Defeat / Victory (Gained Coin + Trophy)
      await Future.delayed(const Duration(milliseconds: 1500)); 
      endScreen(); 
    }

    //Reset the Player Last Action 
    players[0].lastAction = PlayerAction.none;
    players[1].lastAction = PlayerAction.none;

    notifyListeners(); 
  }

  void summarizeGame() async{
    if (currentUser?.email != null){
      DocumentReference docRef = FirebaseFirestore.instance.collection('Users').doc(currentUser!.email); 
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }
        int currentCoins = snapshot['coin'] ?? 0; // Assuming 'coin' field exists and is an integer
        transaction.update(docRef, {'coin': currentCoins + (players[0].coin - 5000)});
        
        int currentTrophy = snapshot['trophy'] ??0; 
        transaction.update(docRef, {'trophy': currentTrophy +calculateTrophies()}); 

      }).then((result) {
        print("Coin added successfully");
      }).catchError((error) {
        print("Failed to add coin: $error");
      });
    }
  }

 void endTurn() {
  _turn.nextTurn(); // Move to the next turn
  print("End turn: Current player is ${_turn.currentPlayer.name}, isBot=${_turn.currentPlayer.isBot}");

  // Check if the next player is AI and trigger their turn
  if (_turn.currentPlayer.isBot) {
    print("End turn: AI's turn next.");
    botTurn();
  } 
  else {
    print("End turn: Human player's turn.");
    notifyListeners(); // Only notify if it's the human player's turn
  }
}


  // Either Raise / Hold / Fold 
Future<void> botTurn() async {
  print("AI Turn: ${turn.currentPlayer.name}");
  await Future.delayed(const Duration(seconds: 2)); // Simulate AI thinking

  // Calculate the AI's hand value
  int aiHandValue = calculateValue(turn.currentPlayer);
  double expectedValue = aiHandValue / 30.0; // Normalize hand value between 0 and 1

  print("AI Hand Value: $aiHandValue");
  print("AI Expected Value: $expectedValue");

  // Generate a random number for probabilistic decision-making
  double randomDecision = Random().nextDouble();
  print("AI Random Decision Value: $randomDecision");

  // Decision-making logic based on probabilities
  if (expectedValue > 0.8) {
    // Strong hand: 70% Raise, 20% Match, 10% Fold
    if (randomDecision < 0.7) {
      print("AI decides to RAISE (Strong hand).");
      raiseAI();
    } else if (randomDecision < 0.9) {
      print("AI decides to MATCH (Strong hand).");
      match();
    } else {
      print("AI decides to FOLD (Strong hand).");
      fold();
    }
  } else if (expectedValue > 0.5) {
    // Moderate hand: 50% Match, 30% Raise, 10% Fold
    if (randomDecision < 0.4) {
      print("AI decides to RAISE (Moderate hand).");
      raiseAI();
    } else if (randomDecision < 0.9) {
      print("AI decides to MATCH (Moderate hand).");
      match();
    } else {
      print("AI decides to FOLD (Moderate hand).");
      fold();
    }
  } else {
    // Weak hand: 10% Raise, 40% Match, 50% Fold
    if (randomDecision < 0.1) {
      print("AI decides to RAISE (Weak hand).");
      raiseAI();
    } else if (randomDecision < 0.5) {
      print("AI decides to MATCH (Weak hand).");
      match();
    } else {
      print("AI decides to FOLD (Weak hand).");
      fold();
    }
  }

  print("AI Turn Complete.");
  notifyListeners();
}

// Matches Opponent Coin & Give the Turn to Opponent (올인 로직도 포함)
  void match(){
    int matchAmount = (turn.otherPlayer.betCoin - turn.currentPlayer.betCoin); 

    // All - IN 이 일어나는 상황 
    if(matchAmount >= turn.currentPlayer.coin){

      // 플레이어는 올인 상태 
      turn.currentPlayer.lastAction = PlayerAction.allIn; 
      textPopUpEffects(); 
      notifyListeners(); 

      // 올인한 플레이어의 코인 상황 
      turn.currentPlayer.betCoin += turn.currentPlayer.coin; 
      turn.currentPlayer.coin =0; 
      notifyListeners(); 

      // 올인을 받은 플레이어의 코인 상황 
      turn.otherPlayer.betCoin = turn.currentPlayer.betCoin; 
      turn.otherPlayer.coin += (turn.otherPlayer.betCoin - turn.currentPlayer.betCoin); 

      // 상황 종료 
      turn.roundEnded = true; 
      notifyListeners(); 
      allSet(); 
    }
    else{
      turn.currentPlayer.lastAction = PlayerAction.called; 
    if(turn.currentPlayer.isHuman){
      print("Human Decided to Match"); 
    }
    notifyListeners(); 
    
    // Each round first turn, Player can hold and give opponent an opportunity to bet
    if(turn.turnCount == 0){
      turn.turnCount++; 
      endTurn(); 
    }
    else{ 
      turn.currentPlayer.betCoin += matchAmount; 
      turn.currentPlayer.coin -= matchAmount; 

      if (turn.currentRound ==1){
      turn.currentRound++; 
      textPopUpEffects(); 
      endTurn(); 
      revealOneRandomCard(players[1]); 
      notifyListeners(); 
    }
    else if(turn.currentRound ==2){
      turn.currentRound++; 
      textPopUpEffects(); 
      endTurn(); 
      notifyListeners(); 
    }
    // Final Round
    else if(turn.currentRound ==3){
      turn.roundEnded = true; 
      notifyListeners(); 
      allSet(); 
    }
    turn.turnCount =0; 
    }
    }
  }

  // loses all betCoin & starts the new Round 
  void fold(){
    turn.currentPlayer.lastAction = PlayerAction.folded; 
    turn.currentPlayer.playerFolded = true;
    turn.roundEnded = true; 
    notifyListeners(); 
    allSet(); 
  }
  
  

  // Calculate the earned trophies 
  int calculateTrophies(){
    return ((players[0].coin - players[1].coin)/300).toInt(); 
  }

// Victory & Defeat Screen + Called when gameIsOVer is true 
  void endScreen(){
    int decideWinner = (players[0].coin - players[1].coin); // Determing the winner by left coins 
    int trophies = calculateTrophies(); 

    // Victory
    if (decideWinner >0){
      showDialog(
        context: navigatorKey.currentContext!, 
        builder: (_) =>
        EndScreen(
        earnedCoin: decideWinner-5000, 
        earnedTrophies: trophies, 
        playerStatus: "V I C T O R Y",
        messageColor: Colors.blueGrey,),);  
    }
    // Draw 
    else if(decideWinner == 0){
     showDialog(
        context: navigatorKey.currentContext!, 
        builder: (_) =>
        EndScreen(
        earnedCoin: decideWinner-5000, 
        earnedTrophies: trophies, 
        playerStatus: "D R A W",
        messageColor: Colors.black,),);  
    }
    // Defeat 
    else{
      showDialog(
        context: navigatorKey.currentContext!, 
        builder: (_) =>
        EndScreen(
        earnedCoin: decideWinner-5000, 
        earnedTrophies: trophies, 
        playerStatus: "D E F E A T",
        messageColor: Colors.redAccent,),);  
    }
    notifyListeners(); 
  }
}

