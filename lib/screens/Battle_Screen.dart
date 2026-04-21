import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../data/loot_table.dart';
import '../widgets/monster_arena.dart';
import 'main_shell.dart';

class BattleScreen extends StatefulWidget {
  final HeroModel hero;
  final List<Monster> enemies;
  final String startMessage;
  final String backgroundImage;
  final VoidCallback onUpdate;

  const BattleScreen({
    super.key,
    required this.hero,
    required this.enemies,
    required this.startMessage,
    required this.backgroundImage,
    required this.onUpdate,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  String battleLog = "";
  late List<int> enemiesHP;
  int currentEnemyIndex = 0;
  List<MonsterDamageInfo> _activeDamagesOnMonsters = [];

  @override
  void initState() {
    super.initState();
    enemiesHP = widget.enemies.map((e) => e.hp).toList().cast<int>();
    battleLog = widget.startMessage;
  }

  // --- MECÂNICA DE FUGA ---
  void _handleFlee() {
    // Penalidade: 30 de gold (ou o que ele tiver se for menos)
    int penalty = widget.hero.gold >= 30 ? 30 : widget.hero.gold;

    setState(() {
      widget.hero.gold -= penalty;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "FUGA!",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Você fugiu como um covarde... e no caminho deixou cair $penalty moedas de ouro!",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o dialog
              Navigator.pop(context); // Volta para o mapa
              widget.onUpdate();
            },
            child: const Text("VOLTAR"),
          ),
        ],
      ),
    );
  }

  void _processTurn() {
    setState(() {
      // --- 1. TURNO DO HERÓI ---
      int damageToMonster =
          widget.hero.totalStr - widget.enemies[currentEnemyIndex].def;
      if (damageToMonster < 1) damageToMonster = 1; // Dano mínimo

      _activeDamagesOnMonsters.add(
        MonsterDamageInfo(
          monsterIndex: currentEnemyIndex,
          damage: damageToMonster,
          key: UniqueKey(),
        ),
      );

      enemiesHP[currentEnemyIndex] -= damageToMonster;
      battleLog =
          "Você atacou ${widget.enemies[currentEnemyIndex].name} e causou $damageToMonster de dano!";

      if (enemiesHP[currentEnemyIndex] <= 0) {
        battleLog +=
            "\nO ${widget.enemies[currentEnemyIndex].name} foi derrotado!";
        currentEnemyIndex++;
      }

      // Verifica vitória antes do contra-ataque
      if (currentEnemyIndex >= widget.enemies.length) {
        _handleVictory();
        return;
      }

      // --- 2. TURNO DOS MONSTROS ---
      int rawMonsterDamage = 0;
      for (int i = currentEnemyIndex; i < widget.enemies.length; i++) {
        if (enemiesHP[i] > 0) {
          rawMonsterDamage += widget.enemies[i].atk;
        }
      }

      int effectiveDamage = (rawMonsterDamage - widget.hero.totalDef);
      if (effectiveDamage < 2) effectiveDamage = 2; // Dano mínimo dos monstros

      widget.hero.hp -= effectiveDamage;
      battleLog +=
          "\nOs monstros revidaram! Você recebeu $effectiveDamage de dano.";

      if (widget.hero.hp <= 0) {
        _handleDefeat();
      }
    });
  }

  void _onDamageAnimationComplete(Key damageKey) {
    if (!mounted) return;
    setState(() {
      _activeDamagesOnMonsters.removeWhere((info) => info.key == damageKey);
    });
  }

  void _handleVictory() {
    List<Item> allLoot = [];
    int totalExp = 0;
    int totalGold = 0;

    for (var m in widget.enemies) {
      allLoot.addAll(LootTable.getDrops(m.name));
      totalExp += m.expValue;
      totalGold += 5; // Gold base por monstro
    }

    widget.hero.gainExp(totalExp);
    widget.hero.gold += totalGold;
    for (var item in allLoot) {
      widget.hero.addItem(item);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "VITÓRIA!",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "💎 EXP: +$totalExp",
              style: const TextStyle(color: Colors.cyan),
            ),
            Text(
              "💰 Gold: +$totalGold",
              style: const TextStyle(color: Colors.amber),
            ),
            if (allLoot.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                "🎒 ITENS ENCONTRADOS:",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              Wrap(
                spacing: 5,
                children: allLoot
                    .map((i) => Image.asset(i.iconPath, width: 24, height: 24))
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              widget.onUpdate();
            },
            child: const Text("SAIR"),
          ),
        ],
      ),
    );
  }

  void _handleDefeat() {
    widget.hero.hp = 0;
    widget.hero.gold = (widget.hero.gold * 0.7)
        .toInt(); // Perde 30% do gold ao morrer
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("DERROTA", style: TextStyle(color: Colors.red)),
        content: const Text(
          "Você desmaiou e perdeu parte do seu ouro...",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onUpdate();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainShell(hero: widget.hero),
                ),
                (route) => false,
              );
            },
            child: const Text(
              "VOLTAR PARA A VILA",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool allDead = currentEnemyIndex >= widget.enemies.length;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.backgroundImage,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "COMBATE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.orangeAccent,
                        ),
                        onPressed: allDead
                            ? () => Navigator.pop(context)
                            : _handleFlee,
                      ),
                    ],
                  ),
                  Expanded(
                    flex: 3,
                    child: MonsterArena(
                      enemies: widget.enemies,
                      enemiesHP: enemiesHP,
                      pendingDamages: _activeDamagesOnMonsters,
                      onDamageAnimationComplete: _onDamageAnimationComplete,
                    ),
                  ),
                  Container(
                    height: 80,
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        battleLog,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900]?.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.hero.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "HP: ${widget.hero.hp}",
                              style: TextStyle(
                                color: widget.hero.hp < 20
                                    ? Colors.red
                                    : Colors.greenAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (!allDead)
                              TextButton(
                                onPressed: _handleFlee,
                                child: const Text(
                                  "FUGIR (-30G)",
                                  style: TextStyle(color: Colors.orangeAccent),
                                ),
                              ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[900],
                              ),
                              onPressed: allDead ? null : _processTurn,
                              child: const Text(
                                "ATACAR",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
