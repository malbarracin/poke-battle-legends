enum PokemonType {
  normal, fuego, agua, electrico, planta, hielo, lucha, veneno, tierra, volador,
  psiquico, bicho, roca, fantasma, dragon, siniestro, acero, hada
}

double getTypeEffectiveness(String attackType, String defenseType) {
  // Esta es una versión simplificada. En un juego real, tendrías una tabla de tipos más compleja.
  final typeChart = {
    'fuego': {'planta': 2.0, 'agua': 0.5},
    'agua': {'fuego': 2.0, 'planta': 0.5},
    'planta': {'agua': 2.0, 'fuego': 0.5},
    // Añade más relaciones de tipos aquí
  };

  if (typeChart[attackType]?.containsKey(defenseType) ?? false) {
    return typeChart[attackType]![defenseType]!;
  }

  return 1.0; // Efectividad neutral
}