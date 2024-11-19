import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';

class PokemonProvider with ChangeNotifier {
  List<Pokemon> _allPokemon = [];
  Map<int, int> _battlePoints = {};
  Map<int, int> _levels = {};
  bool _isLoading = false;
  int _currentPage = 0;
  static const int _pokemonsPerPage = 20; // Aumentado a 20 para cargar más Pokémon inicialmente
  late SharedPreferences _prefs;
  Map<int, bool> _likes = {};
  Map<int, bool> _dislikes = {};
  Map<int, int> _totalBattles = {};
  Map<int, int> _wins = {};
  Map<int, int> _losses = {};
   Map<int, double> _ratings = {};

  List<Pokemon> get allPokemon => _allPokemon;
  Map<int, int> get battlePoints => _battlePoints;
  Map<int, int> get levels => _levels;
  bool get isLoading => _isLoading;
  Map<int, bool> get likes => _likes;
  Map<int, bool> get dislikes => _dislikes;
  Map<int, double> get ratings => _ratings;
  

  PokemonProvider() {
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSavedData();
    await fetchAllPokemon(); // Cambiado para cargar todos los Pokémon al inicio
  }

  Future<void> _loadSavedData() async {
    final battlePointsJson = _prefs.getString('battlePoints');
    final levelsJson = _prefs.getString('levels');
    final likesJson = _prefs.getString('likes');
    final dislikesJson = _prefs.getString('dislikes');
    final totalBattlesJson = _prefs.getString('totalBattles');
    final winsJson = _prefs.getString('wins');
    final lossesJson = _prefs.getString('losses');

    if (battlePointsJson != null) {
      final Map<String, dynamic> decodedBattlePoints = json.decode(battlePointsJson);
      _battlePoints = decodedBattlePoints.map((key, value) => MapEntry(int.parse(key), value as int));
    }

    if (levelsJson != null) {
      final Map<String, dynamic> decodedLevels = json.decode(levelsJson);
      _levels = decodedLevels.map((key, value) => MapEntry(int.parse(key), value as int));
    }

     if (likesJson != null) {
      final Map<String, dynamic> decodedLikes = json.decode(likesJson);
      _likes = decodedLikes.map((key, value) => MapEntry(int.parse(key), value as bool));
    }

    if (dislikesJson != null) {
      final Map<String, dynamic> decodedDislikes = json.decode(dislikesJson);
      _dislikes = decodedDislikes.map((key, value) => MapEntry(int.parse(key), value as bool));
    }

    if (totalBattlesJson != null) {
      final Map<String, dynamic> decodedTotalBattles = json.decode(totalBattlesJson);
      _totalBattles = decodedTotalBattles.map((key, value) => MapEntry(int.parse(key), value as int));
    }

    if (winsJson != null) {
      final Map<String, dynamic> decodedWins = json.decode(winsJson);
      _wins = decodedWins.map((key, value) => MapEntry(int.parse(key), value as int));
    }

    if (lossesJson != null) {
      final Map<String, dynamic> decodedLosses = json.decode(lossesJson);
      _losses = decodedLosses.map((key, value) => MapEntry(int.parse(key), value as int));
    }

    final ratingsJson = _prefs.getString('ratings');
    if (ratingsJson != null) {
      final Map<String, dynamic> decodedRatings = json.decode(ratingsJson);
      _ratings = decodedRatings.map((key, value) => MapEntry(int.parse(key), (value as num).toDouble()));
    }
  }

  Future<void> _saveData() async {
    try {
      final battlePointsJson = json.encode(_battlePoints.map((key, value) => MapEntry(key.toString(), value)));
      final levelsJson = json.encode(_levels.map((key, value) => MapEntry(key.toString(), value)));

      final likesJson = json.encode(_likes.map((key, value) => MapEntry(key.toString(), value)));
      final dislikesJson = json.encode(_dislikes.map((key, value) => MapEntry(key.toString(), value)));
      final totalBattlesJson = json.encode(_totalBattles.map((key, value) => MapEntry(key.toString(), value)));
      final winsJson = json.encode(_wins.map((key, value) => MapEntry(key.toString(), value)));
      final lossesJson = json.encode(_losses.map((key, value) => MapEntry(key.toString(), value)));

      await _prefs.setString('battlePoints', battlePointsJson);
      await _prefs.setString('levels', levelsJson);
      await _prefs.setString('likes', likesJson);
      await _prefs.setString('dislikes', dislikesJson);
      await _prefs.setString('totalBattles', totalBattlesJson);
      await _prefs.setString('wins', winsJson);
      await _prefs.setString('losses', lossesJson);
      await _prefs.setString('ratings', json.encode(_ratings));

    } catch (e) {
      print('Error saving data: $e');
    }
  }

 void updateRating(int pokemonId, double rating) {
    _ratings[pokemonId] = rating;
    _saveData();
    notifyListeners();
  }

  Future<void> fetchAllPokemon() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      while (_allPokemon.length < 151) { // Asegurarse de cargar todos los 151 Pokémon
        await fetchNextPage();
      }
      print('Todos los Pokémon cargados. Total: ${_allPokemon.length}');
    } catch (e) {
      print('Error fetching all Pokemon: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    final offset = _currentPage * _pokemonsPerPage;
    final cachedData = _prefs.getString('pokemon_page_$_currentPage');

    if (cachedData != null) {
      _processCachedData(cachedData);
    } else {
      await _fetchFromApi(offset);
    }

    _currentPage++;
  }

  void _processCachedData(String cachedData) {
    final List<dynamic> pokemonList = json.decode(cachedData);
    for (var pokemonData in pokemonList) {
      final pokemon = Pokemon.fromJson(pokemonData);
      _addPokemon(pokemon);
    }
  }

  Future<void> _fetchFromApi(int offset) async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=$_pokemonsPerPage')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      List<Map<String, dynamic>> pokemonDetailsToCache = [];

      for (var pokemonData in results) {
        final pokemonResponse = await http.get(Uri.parse(pokemonData['url']));
        if (pokemonResponse.statusCode == 200) {
          final pokemonDetails = json.decode(pokemonResponse.body);
          pokemonDetailsToCache.add(pokemonDetails);
          final pokemon = Pokemon.fromJson(pokemonDetails);
          _addPokemon(pokemon);
        }
      }

      // Cache the fetched data
      _prefs.setString('pokemon_page_$_currentPage', json.encode(pokemonDetailsToCache));
    } else {
      throw Exception('Failed to load pokemon');
    }
  }

  void _addPokemon(Pokemon pokemon) {
    if (!_allPokemon.any((p) => p.id == pokemon.id)) {
      _allPokemon.add(pokemon);
      _battlePoints[pokemon.id] = _battlePoints[pokemon.id] ?? 100;
      _levels[pokemon.id] = _levels[pokemon.id] ?? 1;
      print('Añadido Pokémon con ID: ${pokemon.id}');
    }
  }

  void updateBattlePoints(int pokemonId, int points) {
    if (_battlePoints.containsKey(pokemonId)) {
      _battlePoints[pokemonId] = (_battlePoints[pokemonId] ?? 0) + points;
      _updateLevel(pokemonId);
      _saveData();
      notifyListeners();
    }
  }

  void _updateLevel(int pokemonId) {
    if (_battlePoints.containsKey(pokemonId)) {
      int points = _battlePoints[pokemonId] ?? 0;
      _levels[pokemonId] = (points / 100).floor() + 1;
    }
  }

  void transferPoints(int weakenedPokemonId, Map<int, int> pointsToTransfer) {
    pointsToTransfer.forEach((donorId, points) {
      _battlePoints[donorId] = (_battlePoints[donorId] ?? 0) - points;
      _battlePoints[weakenedPokemonId] = (_battlePoints[weakenedPokemonId] ?? 0) + points;
      _updateLevel(donorId);
      _updateLevel(weakenedPokemonId);
    });
    _saveData();
    notifyListeners();
  }

  List<Pokemon> getRankedPokemon() {
    List<Pokemon> rankedPokemon = List.from(_allPokemon);
    rankedPokemon.sort((a, b) => (_battlePoints[b.id] ?? 0).compareTo(_battlePoints[a.id] ?? 0));
    return rankedPokemon;
  }

  Pokemon? getPokemonById(int id) {
    try {
      return _allPokemon.firstWhere((pokemon) => pokemon.id == id);
    } catch (e) {
      print('Pokemon with id $id not found. Total Pokémon: ${_allPokemon.length}');
      return null;
    }
  }

  void resetBattlePoints(int pokemonId) {
    if (_battlePoints.containsKey(pokemonId)) {
      _battlePoints[pokemonId] = 100; // Cambiado a 100 puntos al resetear
      _levels[pokemonId] = 1;
      _saveData();
      notifyListeners();
    }
  }

  Future<void> refreshPokemonData(int pokemonId) async {
    try {
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonId'));
      if (response.statusCode == 200) {
        final pokemonData = json.decode(response.body);
        final updatedPokemon = Pokemon.fromJson(pokemonData);
        final index = _allPokemon.indexWhere((p) => p.id == pokemonId);
        if (index != -1) {
          _allPokemon[index] = updatedPokemon;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error refreshing Pokemon data: $e');
    }
  }

  Future<void> fetchPokemonDetails(Pokemon pokemon) async {
    try {
      final speciesResponse = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/${pokemon.id}'));
      if (speciesResponse.statusCode == 200) {
        final speciesData = json.decode(speciesResponse.body);
        final englishDescription = speciesData['flavor_text_entries']
            .firstWhere((entry) => entry['language']['name'] == 'en')['flavor_text'];

        final abilitiesResponse = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${pokemon.id}'));
        if (abilitiesResponse.statusCode == 200) {
          final abilitiesData = json.decode(abilitiesResponse.body);
          final abilities = (abilitiesData['abilities'] as List)
              .map((ability) => ability['ability']['name'] as String)
              .toList();

          pokemon.updateDetails(englishDescription, abilities);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching Pokemon details: $e');
    }
  }

  void toggleLike(int pokemonId) {
    if (_dislikes[pokemonId] == true) {
      _dislikes[pokemonId] = false;
    }
    _likes[pokemonId] = !(_likes[pokemonId] ?? false);
    _saveData();
    notifyListeners();
  }

  void toggleDislike(int pokemonId) {
    if (_likes[pokemonId] == true) {
      _likes[pokemonId] = false;
    }
    _dislikes[pokemonId] = !(_dislikes[pokemonId] ?? false);
    _saveData();
    notifyListeners();
  }

  void updateBattleStatistics(int pokemonId, bool won) {
    _totalBattles[pokemonId] = (_totalBattles[pokemonId] ?? 0) + 1;
    if (won) {
      _wins[pokemonId] = (_wins[pokemonId] ?? 0) + 1;
    } else {
      _losses[pokemonId] = (_losses[pokemonId] ?? 0) + 1;
    }
    _saveData();
    notifyListeners();
  }

  int getTotalBattles(int pokemonId) => _totalBattles[pokemonId] ?? 0;
  int getWins(int pokemonId) => _wins[pokemonId] ?? 0;
  int getLosses(int pokemonId) => _losses[pokemonId] ?? 0;

  Future<void> resetAllData() async {
  _isLoading = true;
  notifyListeners();

  try {
    // Clear all data
    _battlePoints.clear();
    _levels.clear();
    _totalBattles.clear();
    _wins.clear();
    _losses.clear();
    _likes.clear();
    _dislikes.clear();

    // Initialize default values for all Pokemon
    for (var pokemon in _allPokemon) {
      _battlePoints[pokemon.id] = 100;
      _levels[pokemon.id] = 1;
    }

    // Save the reset state
    await _saveData();
    
    // Small delay to ensure UI updates are visible
    await Future.delayed(Duration(milliseconds: 500));
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

double calculatePokemonRating(Pokemon pokemon) {
    // Base the rating on the pokemon's stats and abilities
    double rating = 0.0;
    
    // Factor in power (base_experience)
    double powerRating = (pokemon.power / 200.0) * 5; // Assuming max power is around 200
    
    // Factor in number of abilities
    double abilitiesRating = (pokemon.abilities.length / 3.0) * 5; // Assuming max abilities is 3
    
    // Factor in types (dual-type Pokémon get a bonus)
    double typeRating = (pokemon.types.length / 2.0) * 5; // Max types is 2
    
    // Calculate average rating
    rating = (powerRating + abilitiesRating + typeRating) / 3.0;
    
    // Ensure rating is between 0 and 5
    return rating.clamp(0.0, 5.0);
  }
}