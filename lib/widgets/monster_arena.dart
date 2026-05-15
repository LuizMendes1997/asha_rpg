import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'damage_number.dart';

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

class MonsterArena extends StatelessWidget {
  final List<Monster> enemies;
  final List<int> enemiesHP;
  final List<MonsterDamageInfo> pendingDamages;
  final List<int> evadingMonsterIndices;
  final int? attackingMonsterIndex;
  final int? slashTargetIndex;
  final Function(Key) onDamageAnimationComplete;
  final bool showName;

  const MonsterArena({
    super.key,
    required this.enemies,
    required this.enemiesHP,
    required this.pendingDamages,
    this.evadingMonsterIndices =
        const [], // Agora opcional para não quebrar outras telas
    this.attackingMonsterIndex,
    this.slashTargetIndex,
    required this.onDamageAnimationComplete,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final arenaWidth = constraints.maxWidth;
        final arenaHeight = constraints.maxHeight;
        List<Widget> elements = [];

        for (int i = 0; i < enemies.length; i++) {
          final monster = enemies[i];
          final hpAtual = enemiesHP[i];
          final percentHP = (hpAtual / monster.hp).clamp(0.0, 1.0);
          double monsterSize = monster.isBoss ? 180 : 100;

          bool isEvading = evadingMonsterIndices.contains(i);
          bool isAttacking = attackingMonsterIndex == i;
          bool isBeingSlashed = slashTargetIndex == i;

          Offset posicao = _calcularPosicao(
            index: i,
            total: enemies.length,
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
                duration: const Duration(milliseconds: 500),
                opacity: hpAtual <= 0 ? 0.0 : 1.0,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 100),
                  padding: EdgeInsets.only(
                    left: isEvading ? 40 : 0,
                    top: isAttacking ? 20 : 0,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: monsterSize,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hpAtual > 0)
                              _buildHPBar(monsterSize, percentHP),
                            Image.asset(
                              monster.imagePath,
                              width: monsterSize,
                              height: monsterSize,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                            ),
                            if (showName)
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
                      if (isBeingSlashed)
                        Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: monsterSize * 0.7,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        for (var damageInfo in pendingDamages) {
          if (damageInfo.monsterIndex >= enemies.length) continue;
          final monster = enemies[damageInfo.monsterIndex];
          double monsterSize = monster.isBoss ? 180 : 100;
          Offset posicao = _calcularPosicao(
            index: damageInfo.monsterIndex,
            total: enemies.length,
            isBoss: monster.isBoss,
            arenaWidth: arenaWidth,
            arenaHeight: arenaHeight,
            monsterSize: monsterSize,
          );

          elements.add(
            Positioned(
              key: damageInfo.key,
              left: posicao.dx + (monsterSize / 2) - 20,
              top: posicao.dy - 20,
              child: DamageNumber(
                damage: damageInfo.damage,
                onAnimationComplete: () =>
                    onDamageAnimationComplete(damageInfo.key),
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
