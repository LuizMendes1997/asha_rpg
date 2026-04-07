import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../data/loot_table.dart';
import '../widgets/monster_arena.dart'; // Certifique-se de criar este widget como passei antes
import 'main_shell.dart';

class BattleScreen extends StatefulWidget {
  final HeroModel hero;
  final List<Monster> enemies;
  final String startMessage;
  final String backgroundImage; // <--- ADICIONE ESTA LINHA
  final VoidCallback onUpdate; // <--- ADICIONE ESTA LINHA
  const BattleScreen({
    super.key,
    required this.hero,
    required this.enemies,
    required this.startMessage,
    required this.backgroundImage,
    required this.onUpdate, // <--- ADICIONE ESTA LINHA TAMBÉM
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  String battleLog = "";
  late List<int> enemiesHP;
  int currentEnemyIndex = 0;

  @override
  void initState() {
    super.initState();
    enemiesHP = widget.enemies.map((e) => e.hp).toList().cast<int>();
    battleLog = widget.startMessage;
  }

  void _processTurn() {
    setState(() {
      // --- 1. TURNO DO HERÓI ---
      int damageToMonster = widget.hero.totalStr;
      // DISPARA A ANIMAÇÃO AQUI!
      _activeDamagesOnMonsters.add(
        MonsterDamageInfo(
          monsterIndex: currentEnemyIndex,
          damage: damageToMonster,
          key: UniqueKey(),
        ),
      );
      enemiesHP[currentEnemyIndex] -= damageToMonster;
      battleLog =
          "Você atacou o ${widget.enemies[currentEnemyIndex].name} e causou $damageToMonster de dano!";

      if (enemiesHP[currentEnemyIndex] <= 0) {
        battleLog +=
            "\nO ${widget.enemies[currentEnemyIndex].name} foi derrotado!";
        currentEnemyIndex++;
      }

      if (currentEnemyIndex >= widget.enemies.length) {
        _handleVictory();
        return;
      }

      // --- 2. TURNO DOS MONSTROS (TODOS OS VIVOS ATACAM!) ---
      int totalMonsterDamage = 0;
      for (int i = currentEnemyIndex; i < widget.enemies.length; i++) {
        if (enemiesHP[i] > 0) {
          totalMonsterDamage += widget.enemies[i].atk;
        }
      }

      widget.hero.hp -= totalMonsterDamage;
      battleLog +=
          "\nOs monstros revidaram! Você recebeu $totalMonsterDamage de dano.";

      if (widget.hero.hp <= 0) {
        _handleDefeat();
      }
    });
  }

  List<MonsterDamageInfo> _activeDamagesOnMonsters = [];

  // Função para remover o dano quando a animação acabar
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
      totalGold += 5;
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
            const Text(
              "Você limpou a área!",
              style: TextStyle(color: Colors.white70),
            ),
            const Divider(color: Colors.white24),
            Text(
              "💎 EXP: +$totalExp",
              style: const TextStyle(color: Colors.cyan),
            ),
            Text(
              "💰 Gold: +$totalGold",
              style: const TextStyle(color: Colors.amber),
            ),
            const SizedBox(height: 10),
            if (allLoot.isNotEmpty) ...[
              const Text(
                "🎒 ITENS:",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              const SizedBox(height: 5),
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
            },
            child: const Text("SAIR"),
          ),
        ],
      ),
    );
  }

  void _handleDefeat() {
    widget.hero.hp = 0;
    widget.hero.gold = (widget.hero.gold * 0.7).toInt();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("DERROTA", style: TextStyle(color: Colors.red)),
        content: const Text(
          "Você desmaiou e foi levado de volta...",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                widget.hero.hp = 0;
              });

              widget.onUpdate();

              // EM VEZ DE VillageScreen, USE A MainShell:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainShell(hero: widget.hero),
                ),
                (route) => false, // Limpa o rastro de telas
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
          // 1. FUNDO DA REGIÃO
          Positioned.fill(
            child: Image.asset(
              widget.backgroundImage,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // 2. INTERFACE DE COMBATE
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // TÍTULO/APPBAR MANUAL
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "COMBATE EM TEMPO REAL",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // ÁREA DOS MONSTROS (ARENA TÁTICA)
                  Expanded(
                    flex: 3,
                    child: MonsterArena(
                      enemies: widget.enemies,
                      enemiesHP: enemiesHP,
                      // ADICIONE ESTAS DUAS LINHAS:
                      pendingDamages: _activeDamagesOnMonsters,
                      onDamageAnimationComplete: _onDamageAnimationComplete,
                    ),
                  ),

                  // LOG DE MENSAGENS
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

                  // STATUS DO HERÓI E BOTÃO DE ATAQUE
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "HP: ${widget.hero.hp}",
                              style: TextStyle(
                                color: widget.hero.hp < 30
                                    ? Colors.red
                                    : Colors.greenAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[900],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
