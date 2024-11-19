import 'package:flutter/material.dart';

class AnimatedPokemonImage extends StatefulWidget {
  final String imageUrl;
  final double size;

  const AnimatedPokemonImage({
    Key? key,
    required this.imageUrl,
    this.size = 200,
  }) : super(key: key);

  @override
  State<AnimatedPokemonImage> createState() => _AnimatedPokemonImageState();
}

class _AnimatedPokemonImageState extends State<AnimatedPokemonImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 10)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 10, end: 0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => 
                Icon(Icons.catching_pokemon, size: widget.size, color: Color(0xFFFFD700)),
            ),
          ),
        );
      },
    );
  }
}