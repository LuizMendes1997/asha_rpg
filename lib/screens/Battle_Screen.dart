import 'package:flutter/material.dart';
import 'dart:math';
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
  List<int> _evadingMonsters = [];
  String _statusElementalInfo = "";

  // Controles de Animação e Delay
  bool _isAttacking = false;
  int? _attackingMonsterIndex;
  int? _slashTargetIndex;
  bool _showRedFlash = false;

  @override
  void initState() {
    super.initState();
    enemiesHP = widget.enemies.map((e) => e.hp).toList().cast<int>();
    battleLog = widget.startMessage;
    // 🎯 Calcula o status do primeiro monstro logo ao abrir a tela
    _statusElementalInfo = _calcularStatusElementalAtual();
  }

  void _triggerMonsterEvade(int index) {
    if (mounted) {
      setState(() => _evadingMonsters.add(index));
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _evadingMonsters.remove(index));
      });
    }
  }

  // 🛡️ MÉTODOS AUXILIARES PARA O SISTEMA ELEMENTAL

  Elemento _obterVantagem(Elemento elem) {
    switch (elem) {
      case Elemento.fogo:
        return Elemento.vento;
      case Elemento.vento:
        return Elemento.terra;
      case Elemento.terra:
        return Elemento.agua;
      case Elemento.agua:
        return Elemento.fogo;
      default:
        return Elemento.nenhum;
    }
  }

  String _obterTagElemental(Elemento elem) {
    switch (elem) {
      case Elemento.fogo:
        return "🔥[FOGO]";
      case Elemento.vento:
        return "💨[VENTO]";
      case Elemento.terra:
        return "🪨[TERRA]";
      case Elemento.agua:
        return "💧[ÁGUA]";
      default:
        return "";
    }
  }

  // 🔮 NOVO METODO: Calcula o confronto elemental do alvo atual a qualquer momento
  String _calcularStatusElementalAtual() {
    if (currentEnemyIndex >= widget.enemies.length) return "";

    Monster alvo = widget.enemies[currentEnemyIndex];
    Map<Elemento, int> bonusAtivos = widget.hero.obterBonusElementaisAtivos();

    if (bonusAtivos.isNotEmpty && alvo.elemento != Elemento.nenhum) {
      Elemento elementoHeroi = bonusAtivos.keys.first;
      int quantidadePecas = bonusAtivos[elementoHeroi]!;
      int atkelemental = quantidadePecas * 5;
      double danoBase = (widget.hero.totalStr).toDouble();
      danoBase = danoBase * (atkelemental / 100);
      String emojiHeroi = _obterTagElemental(elementoHeroi).split('[').first;

      if (_obterVantagem(elementoHeroi) == alvo.elemento) {
        return "$emojiHeroi vs ${alvo.elemento.name.toUpperCase()}: +$atkelemental% Total de $danoBase a mais.";
      } else if (_obterVantagem(alvo.elemento) == elementoHeroi) {
        return "$emojiHeroi vs ${alvo.elemento.name.toUpperCase()}: -25%";
      }
    }
    return "";
  }

  // --- LÓGICA DE TURNO COMPLETA COM CÁLCULO ELEMENTAL ---
  Future<void> _processTurn() async {
    if (_isAttacking) return;

    setState(() {
      _isAttacking = true;
      _slashTargetIndex = currentEnemyIndex;
    });

    // 1. TURNO DO HERÓI
    bool monsterEvaded = Random().nextInt(100) < 10;
    await Future.delayed(const Duration(milliseconds: 150));

    setState(() {
      if (monsterEvaded) {
        battleLog =
            "${widget.enemies[currentEnemyIndex].name} desviou do seu ataque!";
        _statusElementalInfo = ""; // Limpa temporariamente se errou o golpe
        _triggerMonsterEvade(currentEnemyIndex);
      } else {
        Monster Alvo = widget.enemies[currentEnemyIndex];

        // Base de cálculo do dano físico bruto
        double danoBase = (widget.hero.totalStr - Alvo.def).toDouble();
        if (danoBase < 1) danoBase = 1;

        Map<Elemento, int> bonusAtivos = widget.hero
            .obterBonusElementaisAtivos();
        double modificadorElemental = 1.0;
        String logEfeitoElemental = "";

        if (bonusAtivos.isNotEmpty) {
          Elemento elementoHeroi = bonusAtivos.keys.first;
          int quantidadePecas = bonusAtivos[elementoHeroi]!;
          int atkelemental = quantidadePecas * 5;
          danoBase += danoBase * (atkelemental / 100);

          // ⚖️ SISTEMA COMBATENTE DA RODA ELEMENTAL
          if (Alvo.elemento != Elemento.nenhum) {
            if (_obterVantagem(elementoHeroi) == Alvo.elemento) {
              modificadorElemental = 1.0;
              logEfeitoElemental =
                  "\n✨ Ataque Eficaz! O poder de ${_obterTagElemental(elementoHeroi)} sobrepujou o ${_obterTagElemental(Alvo.elemento)} do inimigo! $atkelemental%";
            } else if (_obterVantagem(Alvo.elemento) == elementoHeroi) {
              modificadorElemental = 0.75;
              logEfeitoElemental =
                  "\n📉 Ataque Ineficaz... O elemento ${_obterTagElemental(Alvo.elemento)} do inimigo resistiu ao seu ${_obterTagElemental(elementoHeroi)}! (-25%)";
            }
          }
        }

        // Atualiza o topo com o status calculado da nova função
        _statusElementalInfo = _calcularStatusElementalAtual();

        // Consolidação do cálculo final de dano
        int damageToMonster = (danoBase * modificadorElemental).toInt();
        if (damageToMonster < 1) damageToMonster = 1;

        _activeDamagesOnMonsters.add(
          MonsterDamageInfo(
            monsterIndex: currentEnemyIndex,
            damage: damageToMonster,
            key: UniqueKey(),
          ),
        );

        damageToMonster = damageToMonster - Alvo.def;
        enemiesHP[currentEnemyIndex] -= damageToMonster;
        battleLog =
            "Você atacou ${Alvo.name} e causou $damageToMonster de dano!$logEfeitoElemental";

        if (enemiesHP[currentEnemyIndex] <= 0) {
          currentEnemyIndex++;
          // 🔄 Monstro morreu? Calcula imediatamente o status para o PRÓXIMO monstro da lista
          _statusElementalInfo = _calcularStatusElementalAtual();
        }
      }
      _slashTargetIndex = null;
    });

    if (currentEnemyIndex >= widget.enemies.length) {
      _handleVictory();
      setState(() => _isAttacking = false);
      return;
    }

    // 2. TURNO DOS MONSTROS (CONTRA-ATAQUE)
    await Future.delayed(const Duration(milliseconds: 400));
    int rawMonsterDamage = 0;
    for (int i = currentEnemyIndex; i < widget.enemies.length; i++) {
      if (enemiesHP[i] > 0) {
        setState(() => _attackingMonsterIndex = i);
        rawMonsterDamage += widget.enemies[i].atk;
        await Future.delayed(const Duration(milliseconds: 150));
        setState(() => _attackingMonsterIndex = null);
      }
    }

    int effectiveDamage = (rawMonsterDamage - widget.hero.totalDef);
    if (effectiveDamage < 2) effectiveDamage = 2;

    setState(() {
      widget.hero.hp -= effectiveDamage;
      _showRedFlash = true;
      battleLog +=
          "\nOs monstros revidam! Você recebeu $effectiveDamage de dano.";

      // Se o herói sobreviveu e tinha limpado o painel por causa de um desvio, restaura o preview do alvo atual
      if (widget.hero.hp > 0 && _statusElementalInfo.isEmpty) {
        _statusElementalInfo = _calcularStatusElementalAtual();
      }
    });

    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _showRedFlash = false);

    if (widget.hero.hp <= 0) {
      _handleDefeat();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _isAttacking = false);
  }

  void _handleVictory() {
    List<Item> allLoot = [];
    int totalExp = 0;
    int totalGold = 0;
    List<String> questProgressMessages = [];

    for (var m in widget.enemies) {
      allLoot.addAll(LootTable.getDrops(m.name));
      totalExp += m.expValue;
      totalGold += 5;

      for (var quest in widget.hero.activeQuests) {
        if (!quest.isCompleted &&
            m.name.toLowerCase().contains(
              quest.targetMonsterName.toLowerCase(),
            )) {
          if (quest.currentKillCount < quest.requiredKillCount) {
            quest.currentKillCount++;
            String msg =
                "${quest.title}: ${quest.currentKillCount}/${quest.requiredKillCount}";
            if (!questProgressMessages.contains(msg)) {
              questProgressMessages.add(msg);
            }
          }
        }
      }
    }

    widget.hero.gainExp(totalExp);
    widget.hero.gold += totalGold;
    for (var item in allLoot) {
      widget.hero.addItem(item);
    }
    widget.hero.saveToSupabase();

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
            if (questProgressMessages.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                "📜 MISSÕES:",
                style: TextStyle(color: Colors.orangeAccent, fontSize: 10),
              ),
              ...questProgressMessages.map(
                (msg) => Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            if (allLoot.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                "🎒 ITENS ENCONTRADOS:",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allLoot
                    .map((i) => Image.asset(i.iconPath, width: 30, height: 30))
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
    widget.hero.gold = (widget.hero.gold * 0.7).toInt();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("DERROTA", style: TextStyle(color: Colors.red)),
        content: const Text(
          "Você desmaiou e perdeu um pouco de ouro...",
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
              "VOLTAR PARA CIDADE",
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFlee() {
    if (_isAttacking) return;
    int penalty = widget.hero.gold >= 30 ? 30 : widget.hero.gold;
    widget.hero.gold -= penalty;
    widget.hero.saveToSupabase();
    Navigator.pop(context);
    widget.onUpdate();
  }

  void _onDamageAnimationComplete(Key damageKey) {
    if (!mounted) return;
    setState(() {
      _activeDamagesOnMonsters.removeWhere((info) => info.key == damageKey);
    });
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
          if (_showRedFlash)
            Positioned.fill(
              child: Container(color: Colors.red.withOpacity(0.3)),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "COMBATE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  if (_statusElementalInfo.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        _statusElementalInfo,
                        style: TextStyle(
                          color: _statusElementalInfo.contains("-")
                              ? Colors.redAccent
                              : Colors.lightBlueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 3,
                    child: MonsterArena(
                      enemies: widget.enemies,
                      enemiesHP: enemiesHP,
                      pendingDamages: _activeDamagesOnMonsters,
                      evadingMonsterIndices: _evadingMonsters,
                      attackingMonsterIndex: _attackingMonsterIndex,
                      slashTargetIndex: _slashTargetIndex,
                      onDamageAnimationComplete: _onDamageAnimationComplete,
                    ),
                  ),
                  Container(
                    height: 100,
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
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
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24),
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
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "HP: ${widget.hero.hp}",
                              style: TextStyle(
                                color: widget.hero.hp < 20
                                    ? Colors.red
                                    : Colors.greenAccent,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (!allDead) ...[
                              TextButton(
                                onPressed: _isAttacking ? null : _handleFlee,
                                child: const Text(
                                  "FUGIR (30G)",
                                  style: TextStyle(color: Colors.orangeAccent),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isAttacking
                                      ? Colors.grey
                                      : Colors.red[900],
                                ),
                                onPressed: _isAttacking ? null : _processTurn,
                                child: Text(
                                  _isAttacking ? "..." : "ATACAR",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ] else
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("SAIR"),
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
