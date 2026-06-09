import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asha_rpg/models/game_state.dart'; // Adapte o path
import 'package:asha_rpg/widgets/monster_arena.dart'; // Adapte o path

class ClanTowerScreen extends StatefulWidget {
  final String clanId;
  final HeroModel hero;
  final int currentFloor;
  final int maxBossHP;
  final int currentBossHP;
  final VoidCallback onUpdate;

  const ClanTowerScreen({
    super.key,
    required this.clanId,
    required this.hero,
    required this.currentFloor,
    required this.maxBossHP,
    required this.currentBossHP,
    required this.onUpdate,
  });

  @override
  State<ClanTowerScreen> createState() => _ClanTowerScreenState();
}

class _ClanTowerScreenState extends State<ClanTowerScreen> {
  final _supabase = Supabase.instance.client;
  late int bossHP;
  int totalDamageDealtThisRun = 0;
  String battleLog = "";
  bool _isProcessing = false;
  bool _hasFinishedBattle = false;

  late List<Monster> currentEnemies;
  late List<int> enemiesHP;
  List<MonsterDamageInfo> _activeDamagesOnMonsters = [];

  @override
  void initState() {
    super.initState();
    bossHP = widget.currentBossHP;
    battleLog =
        "O Boss do ${widget.currentFloor}º Andar surge das sombras com o HP restante de investidas anteriores!";
    _setupBoss();
  }

  void _setupBoss() {
    // Escalonamento agressivo: Bosses de guilda nascem brutais desde o andar 1
    double scale = pow(1.25, widget.currentFloor - 1).toDouble();
    int atkBase = 25 + (widget.currentFloor * 8);
    int defBase = 10 + (widget.currentFloor * 3);

    Monster boss = Monster(
      name: "Guardião Supremo F$widget.currentFloor",
      hp: widget.maxBossHP,
      atk: (atkBase * scale).toInt(),
      def: (defBase * scale).toInt(),
      expValue: 100 * widget.currentFloor,
      imagePath: 'assets/monsters/boss_golem.webp',
      elemento: Elemento.fogo,
      isBoss: true,
    );

    currentEnemies = [boss];
    enemiesHP = [bossHP];
  }

  void _processTurn() async {
    if (_isProcessing ||
        enemiesHP[0] <= 0 ||
        widget.hero.hp <= 0 ||
        _hasFinishedBattle) {
      return;
    }
    setState(() => _isProcessing = true);

    setState(() {
      // 1. Turno do Herói
      int damageToMonster = (widget.hero.totalStr - currentEnemies[0].def)
          .clamp(5, 99999);
      _activeDamagesOnMonsters.add(
        MonsterDamageInfo(
          monsterIndex: 0,
          damage: damageToMonster,
          key: UniqueKey(),
        ),
      );
      enemiesHP[0] -= damageToMonster;
      totalDamageDealtThisRun += damageToMonster;

      if (enemiesHP[0] <= 0) {
        enemiesHP[0] = 0;
        _hasFinishedBattle = true;
        Future.delayed(
          const Duration(milliseconds: 600),
          () => _handleBossVictory(),
        );
        return;
      }

      // 2. Turno do Boss (Sempre revida agressivamente)
      int effectiveDamage = (currentEnemies[0].atk - widget.hero.totalDef)
          .clamp(15, 99999);
      widget.hero.hp -= effectiveDamage;
      battleLog =
          "Você desferiu $damageToMonster de dano! O Boss revidou com $effectiveDamage!";

      if (widget.hero.hp <= 0) {
        widget.hero.hp = 0;
        _hasFinishedBattle = true;
        Future.delayed(
          const Duration(milliseconds: 600),
          () => _handleHeroDeath(),
        );
      }
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _finalizarDadosNoSupabase(
    int novoHpBoss,
    bool bossMorreu,
  ) async {
    final hoje = DateTime.now().toIso8601String().split('T').first;
    final userId = _supabase.auth.currentUser!.id;

    try {
      // Busca rápida para pegar os scores atuais salvos no banco antes de somar
      final clanData = await _supabase
          .from('clans')
          .select('total_damage_score, tower_floor')
          .eq('id', widget.clanId)
          .single();

      int currentDamageScore = clanData['total_damage_score'] ?? 0;
      int currentFloorInDb = clanData['tower_floor'] ?? widget.currentFloor;

      // Monta o update calculando os incrementos corretos para o Supabase
      final clanUpdates = {
        'boss_current_hp': bossMorreu ? -1 : novoHpBoss,
        'total_damage_score': currentDamageScore + totalDamageDealtThisRun,
      };

      if (bossMorreu) {
        clanUpdates['tower_floor'] = currentFloorInDb + 1;
      }

      // Atualiza o Clã
      await _supabase.from('clans').update(clanUpdates).eq('id', widget.clanId);

      // Registra a trava diária no Perfil do Jogador
      await _supabase
          .from('profiles')
          .update({'last_clan_tower_attack': hoje})
          .eq('id', userId);

      // Salva o estado atual do herói (vida reduzida, etc)
      await widget.hero.saveToSupabase();
      widget.onUpdate();
    } catch (e) {
      debugPrint("Erro ao atualizar dados no Supabase: $e");
    }
  }

  void _handleBossVictory() async {
    await _finalizarDadosNoSupabase(0, true);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "⚔️ VITÓRIA DO CLÃ!",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Incrível! Você desferiu o golpe final!\n\nDano causado nessa sessão: $totalDamageDealtThisRun\nO Clã avançou para o Andar ${widget.currentFloor + 1}!",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text("RETORNAR"),
          ),
        ],
      ),
    );
  }

  void _handleHeroDeath() async {
    await _finalizarDadosNoSupabase(enemiesHP[0], false);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "💀 VOCÊ TOMBOU",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "O Boss era forte demais, mas seu sacrifício ajudou o Clã!\n\nDano salvo e acumulado no Ranking: +$totalDamageDealtThisRun\nO próximo membro pegará o Boss com ${enemiesHP[0]} de HP!",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text("MURAL DO CLÃ"),
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.red[900]!.withOpacity(0.15)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "RAID - ANDAR ${widget.currentFloor}",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Seu HP: ${widget.hero.hp}",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 20,
                        child: Text(
                          currentEnemies[0].name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Transform.scale(
                          scale: 2.2,
                          child: MonsterArena(
                            enemies: currentEnemies,
                            enemiesHP: enemiesHP,
                            pendingDamages: _activeDamagesOnMonsters,
                            onDamageAnimationComplete:
                                _onDamageAnimationComplete,
                            showName: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    battleLog,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isProcessing || _hasFinishedBattle
                          ? Colors.grey[800]
                          : Colors.red[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _processTurn,
                    child: Text(
                      _isProcessing ? "CONJURANDO..." : "GOLPE DE GUILDA",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
