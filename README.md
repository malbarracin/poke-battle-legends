# PokéBattle Legends

PokéBattle Legends es una aplicación interactiva de batallas Pokémon construida con Flutter. La app permite a los usuarios participar en batallas Pokémon, gestionar puntos de batalla y seguir el progreso de sus Pokémon a través de una interfaz intuitiva y atractiva.

## Características

- 🎮 Batallas Pokémon interactivas
- ⭐ Sistema de calificación basado en habilidades y poderes de los Pokémon
- 💪 Gestión de puntos de batalla
- 👍 Sistema de Me gusta/No me gusta para Pokémon
- 📊 Sistema de clasificación para estadísticas de batalla
- 🏆 Seguimiento de victorias/derrotas
- 🎨 Hermosa interfaz de usuario con animaciones

## Tecnologías Utilizadas

- Flutter 3.16.0
- Dart 3.2.0
- Gestión de estado con Provider
- SharedPreferences para almacenamiento local
- Paquete HTTP para integración de API
- Flutter Rating Bar 4.0.1

## Tecnologías Utilizadas

| Requisito | Versión Requerida |
|:-|:-|
| ![Flutter](https://img.shields.io/badge/Flutter-3.16.0-02569B?style=for-the-badge&logo=flutter&logoColor=white) | 3.16.0 o superior |
| ![Dart](https://img.shields.io/badge/Dart-3.2.0-0175C2?style=for-the-badge&logo=dart&logoColor=white) | 3.2.0 o superior |
| ![Provider](https://img.shields.io/badge/Provider-6.1.1-purple?style=for-the-badge) | Necesario para gestión de estado |
| ![SharedPreferences](https://img.shields.io/badge/SharedPreferences-required-blue?style=for-the-badge) | Necesario para almacenamiento local |
| ![HTTP](https://img.shields.io/badge/HTTP_package-required-green?style=for-the-badge) | Necesario para consumo de API |
| ![Rating Bar](https://img.shields.io/badge/Flutter_Rating_Bar-4.0.1-orange?style=for-the-badge) | Necesario para sistema de calificación |

## Primeros Pasos

1. Clona el repositorio:
   ```bash
   git clone https://github.com/malbarracin/poke-battle-legends.git
   ```

2. Navega al directorio del proyecto: 
   ```bash
   cd poke-battle-legends
   ```  

3. Instala las dependencias:
   ```bash
   flutter pub get
   ```  

4. Ejecuta la aplicación en modo de depuración:
   ```bash
   flutter run
   ```        

## Configuración de VS Code

1. Abre VS Code
2. Instala las siguientes extensiones:
1. Flutter
2. Dart
3. Flutter Widget Snippets (opcional)
3. Abre la paleta de comandos (Ctrl+Shift+P / Cmd+Shift+P)
4. Selecciona "Flutter: New Project"
5. Abre la carpeta del proyecto
6. Presiona F5 o selecciona "Run > Start Debugging" para lanzar la aplicación   

## Estructura del Proyecto
 ```bash
   lib/
├── models/
│   └── pokemon.dart
├── providers/
│   └── pokemon_provider.dart
├── screens/
│   ├── pokemon_detail_screen.dart
│   ├── pokemon_list_screen.dart
│   ├── pokemon_ranking_screen.dart
│   └── transfer_points_screen.dart
└── main.dart
   ``` 

## Ejecutar Pruebas

Para ejecutar las pruebas, ejecuta:
```bash
flutter test 
```  
## Compilar para Producción

Para compilar la versión de lanzamiento:
```bash
flutter build apk  # Para Android
flutter build ios  # Para iOS
```  

## Contribuir

1. Haz un fork del repositorio
2. Crea tu rama de características (`git checkout -b feature/CaracteristicaIncreible`)
3. Haz commit de tus cambios (`git commit -m 'Añadir alguna CaracteristicaIncreible'`)
4. Haz push a la rama (`git push origin feature/CaracteristicaIncreible`)
5. Abre un Pull Reques

## Agradecimientos

- PokéAPI por proporcionar datos de Pokémon
- El equipo de Flutter por el increíble framework
- La comunidad de código abierto por sus contribuciones

## ¿Te gusta el contenido que comparto? Invítame un café para ayudarme a seguir creando. ¡Gracias por tu apoyo!
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-F7DF1E?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/malbarracin) 