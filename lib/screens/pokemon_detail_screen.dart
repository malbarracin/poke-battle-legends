import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import 'transfer_points_screen.dart';
import '../widgets/animated_pokemon_image.dart';

class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({Key? key, required this.pokemon}) : super(key: key);

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Pokemon _currentPokemon;
  bool _isBattling = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentPokemon = widget.pokemon;
    _fetchPokemonDetails();
  }

  Future<void> _fetchPokemonDetails() async {
    final pokemonProvider = Provider.of<PokemonProvider>(context, listen: false);
    await pokemonProvider.fetchPokemonDetails(_currentPokemon);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A0E4E),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A0E4E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentPokemon.name.toUpperCase(),
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, pokemonProvider, child) {
          final currentPoints = pokemonProvider.battlePoints[_currentPokemon.id] ?? 0;
          final currentLevel = pokemonProvider.levels[_currentPokemon.id] ?? 0;
          
          return _isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Hero(
                              tag: 'pokemon-${_currentPokemon.id}',
                              child: AnimatedPokemonImage(
                                imageUrl: _currentPokemon.imageUrl,
                                size: 200,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  pokemonProvider.likes[_currentPokemon.id] == true 
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  color: Color(0xFFFFD700),
                                ),
                                onPressed: () => pokemonProvider.toggleLike(_currentPokemon.id),
                              ),
                              IconButton(
                                icon: Icon(
                                  pokemonProvider.dislikes[_currentPokemon.id] == true 
                                      ? Icons.thumb_down
                                      : Icons.thumb_down_outlined,
                                  color: Color(0xFFFFD700),
                                ),
                                onPressed: () => pokemonProvider.toggleDislike(_currentPokemon.id),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Color(0xFFAA77DD),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Nivel: $currentLevel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                                Text(
                                  'Puntos de Batalla: $currentPoints',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Descripción',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                                  ),
                                  SizedBox(height: 4),

                                  // Aquí hacemos que el texto ocupe todo el espacio
                                  Container(
                                    width: double.infinity,  // Asegura que ocupe todo el ancho disponible
                                    child: Text(
                                      _currentPokemon.description,
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                      textAlign: TextAlign.justify,  // Justificado para que ocupe el espacio de manera ordenada
                                      overflow: TextOverflow.visible, // Para evitar que el texto se corte
                                    ),
                                  ),

                                  SizedBox(height: 4),
                                  Text(
                                    'Habilidades',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                                  ),
                                  SizedBox(height: 4),
                                  ..._currentPokemon.abilities.map((ability) => 
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text('• $ability', style: TextStyle(fontSize: 14, color: Colors.white)),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Estadísticas',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                                  ),
                                  SizedBox(height: 4),
                                  _buildStatRow('Tipos', _currentPokemon.types.join(", ")),
                                  _buildStatRow('Altura', '${_currentPokemon.height / 10} m'),
                                  _buildStatRow('Peso', '${_currentPokemon.weight / 10} kg'),
                                  _buildStatRow('Poder', '${_currentPokemon.power}'),
                                ],
                              ),
                            ),

                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (currentPoints <= 0)
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransferPointsScreen(
                                    weakenedPokemon: _currentPokemon,
                                  ),
                                ),
                              );
                              if (result == true) {
                                setState(() {
                                  _isBattling = false;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFD700),
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'Transferir Puntos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        if (currentPoints <= 0)
                          SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: (currentPoints <= 0 || _isBattling) ? null : () => _startBattleSequence(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFD700),
                            disabledBackgroundColor: Colors.grey[400],
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Iniciar Batalla',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  void _startBattleSequence() async {
    setState(() {
      _isBattling = true;
    });
    await _startRandomBattle();
    setState(() {
      _isBattling = false;
    });
  }

  Future<void> _startRandomBattle() async {
    final random = Random();
    final playerPower = _currentPokemon.power;
    final minEnemyPower = (playerPower * 0.8).round();
    final maxEnemyPower = (playerPower * 1.2).round();

    try {
      int attempts = 0;
      Pokemon? enemyPokemon;
      
      while (attempts < 5 && enemyPokemon == null) {
        final enemyId = random.nextInt(151) + 1;
        final pokemonProvider = Provider.of<PokemonProvider>(context, listen: false);
        enemyPokemon = pokemonProvider.getPokemonById(enemyId);
        
        if (enemyPokemon != null && 
            (enemyPokemon.power < minEnemyPower || enemyPokemon.power > maxEnemyPower)) {
          enemyPokemon = null;
        }
        
        attempts++;
      }
      
      if (enemyPokemon == null) {
        final enemyId = random.nextInt(151) + 1;
        final pokemonProvider = Provider.of<PokemonProvider>(context, listen: false);
        enemyPokemon = pokemonProvider.getPokemonById(enemyId);
      }

      if (enemyPokemon != null) {
        final bool won = _calculateBattleResult(
          _currentPokemon.power,
          enemyPokemon.power,
          _currentPokemon.types.first,
          enemyPokemon.types.first
        );

        final pokemonProvider = Provider.of<PokemonProvider>(context, listen: false);
        int pointsChange = won ? 10 : -10;
        
        pokemonProvider.updateBattlePoints(_currentPokemon.id, pointsChange);

        pokemonProvider.updateBattleStatistics(_currentPokemon.id, won);
        int currentPoints = pokemonProvider.battlePoints[_currentPokemon.id] ?? 0;
        
        bool isFainted = currentPoints <= 0;
        await _showBattleResult(won, enemyPokemon, pointsChange.abs(), isFainted);
        
        if (isFainted) {
          setState(() {
            _isBattling = false;
          });
        }
      }
    } catch (e) {
      print('Error en la batalla: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar la batalla. Intenta de nuevo.')),
      );
    }
  }

  bool _calculateBattleResult(int playerPower, int enemyPower, String playerType, String enemyType) {
    final pokemonProvider = Provider.of<PokemonProvider>(context, listen: false);
    final playerLevel = pokemonProvider.levels[_currentPokemon.id] ?? 1;

    double effectiveness = getTypeEffectiveness(playerType, enemyType);
    double levelBonus = playerLevel * 5.0;
    double playerTotalPower = (playerPower + levelBonus) * effectiveness;

    final random = Random();
    double randomFactor = 0.9 + (random.nextDouble() * 0.2);
    playerTotalPower *= randomFactor;

    return playerTotalPower > enemyPower;
  }

  Future<void> _showBattleResult(bool won, Pokemon enemyPokemon, int pointsChange, bool isFainted) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(won ? '¡Victoria!' : '¡Derrota!', style: TextStyle(fontSize: 24, color: Color(0xFFFFD700))),
          backgroundColor: Color(0xFF4A0E4E),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Center(
                        child: Hero(
                          tag: 'pokemon-${_currentPokemon.id}',
                          child: AnimatedPokemonImage(
                            imageUrl: _currentPokemon.imageUrl,
                            size: 100,
                          ),
                        ),
                      ),
                      Text(_currentPokemon.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                      Text('Poder: ${_currentPokemon.power}', style: TextStyle(color: Colors.white)),
                      Text('Tipo: ${_currentPokemon.types.first}', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Text('VS', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                  Column(
                    children: [
                      Center(
                        child: Hero(
                          tag: 'pokemon-${enemyPokemon.id}',
                          child: AnimatedPokemonImage(
                            imageUrl: enemyPokemon.imageUrl,
                            size: 100,
                          ),
                        ),
                      ),
                      Text(enemyPokemon.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                      Text('Poder: ${enemyPokemon.power}', style: TextStyle(color: Colors.white)),
                      Text('Tipo: ${enemyPokemon.types.first}', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                '¡Tu ${_currentPokemon.name} ${won ? 'ganó' : 'perdió'} la batalla!',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white)
              ),
              Text(
                '${won ? 'Ganaste' : 'Perdiste'} $pointsChange puntos de batalla.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white)
              ),
              if (isFainted)
                Text(
                  '¡Tu Pokémon se ha debilitado!',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          actions: [
             ElevatedButton(
                          onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {});  // Actualizar la pantalla para mostrar los puntos actualizados
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFD700),
                            disabledBackgroundColor: Colors.grey[400],
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),

          ],
        );
      },
    );
  }

  double getTypeEffectiveness(String attackerType, String defenderType) {
    final Map<String, Map<String, double>> typeChart = {
      'normal': {'rock': 0.5, 'ghost':0, 'steel':0.5},
      'fire': {'fire':0.5, 'water':0.5, 'grass':2, 'ice':2, 'bug':2, 'rock':0.5, 'dragon':0.5, 'steel':2},
      'water': {'fire':2, 'water':0.5, 'grass':0.5, 'ground':2, 'rock':2, 'dragon':0.5},
      'electric': {'water':2, 'electric':0.5, 'grass':0.5, 'ground':0, 'flying':2, 'dragon':0.5},
      'grass': {'fire':0.5, 'water':2, 'grass':0.5, 'poison':0.5, 'ground':2, 'flying':0.5, 'bug':0.5, 'rock':2, 'dragon':0.5, 'steel':0.5},
      'ice': {'fire':0.5, 'water':0.5, 'grass':2, 'ice':0.5, 'ground':2, 'flying':2, 'dragon':2, 'steel':0.5},
      'fighting': {'normal':2, 'ice':2, 'poison':0.5, 'flying':0.5, 'psychic':0.5, 'bug':0.5, 'rock':2, 'ghost':0, 'dark':2, 'steel':2, 'fairy':0.5},
      'poison': {'grass':2, 'poison':0.5, 'ground':0.5, 'rock':0.5, 'ghost':0.5, 'steel':0, 'fairy':2},
      'ground': {'fire':2, 'electric':2, 'grass':0.5, 'poison':2, 'flying':0, 'bug':0.5, 'rock':2, 'steel':2},
      'flying': {'electric':0.5, 'grass':2, 'fighting':2, 'bug':2, 'rock':0.5, 'steel':0.5},
      'psychic': {'fighting':2, 'poison':2, 'psychic':0.5, 'dark':0, 'steel':0.5},
      'bug': {'fire':0.5, 'grass':2, 'fighting':0.5, 'poison':0.5, 'flying':0.5, 'psychic':2, 'ghost':0.5, 'dark':2, 'steel':0.5, 'fairy':0.5},
      'rock': {'fire':2, 'ice':2, 'fighting':0.5, 'ground':0.5, 'flying':2, 'bug':2, 'steel':0.5},
      'ghost': {'normal':0, 'psychic':2, 'ghost':2, 'dark':0.5},
      'dragon': {'dragon':2, 'steel':0.5, 'fairy':0},
      'dark': {'fighting':0.5, 'psychic':2, 'ghost':2, 'dark':0.5, 'fairy':0.5},
      'steel': {'fire':0.5, 'water':0.5, 'electric':0.5, 'ice':2, 'rock':2, 'steel':0.5, 'fairy':2},
      'fairy': {'fire':0.5, 'fighting':2, 'poison':0.5, 'dragon':2, 'dark':2, 'steel':0.5}
    };

    attackerType = attackerType.toLowerCase();
    defenderType = defenderType.toLowerCase();

    if (typeChart.containsKey(attackerType)) {
      if (typeChart[attackerType]!.containsKey(defenderType)) {
        return typeChart[attackerType]![defenderType]!;
      }
    }

    return 1.0;
  }
}