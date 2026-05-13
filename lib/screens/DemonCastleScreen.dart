import 'package:flutter/material.dart';
import 'package:asha_rpg/models/game_state.dart'; // O widget que faz os danos voarem
import 'main_shell.dart';
import '../widgets/monster_arena.dart';
import '../data/item_data.dart';

class DemonCastleScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const DemonCastleScreen({
    super.key,
    required this.hero,
    required this.onUpdate,
  });

  @override
  State<DemonCastleScreen> createState() => _DemonCastleScreenState();
}

class _DemonCastleScreenState extends State<DemonCastleScreen> {
  int currentRoom = 1;
  final int totalRooms = 7;
  String battleLog = "Você entrou no Castelo do Rei Demônio...";

  // Lógica de HP e Monstros igual ao seu BattleScreen
  late List<int> enemiesHP;
  late List<Monster> currentEnemies;
  List<MonsterDamageInfo> _activeDamagesOnMonsters = [];

  @override
  void initState() {
    super.initState();
    _generateRoomMonster();
  }

  void _generateRoomMonster() {
    // Cria o monstro da sala atual
    Monster rato = Monster(
      name: currentRoom == totalRooms
          ? "Rei Rato (BOSS)"
          : "Rato Nível $currentRoom",
      hp: 40 + (currentRoom * 15),
      atk: 5 + (currentRoom * 2),
      def: 2 + currentRoom,
      expValue: 30 * currentRoom,
      imagePath: 'assets/monsters/esqueleto.webp',
      isBoss: currentRoom == totalRooms,
    );

    setState(() {
      currentEnemies = [rato];
      enemiesHP = [rato.hp];
      _activeDamagesOnMonsters = [];
    });
  }

  void _processTurn() {
    setState(() {
      // --- 1. TURNO DO HERÓI ---
      int damageToMonster = widget.hero.totalStr - currentEnemies[0].def;
      if (damageToMonster < 1) damageToMonster = 1;

      _activeDamagesOnMonsters.add(
        MonsterDamageInfo(
          monsterIndex: 0,
          damage: damageToMonster,
          key: UniqueKey(),
        ),
      );

      enemiesHP[0] -= damageToMonster;
      battleLog =
          "Você causou $damageToMonster de dano no ${currentEnemies[0].name}!";

      // Verifica se o bicho morreu
      if (enemiesHP[0] <= 0) {
        _handleRoomVictory();
        return;
      }

      // --- 2. TURNO DO MONSTRO ---
      int effectiveDamage = (currentEnemies[0].atk - widget.hero.totalDef);
      if (effectiveDamage < 2) effectiveDamage = 2;

      widget.hero.hp -= effectiveDamage;
      battleLog +=
          "\nO monstro revidou! Você recebeu $effectiveDamage de dano.";

      if (widget.hero.hp <= 0) {
        _handleDefeat();
      }
    });
  }

  void _handleRoomVictory() {
    if (currentRoom < totalRooms) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "SALA LIMPA!",
            style: TextStyle(color: Colors.green),
          ),
          content: Text("O monstro da sala $currentRoom caiu. Deseja avançar?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  currentRoom++;
                  battleLog = "Sala $currentRoom: Um novo desafio surge!";
                  _generateRoomMonster();
                });
              },
              child: const Text("PRÓXIMA SALA"),
            ),
          ],
        ),
      );
    } else {
      _handleFinalVictory();
    }
  }

  void _handleFinalVictory() {
    // Recompensa Fixa: Espada Comum
    final reward = ItemData.espadacomum.copy();

    widget.hero.addItem(reward);

    widget.hero.gainExp(500); // Bônus de exp do castelo

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "VITÓRIA TOTAL!",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Você conquistou o castelo!\n\nGanhou: ${reward.name}\nEXP: +500",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              widget.onUpdate();
            },
            child: const Text("VOLTAR"),
          ),
        ],
      ),
    );
  }

  void _handleDefeat() {
    widget.hero.hp = 0;
    // Perde 30% do gold
    widget.hero.gold = (widget.hero.gold * 0.7).toInt();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("DERROTA", style: TextStyle(color: Colors.red)),
        content: const Text("Você sucumbiu aos monstros do castelo..."),
        actions: [
          ElevatedButton(
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
            child: const Text("VOLTAR PARA VILA"),
          ),
        ],
      ),
    );
  }

  void _onDamageAnimationComplete(Key damageKey) {
    if (!mounted) return;
    setState(() {
      _activeDamagesOnMonsters.removeWhere((info) => info.key == damageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo escuro do castelo
          Positioned.fill(
            child: Image.asset(
              "assets/images/castelo.webp",
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.8),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Cabeçalho com progresso das salas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "CASTELO - SALA $currentRoom/$totalRooms",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "HP: ${widget.hero.hp}",
                        style: TextStyle(
                          color: widget.hero.hp < 30
                              ? Colors.red
                              : Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: currentRoom / totalRooms,
                    backgroundColor: Colors.white10,
                    color: Colors.red,
                  ),

                  // Arena de Monstros (Onde o dano voa)
                  Expanded(
                    flex: 3,
                    child: MonsterArena(
                      enemies: currentEnemies,
                      enemiesHP: enemiesHP,
                      pendingDamages: _activeDamagesOnMonsters,
                      onDamageAnimationComplete: _onDamageAnimationComplete,
                    ),
                  ),

                  // Log de Batalha
                  Container(
                    height: 80,
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.3),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        battleLog,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Controles de Batalha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[900],
                          ),
                          onPressed: _processTurn,
                          child: const Text(
                            "ATACAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
