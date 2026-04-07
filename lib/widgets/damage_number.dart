// widgets/damage_number.dart

import 'package:flutter/material.dart';

class DamageNumber extends StatefulWidget {
  final int damage;
  final bool
  isHeroReceiving; // Se é o herói tomando dano (vermelho) ou monstro (amarelo/branco)
  final VoidCallback onAnimationComplete;

  const DamageNumber({
    super.key,
    required this.damage,
    this.isHeroReceiving = false,
    required this.onAnimationComplete,
  });

  @override
  State<DamageNumber> createState() => _DamageNumberState();
}

class _DamageNumberState extends State<DamageNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // Duração da animação (rápida)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animação de Movimento (Sobe 30 pixels)
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Animação de Transparência (Começa visível, some no final)
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Inicia a animação e avisa quando acabar
    _controller.forward().then((_) => widget.onAnimationComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define a cor baseada em quem toma o dano
    Color damageColor = widget.isHeroReceiving
        ? Colors.redAccent
        : Colors.amberAccent;

    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Text(
          "-${widget.damage}",
          style: TextStyle(
            color: damageColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            // Sombra para destacar no fundo do bioma
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2)),
            ],
          ),
        ),
      ),
    );
  }
}
