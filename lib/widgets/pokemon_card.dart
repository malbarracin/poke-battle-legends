import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;

  const PokemonCard({Key? key, required this.pokemon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pokemonProvider = Provider.of<PokemonProvider>(context);
    final battlePoints = pokemonProvider.battlePoints[pokemon.id] ?? 0;
    final level = pokemonProvider.levels[pokemon.id] ?? 1;

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  pokemon.imageUrl,
                  height: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '#${pokemon.id} ${pokemon.name.toUpperCase()}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Tipos: ${pokemon.types.join(", ")}',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Nivel: $level (PB: $battlePoints)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Poder: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ...List.generate(5, (index) => Icon(
                    index < (pokemon.power / 20).round() ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}