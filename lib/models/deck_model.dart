
class DeckModel{
  final String deck_id; 
  bool shuffled; 
  int remaining; 

  DeckModel({
    required this.deck_id, 
    required this.shuffled, 
    required this.remaining,}); 

  factory DeckModel.fromJson(Map<String, dynamic> json){
    return DeckModel(
      deck_id: json['deck_id'], 
      shuffled: json['shuffled'], 
      remaining: json['remaining'],
      ); 
  }
}