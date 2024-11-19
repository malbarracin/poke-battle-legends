class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;
  final int power;
  List<String> abilities = [];
  String description = '';
  bool isLiked = false;
  bool isDisliked = false;
  final int totalBattles;
  final int wins;
  final int losses;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.power,
    this.isLiked = false,
    this.isDisliked = false,
    this.totalBattles = 0,
    this.wins = 0,
    this.losses = 0,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['other']['official-artwork']['front_default'],
      types: (json['types'] as List).map((type) => type['type']['name'] as String).toList(),
      height: json['height'],
      weight: json['weight'],
      power: json['stats'][0]['base_stat'], // Using HP as power for simplicity
      isLiked: json['isLiked'] ?? false,
      isDisliked: json['isDisliked'] ?? false,
      totalBattles: json['totalBattles'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
    );
  }

  void updateDetails(String description, List<String> abilities) {
    this.description = description;
    this.abilities = abilities;
  }
}