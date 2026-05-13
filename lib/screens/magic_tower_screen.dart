import 'dart:math';
import 'package:asha_rpg/data/item_data.dart';
import 'package:flutter/material.dart';
import 'package:asha_rpg/models/game_state.dart';
import 'package:asha_rpg/widgets/monster_arena.dart';
import 'main_shell.dart';

class MagicTowerScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const MagicTowerScreen({
    super.key,
    required this.hero,
    required this.onUpdate,
  });

  @override
  State<MagicTowerScreen> createState() => _MagicTowerScreenState();
}

class _MagicTowerScreenState extends State<MagicTowerScreen> {
  late int currentFloor;
  int totalGoldEarned = 0;
  String battleLog = "";
  bool _isProcessing = false;

  late List<int> enemiesHP;
  late List<Monster> currentEnemies;
  List<MonsterDamageInfo> _activeDamagesOnMonsters = [];

  @override
  void initState() {
    super.initState();
    currentFloor = widget.hero.maxTowerFloor + 1;
    battleLog = "Você entrou no $currentFloorº Andar da Torre Mágica...";
    _spawnFloorMonster();
  }

  void _spawnFloorMonster() {
    double scale = pow(1.12, currentFloor - 1).toDouble();
    int hpBase = 40;
    int atkBase = 7;
    int defBase = 2;

    Monster monstro = Monster(
      name: _getMonsterName(currentFloor),
      hp: (hpBase * scale).toInt() + (currentFloor * 5),
      atk: (atkBase * scale).toInt() + 2,
      def: (defBase * (1 + currentFloor * 0.1)).toInt(),
      expValue: (10 * scale).toInt() + currentFloor,
      imagePath: _getMonsterImage(currentFloor),
      isBoss: currentFloor % 5 == 0,
    );

    setState(() {
      currentEnemies = [monstro];
      enemiesHP = [monstro.hp];
      _activeDamagesOnMonsters = [];
    });
  }

  String _getMonsterName(int floor) {
    if (floor % 5 == 0) return "Guardião Ancestral";
    if (floor > 10) return "Sentinela de Éter";
    return "Olho Arcano";
  }

  String _getMonsterImage(int floor) {
    if (floor % 5 == 0) return 'assets/monsters/boss_golem.webp';
    if (floor > 10) return 'assets/monsters/spectral_armor.webp';
    return 'assets/monsters/eye_watcher.webp';
  }

  void _processTurn() async {
    if (_isProcessing || enemiesHP[0] <= 0 || widget.hero.hp <= 0) return;
    setState(() => _isProcessing = true);

    setState(() {
      int damageToMonster = (widget.hero.totalStr - currentEnemies[0].def)
          .clamp(1, 9999);
      _activeDamagesOnMonsters.add(
        MonsterDamageInfo(
          monsterIndex: 0,
          damage: damageToMonster,
          key: UniqueKey(),
        ),
      );
      enemiesHP[0] -= damageToMonster;

      if (enemiesHP[0] <= 0) {
        Future.delayed(
          const Duration(milliseconds: 600),
          () => _handleFloorVictory(),
        );
        return;
      }

      int effectiveDamage = (currentEnemies[0].atk - widget.hero.totalDef)
          .clamp(2, 9999);
      widget.hero.hp -= effectiveDamage;
      battleLog = "Recebeu $effectiveDamage de dano!";

      if (widget.hero.hp <= 0) {
        Future.delayed(
          const Duration(milliseconds: 600),
          () => _handleDefeat(),
        );
      }
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _isProcessing = false);
  }

  void _handleFloorVictory() {
    int floorGold = 10 + (currentFloor * 3);
    totalGoldEarned += floorGold;
    widget.hero.gold += floorGold;
    String lootMessage = "";

    if (currentFloor > widget.hero.maxTowerFloor)
      widget.hero.maxTowerFloor = currentFloor;

    if (currentFloor % 5 == 0) {
      final reward = ItemData.espadacomum.copy();
      widget.hero.addItem(reward);
      lootMessage = "\n✨ ITEM: ${reward.name}";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "ANDAR $currentFloor",
          style: const TextStyle(color: Colors.cyanAccent),
        ),
        content: Text(
          "+$floorGold Ouro$lootMessage\n\nTotal: $totalGoldEarned",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              widget.onUpdate();
              widget.hero.saveToSupabase();
            },
            child: const Text("SAIR", style: TextStyle(color: Colors.amber)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.hero.saveToSupabase();
              setState(() {
                currentFloor++;
                _spawnFloorMonster();
              });
            },
            child: const Text("SUBIR"),
          ),
        ],
      ),
    );
  }

  void _handleDefeat() {
    widget.hero.hp = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("DERROTA", style: TextStyle(color: Colors.red)),
        content: Text("Perdeu $totalGoldEarned ouro acumulado."),
        actions: [
          ElevatedButton(
            onPressed: () {
              widget.hero.gold -= totalGoldEarned;
              widget.onUpdate();
              widget.hero.saveToSupabase();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainShell(hero: widget.hero),
                ),
                (route) => false,
              );
            },
            child: const Text("VILA"),
          ),
        ],
      ),
    );
  }

  void _onDamageAnimationComplete(Key damageKey) {
    if (!mounted) return;
    setState(
      () =>
          _activeDamagesOnMonsters.removeWhere((info) => info.key == damageKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/torre.webp", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // --- NOME DO MONSTRO (APENAS AQUI NO TOPO) ---
                      Positioned(
                        top: 10,
                        child: Column(
                          children: [
                            Text(
                              currentEnemies[0].name.toUpperCase(),
                              style: TextStyle(
                                color: currentEnemies[0].isBoss
                                    ? Colors.redAccent
                                    : Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                shadows: [
                                  const Shadow(
                                    blurRadius: 15,
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                  ),
                                  Shadow(
                                    blurRadius: 10,
                                    color: currentEnemies[0].isBoss
                                        ? Colors.red
                                        : Colors.cyan,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "LVL $currentFloor",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- MONSTRO (LIMPO, SEM NOME EMBAIXO) ---
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Transform.scale(
                            scale: 2.5, // Seu scale de preferência
                            child: MonsterArena(
                              // Se o seu MonsterArena tiver a opção de ocultar o nome, use-a.
                              // Caso contrário, o nome que eu coloquei acima será o destaque.
                              enemies: currentEnemies,
                              enemiesHP: enemiesHP,
                              pendingDamages: _activeDamagesOnMonsters,
                              onDamageAnimationComplete:
                                  _onDamageAnimationComplete,
                              showName: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildLog(),
                _buildAttackButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderInfo("F$currentFloor", Colors.cyan),
          _buildHeaderInfo("HP: ${widget.hero.hp}", Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLog() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        battleLog,
        style: const TextStyle(color: Colors.white60, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAttackButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isProcessing ? Colors.grey[800] : Colors.red[900],
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 10,
        ),
        onPressed: _processTurn,
        child: Text(
          _isProcessing ? "CONJURANDO..." : "ATAQUE MÁGICO",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
