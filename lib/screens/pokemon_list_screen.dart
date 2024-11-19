import 'package:flutter/material.dart';
import 'package:poke-battle-legends/widgets/animated_pokemon_image.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../models/pokemon.dart';
import 'pokemon_detail_screen.dart';
import 'pokemon_ranking_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      Provider.of<PokemonProvider>(context, listen: false).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A0E4E), // Lila oscuro
      appBar: AppBar(
        backgroundColor: Color(0xFF4A0E4E), // Lila oscuro
        elevation: 0,
        title: Text(
          'Pokémon App',
          style: TextStyle(
            color: Color(0xFFFFD700), // Amarillo
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.leaderboard, color: Color(0xFFFFD700)), // Amarillo
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PokemonRankingScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, pokemonProvider, child) {
          final pokemons = pokemonProvider.allPokemon;
          
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            itemCount: pokemons.length + (pokemonProvider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == pokemons.length) {
                return Center(child: CircularProgressIndicator());
              }

              final pokemon = pokemons[index];
              final battlePoints = pokemonProvider.battlePoints[pokemon.id] ?? 0;
              final level = pokemonProvider.levels[pokemon.id] ?? 1;
              
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF6B1B72), // Lila suave más oscuro
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PokemonDetailScreen(pokemon: pokemon),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                             Center(
                              child: Hero(
                                tag: 'pokemon-${pokemon.id}',
                                child: AnimatedPokemonImage(
                                  imageUrl: pokemon.imageUrl,
                                  size: 80,
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFFD700), // Amarillo
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Nivel: $level',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white, // Amarillo
                                    ),
                                  ),
                                  Text(
                                    'Puntos: $battlePoints',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white, // Amarillo
                                    ),
                                  ),
                                  if (battlePoints <= 0)
                                    Text(
                                      'Debilitado!!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
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
                                ],
                              ),
                            ),
                            
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    pokemonProvider.likes[pokemon.id] == true 
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    color: Color(0xFFFFD700),
                                  ),
                                  onPressed: () => pokemonProvider.toggleLike(pokemon.id),
                                ),
                                IconButton(
                                  icon: Icon(
                                    pokemonProvider.dislikes[pokemon.id] == true 
                                        ? Icons.thumb_down
                                        : Icons.thumb_down_outlined,
                                    color: Color(0xFFFFD700),
                                  ),
                                  onPressed: () => pokemonProvider.toggleDislike(pokemon.id),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Color(0xFFFFD700), // Amarillo
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
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