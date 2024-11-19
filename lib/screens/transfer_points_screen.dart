import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';

class TransferPointsScreen extends StatefulWidget {
  final Pokemon weakenedPokemon;

  const TransferPointsScreen({Key? key, required this.weakenedPokemon}) : super(key: key);

  @override
  _TransferPointsScreenState createState() => _TransferPointsScreenState();
}

class _TransferPointsScreenState extends State<TransferPointsScreen> {
  Map<int, int> selectedPoints = {};
  int totalSelectedPoints = 0;
  bool _isConfirmEnabled = false;
  int requiredPoints = 10;

  @override
  void initState() {
    super.initState();
    selectedPoints = {};
    totalSelectedPoints = 0;
    requiredPoints = 10;
  }

  void _updateSelectedPoints() {
    setState(() {
      totalSelectedPoints = selectedPoints.values.fold(0, (sum, value) => sum + value);
      _isConfirmEnabled = totalSelectedPoints == 10;
    });
  }

  void _confirmTransfer() {
    if (totalSelectedPoints == 10) {
      final pokemonProvider = Provider.of<PokemonProvider>(context, listen: false);
      pokemonProvider.transferPoints(widget.weakenedPokemon.id, selectedPoints);
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona exactamente 10 puntos para transferir.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A0E4E),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A0E4E), // Lila oscuro
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Transferir Puntos de Batalla',  style: TextStyle(color: Color(0xFFFFD700))),
        elevation: 0,
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, pokemonProvider, child) {
          List<Pokemon> availablePokemon = pokemonProvider.allPokemon
              .where((pokemon) =>
                  pokemon.id != widget.weakenedPokemon.id &&
                  (pokemonProvider.battlePoints[pokemon.id] ?? 0) > 20)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.weakenedPokemon.name} necesita $requiredPoints puntos para recuperarse',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: availablePokemon.length,
                    itemBuilder: (context, index) {
                      Pokemon pokemon = availablePokemon[index];
                      int availablePoints = pokemonProvider.battlePoints[pokemon.id] ?? 0;
                      int selectedPointsForPokemon = selectedPoints[pokemon.id] ?? 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.network(
                                pokemon.imageUrl,
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.catching_pokemon, size: 80),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pokemon.name,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                                    ),
                                    Text(
                                      'Puntos disponibles: $availablePoints',
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: selectedPointsForPokemon.toDouble(),
                                  min: 0,
                                  max: availablePoints.toDouble(),
                                  divisions: availablePoints,
                                  activeColor: Color(0xFF8B5CF6),
                                  inactiveColor: Color(0xFFFFD700),
                                  onChanged: (double value) {
                                    setState(() {
                                      int newValue = value.round();
                                      int pointsDifference = newValue - (selectedPoints[pokemon.id] ?? 0);
                                      
                                      // Check if we can add these points
                                      if (totalSelectedPoints + pointsDifference <= requiredPoints) {
                                        selectedPoints[pokemon.id] = newValue;
                                        totalSelectedPoints += pointsDifference;
                                      }
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                '$selectedPointsForPokemon',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Puntos seleccionados: $totalSelectedPoints/$requiredPoints',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: totalSelectedPoints >= requiredPoints
                        ? () {
                            final pokemonProvider = Provider.of<PokemonProvider>(context, listen: false);
                            pokemonProvider.transferPoints(widget.weakenedPokemon.id, selectedPoints);
                            Navigator.of(context).pop(true);
                          }
                        : null,
                    child: Text(
                      'Confirmar Transferencia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A0E4E),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: totalSelectedPoints >= requiredPoints ? Color(0xFFFFD700) : Colors.grey[400],
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}