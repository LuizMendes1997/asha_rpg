import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'damage_number.dart'; // Importe o widget de dano que criamos

class MonsterDamageInfo {
  final int monsterIndex;
  final int damage;
  final Key key;
  MonsterDamageInfo({
    required this.monsterIndex,
    required this.damage,
    required this.key,
  });
}

class MonsterArena extends StatefulWidget {
  final List<Monster> enemies;
  final List<int> enemiesHP;
  final List<MonsterDamageInfo> pendingDamages;
  final Function(Key) onDamageAnimationComplete;

  const MonsterArena({
    super.key,
    required this.enemies,
    required this.enemiesHP,
    required this.pendingDamages,
    required this.onDamageAnimationComplete,
  });

  @override
  State<MonsterArena> createState() => _MonsterArenaState();
}

class _MonsterArenaState extends State<MonsterArena> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final arenaWidth = constraints.maxWidth;
        final arenaHeight = constraints.maxHeight;

        List<Widget> elements = [];

        // 1. RENDERIZA OS MONSTROS
        for (int i = 0; i < widget.enemies.length; i++) {
          final monster = widget.enemies[i];
          final hpAtual = widget.enemiesHP[i];
          final percentHP = (hpAtual / monster.hp).clamp(0.0, 1.0);
          double monsterSize = monster.isBoss ? 180 : 100;

          Offset posicao = _calcularPosicao(
            index: i,
            total: widget.enemies.length,
            isBoss: monster.isBoss,
            arenaWidth: arenaWidth,
            arenaHeight: arenaHeight,
            monsterSize: monsterSize,
          );

          elements.add(
            Positioned(
              left: posicao.dx,
              top: posicao.dy,
              child: AnimatedOpacity(
                // Transição suave quando morre
                duration: const Duration(milliseconds: 500),
                opacity: hpAtual <= 0 ? 0.0 : 1.0,
                child: SizedBox(
                  width: monsterSize,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hpAtual > 0) _buildHPBar(monsterSize, percentHP),
                      Image.asset(
                        monster.imagePath,
                        width: monsterSize,
                        height: monsterSize,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                      Text(
                        monster.name,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // 2. RENDERIZA OS DANOS FLUTUANTES (SISTEMA 4)
        for (var damageInfo in widget.pendingDamages) {
          if (damageInfo.monsterIndex >= widget.enemies.length) continue;

          final monster = widget.enemies[damageInfo.monsterIndex];
          double monsterSize = monster.isBoss ? 180 : 100;
          Offset posicao = _calcularPosicao(
            index: damageInfo.monsterIndex,
            total: widget.enemies.length,
            isBoss: monster.isBoss,
            arenaWidth: arenaWidth,
            arenaHeight: arenaHeight,
            monsterSize: monsterSize,
          );

          elements.add(
            Positioned(
              key: damageInfo.key,
              left: posicao.dx + (monsterSize / 2) - 20, // Centraliza o número
              top: posicao.dy - 20, // Aparece um pouco acima da cabeça
              child: DamageNumber(
                damage: damageInfo.damage,
                onAnimationComplete: () =>
                    widget.onDamageAnimationComplete(damageInfo.key),
              ),
            ),
          );
        }

        return Stack(children: elements);
      },
    );
  }

  Widget _buildHPBar(double monsterSize, double percentHP) {
    return Container(
      height: 4,
      width: monsterSize * 0.8,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentHP,
        child: Container(
          decoration: BoxDecoration(
            color: percentHP < 0.3 ? Colors.red : Colors.greenAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Offset _calcularPosicao({
    required int index,
    required int total,
    required bool isBoss,
    required double arenaWidth,
    required double arenaHeight,
    required double monsterSize,
  }) {
    double centerX = arenaWidth / 2 - (monsterSize / 2);
    double centerY = (arenaHeight * 0.65) - (monsterSize / 2);

    if (isBoss && total == 1) return Offset(centerX, centerY + 20);

    double hSpace = monsterSize * 0.8;
    double vSpace = 40;

    switch (total) {
      case 1:
        return Offset(centerX, centerY);
      case 2:
        return index == 0
            ? Offset(centerX - hSpace, centerY)
            : Offset(centerX + hSpace, centerY);
      case 3:
        if (index == 0) return Offset(centerX, centerY - vSpace);
        return index == 1
            ? Offset(centerX - hSpace, centerY + vSpace)
            : Offset(centerX + hSpace, centerY + vSpace);
      default:
        return Offset(centerX, centerY);
    }
  }
}
