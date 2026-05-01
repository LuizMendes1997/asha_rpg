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
  int currentFloor = 1;
  int totalGoldEarned = 0;
  String battleLog = "Você entrou no 1º Andar da Torre Mágica...";

  late List<int> enemiesHP;
  late List<Monster> currentEnemies;
  List<MonsterDamageInfo> _activeDamagesOnMonsters = [];

  @override
  void initState() {
    super.initState();
    _spawnFloorMonster();
  }

  void _spawnFloorMonster() {
    // A cada andar, o bicho fica 10% mais forte que o anterior
    Monster monstro = Monster(
      name: "Guardião da Torre F$currentFloor",
      hp: 30 + (currentFloor * 10),
      atk: 5 + (currentFloor * 2),
      def: 2 + (currentFloor),
      expValue: 10 + currentFloor,
      imagePath:
          'assets/monsters/fantasma.webp', // Use um fantasma ou bicho místico
      isBoss: currentFloor % 5 == 0, // A cada 5 andares é um boss
    );

    setState(() {
      currentEnemies = [monstro];
      enemiesHP = [monstro.hp];
      _activeDamagesOnMonsters = [];
    });
  }

  void _processTurn() {
    setState(() {
      // Ataque do Herói
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

      if (enemiesHP[0] <= 0) {
        _handleFloorVictory();
        return;
      }

      // Contra-ataque do Monstro
      int effectiveDamage = (currentEnemies[0].atk - widget.hero.totalDef);
      if (effectiveDamage < 2) effectiveDamage = 2;

      widget.hero.hp -= effectiveDamage;
      battleLog = "Andar $currentFloor: Recebeu $effectiveDamage de dano!";

      if (widget.hero.hp <= 0) _handleDefeat();
    });
  }

  void _handleFloorVictory() {
    totalGoldEarned += 10;
    widget.hero.gold += 10;

    // Aqui você salvaria o recorde do ranking no futuro
    // if (currentFloor > hero.maxTowerFloor) hero.maxTowerFloor = currentFloor;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "ANDAR $currentFloor CONCLUÍDO!",
          style: const TextStyle(color: Colors.cyanAccent),
        ),
        content: Text(
          "Recompensa: +10 Ouro\nTotal acumulado: $totalGoldEarned Ouro\nDeseja continuar subindo?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              widget.onUpdate();
            },
            child: const Text(
              "SAIR COM O OURO",
              style: TextStyle(color: Colors.amber),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentFloor++;
                battleLog = "Subindo para o andar $currentFloor...";
                _spawnFloorMonster();
              });
            },
            child: const Text("SUBIR PRÓXIMO ANDAR"),
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
        title: const Text(
          "DERROTA NA TORRE",
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          "Você caiu no andar $currentFloor.\nTodo o ouro acumulado nesta subida foi perdido!",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Penalidade da torre: perde o ouro que ganhou nela
              widget.hero.gold -= totalGoldEarned;
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
          // 1. FUNDO DA TORRE (A imagem digna que você gerou)
          Positioned.fill(
            child: Image.asset(
              "assets/images/torre.webp", // Certifique-se de que o nome está igual ao arquivo
              fit: BoxFit.cover,
            ),
          ),

          // 2. FILTRO DE CONTRASTE (Para a interface não sumir no fundo)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4), // Escurece o topo
                    Colors.transparent, // Deixa o meio limpo para o monstro
                    Colors.black.withOpacity(
                      0.7,
                    ), // Escurece a base para o botão/log
                  ],
                ),
              ),
            ),
          ),

          // 3. INTERFACE DO JOGO
          SafeArea(
            child: Column(
              children: [
                // Cabeçalho com Estilo Neon
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.cyan, width: 1),
                        ),
                        child: Text(
                          "TORRE MÁGICA - F$currentFloor",
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.cyan, blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        "HP: ${widget.hero.hp}",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arena de Batalha (Onde os monstros aparecem)
                Expanded(
                  child: MonsterArena(
                    enemies: currentEnemies,
                    enemiesHP: enemiesHP,
                    pendingDamages: _activeDamagesOnMonsters,
                    onDamageAnimationComplete: _onDamageAnimationComplete,
                  ),
                ),

                // Log de Batalha Estilizado
                Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    battleLog,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),

                // Botão de Ação
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan.shade900,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(220, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                          color: Colors.cyanAccent,
                          width: 2,
                        ),
                      ),
                      elevation: 15,
                      shadowColor: Colors.cyanAccent,
                    ),
                    onPressed: _processTurn,
                    child: const Text(
                      "CONJURAR ATAQUE",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
