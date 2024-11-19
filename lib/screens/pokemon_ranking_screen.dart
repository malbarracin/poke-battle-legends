import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:poke-battle-legends/widgets/animated_pokemon_image.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../models/pokemon.dart';

class PokemonRankingScreen extends StatelessWidget {
  Future<void> _showResetConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF4A0E4E),
          title: Text(
            '¿Reiniciar Ranking?',
            style: TextStyle(color: Color(0xFFFFD700)),
          ),
          content: Text(
            '¿Estás seguro de que deseas reiniciar todos los datos? Esta acción no se puede deshacer.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Color(0xFFFFD700))),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Reiniciar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ).then((confirmed) async {
      if (confirmed == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                backgroundColor: Color(0xFF4A0E4E),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Reiniciando datos...',
                      style: TextStyle(color: Color(0xFFFFD700)),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        await Provider.of<PokemonProvider>(context, listen: false).resetAllData();
        Navigator.of(context).pop();
      }
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
          'Ranking de Pokémon',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFFFFD700)),
            onPressed: () => _showResetConfirmationDialog(context),
          ),
        ],
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, pokemonProvider, child) {
          if (pokemonProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
            );
          }

          final rankedPokemon = pokemonProvider.getRankedPokemon().where((pokemon) {
            final points = pokemonProvider.battlePoints[pokemon.id] ?? 0;
            return points != 100;
          }).toList();
          
          if (rankedPokemon.isEmpty) {
            return Center(
              child: Text(
                'No hay datos de batalla disponibles',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 18,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: rankedPokemon.length,
            itemBuilder: (context, index) {
              final pokemon = rankedPokemon[index];
              final battlePoints = pokemonProvider.battlePoints[pokemon.id] ?? 0;
              final level = pokemonProvider.levels[pokemon.id] ?? 1;
              final totalBattles = pokemonProvider.getTotalBattles(pokemon.id);
              final wins = pokemonProvider.getWins(pokemon.id);
              final losses = pokemonProvider.getLosses(pokemon.id);
              
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF6B1B72),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                     
                       Center(
                        child: Hero(
                          tag: 'pokemon-${pokemon.id}',
                          child: AnimatedPokemonImage(
                            imageUrl: pokemon.imageUrl,
                            size: 120,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pokemon.name.toUpperCase(),
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Nivel: $level',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Batallas: $totalBattles (G: $wins, P: $losses)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            RatingBar.builder(
                                        initialRating: pokemonProvider.calculatePokemonRating(pokemon),
                                        minRating: 0,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 20,
                                        ignoreGestures: true, // Make it read-only
                                        unratedColor: Colors.amber.withOpacity(0.3),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Color(0xFFFFD700),
                                        ),
                                        onRatingUpdate: (rating) {
                                          // This won't be called since ignoreGestures is true
                                        },
                                      ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(
                                    pokemonProvider.likes[pokemon.id] == true 
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    color: Color(0xFFFFD700),
                                    size: 20,
                                  ),
                                  onPressed: () => pokemonProvider.toggleLike(pokemon.id),
                                ),
                                SizedBox(width: 16),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(
                                    pokemonProvider.dislikes[pokemon.id] == true 
                                        ? Icons.thumb_down
                                        : Icons.thumb_down_outlined,
                                    color: Color(0xFFFFD700),
                                    size: 20,
                                  ),
                                  onPressed: () => pokemonProvider.toggleDislike(pokemon.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Puntos:',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$battlePoints',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}