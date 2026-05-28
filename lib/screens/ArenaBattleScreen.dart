import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ==========================================
// 1. MODELOS DE DADOS (ESTRATO SIMPLES)
// ==========================================

class ArenaOpponent {
  final String id;
  final String username;
  final int level;
  final int str;
  final int def;
  final int maxHp;
  int currentHp;
  final String? elementalStats;
  final String raca;

  ArenaOpponent({
    required this.id,
    required this.username,
    required this.level,
    required this.str,
    required this.def,
    required this.maxHp,
    required this.elementalStats,
    required this.raca,
  }) : currentHp = maxHp;
}

// Simulando seu HeroModel atual para o código compilar direto
class ArenaHeroModel {
  final String id;
  final String name;
  final int level;
  final int totalStr;
  final int def;
  final int maxHp;
  int currentHp;
  final String? elementalStats;
  final String raca;
  int gold;

  ArenaHeroModel({
    required this.id,
    required this.name,
    required this.level,
    required this.totalStr,
    required this.def,
    required this.maxHp,
    required this.currentHp,
    required this.elementalStats,
    required this.raca,
    this.gold = 0,
  });
}

// ==========================================
// 2. MOTOR DE CÁLCULO ELEMENTAL
// ==========================================

class ArenaEngine {
  // Converte a string "0:15,2:10" para um Map de {elemento: porcentagem}
  static Map<int, int> parseElementalStats(String? stats) {
    if (stats == null || stats.isEmpty) return {};
    final map = <int, int>{};
    try {
      final parts = stats.split(',');
      for (var p in parts) {
        final entry = p.split(':');
        if (entry.length == 2) {
          map[int.parse(entry[0])] = int.parse(entry[1]);
        }
      }
    } catch (e) {
      debugPrint("Erro ao fazer o parse dos status elementais: $e");
    }
    return map;
  }

  // Aplica a sua regra: cada parte dá 5% de força extra (só ativa com 3+ itens)
  static int calcularDano(
    int strAtacante,
    int defDefensor,
    Map<int, int> statsAtacante,
  ) {
    double multiplicadorExtra = 0.0;

    // Varre os elementos acumulados no cache
    statsAtacante.forEach((elemento, porcentagem) {
      // Como 3 itens = 15% e 4 itens = 20%, a própria porcentagem dita o ganho direto
      if (porcentagem >= 15) {
        multiplicadorExtra += (porcentagem / 100);
      }
    });

    double multiplicadorFinal = 1.0 + multiplicadorExtra;

    // Fórmula base: Dano = (Força com bônus) - metade da defesa do alvo
    int danoFinal = (((strAtacante * multiplicadorFinal) * 2) - (defDefensor))
        .toInt();

    // Garante que pelo menos 1 de dano seja causado
    return danoFinal < 1 ? 1 : danoFinal;
  }
}

// ==========================================
// 3. WIDGET DE DANO FLUTUANTE (ANIMADO)
// ==========================================

class FloatingDamageText extends StatefulWidget {
  final int damage;
  final Key key; // Obrigatório para o Flutter diferenciar os widgets na Stack

  const FloatingDamageText({required this.damage, required this.key})
    : super(key: key);

  @override
  State<FloatingDamageText> createState() => _FloatingDamageTextState();
}

class _FloatingDamageTextState extends State<FloatingDamageText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: -80.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Text(
              "-${widget.damage}",
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 4. TELA PRINCIPAL DA ARENA
// ==========================================
class ArenaBattleScreen extends StatefulWidget {
  final ArenaHeroModel player;
  final ArenaOpponent opponent;

  const ArenaBattleScreen({
    super.key,
    required this.player,
    required this.opponent,
  });

  @override
  State<ArenaBattleScreen> createState() => _ArenaBattleScreenState();
}

class _ArenaBattleScreenState extends State<ArenaBattleScreen> {
  bool processandoTurno = false;

  final List<FloatingDamageText> _playerDamageWidgets = [];
  final List<FloatingDamageText> _opponentDamageWidgets = [];

  // ==========================================
  // CONFIGURAÇÃO ELEMENTAL (AJUSTE AQUI)
  // ==========================================

  // Mapeie os IDs dos seus elementos para nomes visuais
  String _getNomeElemento(int id) {
    switch (id) {
      case 0:
        return "Fogo";
      case 1:
        return "Água";
      case 2:
        return "Terra";
      case 3:
        return "Ar";
      case 4:
        return "Luz";
      case 5:
        return "Trevas";
      default:
        return "El.$id";
    }
  }

  // Defina quem tem vantagem sobre quem (Ex: 1 (Água) ganha de 0 (Fogo))
  bool _temVantagem(int meuElemento, List<int> elementosInimigo) {
    final Map<int, List<int>> vantagens = {
      0: [2], // Fogo ganha de Terra
      1: [0], // Água ganha de Fogo
      2: [1], // Terra ganha de Água
      // Adicione o resto da sua roda elemental aqui...
    };

    final meusAlvosFracos = vantagens[meuElemento] ?? [];
    // Retorna true se o inimigo tiver algum elemento que o meu elemento ganha
    return elementosInimigo.any((el) => meusAlvosFracos.contains(el));
  }

  void _adicionarDanoFlutuante(int dano, bool isPlayerAlvo) {
    final uniqueKey = UniqueKey();
    final dmgWidget = FloatingDamageText(damage: dano, key: uniqueKey);

    setState(() {
      if (isPlayerAlvo) {
        _playerDamageWidgets.add(dmgWidget);
      } else {
        _opponentDamageWidgets.add(dmgWidget);
      }
    });

    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          if (isPlayerAlvo) {
            _playerDamageWidgets.removeWhere((w) => w.key == uniqueKey);
          } else {
            _opponentDamageWidgets.removeWhere((w) => w.key == uniqueKey);
          }
        });
      }
    });
  }

  void _executarTurno() {
    if (processandoTurno ||
        widget.player.currentHp <= 0 ||
        widget.opponent.currentHp <= 0)
      return;

    setState(() {
      processandoTurno = true;
    });

    final statsPlayer = ArenaEngine.parseElementalStats(
      widget.player.elementalStats,
    );
    int danoDoPlayer = ArenaEngine.calcularDano(
      widget.player.totalStr,
      widget.opponent.def,
      statsPlayer,
    );

    setState(() {
      widget.opponent.currentHp = max(
        0,
        widget.opponent.currentHp - danoDoPlayer,
      );
    });
    _adicionarDanoFlutuante(danoDoPlayer, false);

    if (widget.opponent.currentHp <= 0) {
      _finalizarBatalha(vitoria: true);
      return;
    }

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;

      final statsBot = ArenaEngine.parseElementalStats(
        widget.opponent.elementalStats,
      );
      int danoDoBot = ArenaEngine.calcularDano(
        widget.opponent.str,
        widget.player.def,
        statsBot,
      );

      setState(() {
        widget.player.currentHp = max(0, widget.player.currentHp - danoDoBot);
      });
      _adicionarDanoFlutuante(danoDoBot, true);

      if (widget.player.currentHp <= 0) {
        _finalizarBatalha(vitoria: false);
      } else {
        setState(() {
          processandoTurno = false;
        });
      }
    });
  }

  void _finalizarBatalha({required bool vitoria}) {
    setState(() {
      processandoTurno = false;
    });

    if (vitoria) widget.player.gold += 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          vitoria ? "🏆 VITÓRIA!" : "💀 DERROTA!",
          style: TextStyle(
            color: vitoria ? Colors.amber : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          vitoria
              ? "Você derrotou ${widget.opponent.username} e faturou +100 moedas de ouro!\n"
              : "Você foi derrotado por ${widget.opponent.username}!\n\n",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 1. Fecha o AlertDialog
              Navigator.of(
                context,
              ).pop(); // 2. Fecha a ArenaBattleScreen e volta pro Hub
            },
            child: const Text(
              "VOLTAR",
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Cor base
      appBar: AppBar(
        backgroundColor: Colors.grey[900]?.withOpacity(0.9),
        title: Text("Arena"),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "Gold: ${widget.player.gold}",
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/arena.webp',
            ), // Sua imagem de fundo aqui
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors
                  .black54, // Escurece um pouco o fundo para dar destaque aos cards
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PLAYER ---
                  _buildCardCombatente(
                    nome: widget.player.name,
                    raca: widget.player.raca,
                    level: widget.player.level,
                    currentHp: widget.player.currentHp,
                    maxHp: widget.player.maxHp,
                    str: widget.player.totalStr,
                    def: widget.player.def,
                    elementalStats: widget.player.elementalStats,
                    enemyElementalStats: widget.opponent.elementalStats,
                    damageWidgets: _playerDamageWidgets,
                    isPlayer: true,
                  ),

                  const Padding(
                    padding: EdgeInsets.only(top: 80.0),
                    child: Text(
                      "VS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- OPONENTE ---
                  _buildCardCombatente(
                    nome: widget.opponent.username,
                    raca: widget.opponent.raca,
                    level: widget.opponent.level,
                    currentHp: widget.opponent.currentHp,
                    maxHp: widget.opponent.maxHp,
                    str: widget.opponent.str,
                    def: widget.opponent.def,
                    elementalStats: widget.opponent.elementalStats,
                    enemyElementalStats: widget.player.elementalStats,
                    damageWidgets: _opponentDamageWidgets,
                    isPlayer: false,
                  ),
                ],
              ),
            ),

            // Painel de Ações
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        "Limite diário atingido!",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          disabledBackgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: (processandoTurno) ? null : _executarTurno,
                        child: processandoTurno
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "ATACAR",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardCombatente({
    required String nome,
    required String raca,
    required int level,
    required int currentHp,
    required int maxHp,
    required int str,
    required int def,
    required String? elementalStats,
    required String? enemyElementalStats,
    required List<FloatingDamageText> damageWidgets,
    required bool isPlayer,
  }) {
    double porcentagemVida = currentHp / maxHp;

    // Parseia os elementos para exibição
    final myElements = ArenaEngine.parseElementalStats(elementalStats);
    final enemyElements = ArenaEngine.parseElementalStats(enemyElementalStats);

    return Expanded(
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Nv. $level - $raca",
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 12),

              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border.all(
                    color: isPlayer ? Colors.blueAccent : Colors.orangeAccent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/hero_placeholder.webp',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 50,
                        color: isPlayer ? Colors.blue : Colors.orange,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: porcentagemVida,
                    minHeight: 14,
                    backgroundColor: Colors.grey[800],
                    color: porcentagemVida > 0.4 ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$currentHp / $maxHp",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Courier',
                ),
              ),

              const SizedBox(height: 12),

              // === NOVOS DADOS: STATUS BRUTOS ===
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 14,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "$str ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.shield, size: 14, color: Colors.blueGrey),
                  const SizedBox(width: 4),
                  Text(
                    "$def",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // === NOVOS DADOS: ELEMENTOS ===
              if (myElements.isEmpty)
                const Text(
                  "Neutro",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )
              else
                Column(
                  children: myElements.entries.map((entry) {
                    int elId = entry.key;
                    int elPct = entry.value;

                    // Sua engine diz que >= 15 ativa o bônus
                    bool isBonusAtivo = elPct >= 15;
                    // Calcula vantagem do tipo em cima do inimigo
                    bool temVantagem = _temVantagem(
                      elId,
                      enemyElements.keys.toList(),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${_getNomeElemento(elId)} $elPct%",
                            style: TextStyle(
                              color: isBonusAtivo
                                  ? Colors.amberAccent
                                  : Colors.white70,
                              fontWeight: isBonusAtivo
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          if (temVantagem) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_double_arrow_up,
                              size: 14,
                              color: Colors.greenAccent,
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),

          Positioned(
            top: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [...damageWidgets],
            ),
          ),
        ],
      ),
    );
  }
}
