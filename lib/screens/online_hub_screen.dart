import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'ranking_screen.dart';
import 'ArenaBattleScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'clan_create_screen.dart';
import 'clan_details_screen.dart';

class OnlineHubScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const OnlineHubScreen({
    super.key,
    required this.hero,
    required this.onUpdate,
  });

  @override
  State<OnlineHubScreen> createState() => _OnlineHubScreenState();
}

class _OnlineHubScreenState extends State<OnlineHubScreen> {
  // --- VARIÁVEIS DE ESTADO LOCAL ---
  String? _currentClanId;
  bool _isCheckingClan = false;

  @override
  void initState() {
    super.initState();
    // Inicializa com o clã que veio do herói, mas vai checar no banco por segurança
    _currentClanId = widget.hero.clanId;
    _buscarClanIdAtualizado();
  }

  // --- BUSCA O CLAN_ID DIRETO DO SUPABASE EM TEMPO REAL ---
  Future<void> _buscarClanIdAtualizado() async {
    if (_isCheckingClan) return;
    setState(() => _isCheckingClan = true);

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      setState(() => _isCheckingClan = false);
      return;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select('clan_id')
          .eq('id', userId)
          .maybeSingle();

      if (mounted && response != null) {
        setState(() {
          _currentClanId = response['clan_id']?.toString();
          // Tentativa de atualizar a referência do herói localmente, caso o modelo permita alteração
          try {
            (widget.hero as dynamic).clanId = _currentClanId;
          } catch (_) {}
        });
      }
    } catch (e) {
      debugPrint("Erro ao sincronizar clã no Hub: $e");
    } finally {
      if (mounted) setState(() => _isCheckingClan = false);
    }
  }

  void _mostrarMensagem(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  Widget _regionCard(
    BuildContext context,
    String title,
    String subtitle,
    String imagePath,
    VoidCallback onTap,
  ) {
    return Card(
      color: Colors.grey[900]?.withOpacity(0.85),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 40,
          height: 40,
          filterQuality: FilterQuality.none,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.online_prediction,
              color: Colors.amber,
              size: 40,
            );
          },
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
        onTap: onTap,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white24,
          size: 16,
        ),
      ),
    );
  }

  Future<void> _entrarNaArena() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
        ),
      ),
    );

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .neq('id', widget.hero.id ?? '')
          .limit(20);

      if (context.mounted) Navigator.pop(context);

      ArenaOpponent oponenteReal;
      final listaBruta = response as List<dynamic>;

      if (listaBruta.isNotEmpty) {
        final listaOponentes = List<Map<String, dynamic>>.from(listaBruta);
        listaOponentes.shuffle();
        final data = listaOponentes.first;

        oponenteReal = ArenaOpponent(
          id: data['id'].toString(),
          username: (data['username'] ?? data['name'] ?? "Guerreiro Secreto")
              .toString(),
          level: data['level'] as int? ?? 1,
          str: data['str'] as int? ?? 10,
          def: data['def'] as int? ?? 10,
          maxHp: data['max_hp'] as int? ?? 100,
          elementalStats: (data['elemental_stats'] ?? "0:0").toString(),
          raca: (data['race'] != null ? data['race'].toString() : "Humano"),
          imagePath: (data['emblema_path'] ?? 'assets/hero_placeholder.webp')
              .toString(),
        );
      } else {
        oponenteReal = ArenaOpponent(
          id: "bot_${DateTime.now().millisecondsSinceEpoch}",
          username: "Guerreiro Sombrio (Bot)",
          level: widget.hero.level,
          str: 25,
          def: 15,
          maxHp: 180,
          elementalStats: "0:15",
          raca: "Orc",
          imagePath: "assets/races/human_m.webp",
        );
      }

      final playerArena = ArenaHeroModel(
        id: widget.hero.id ?? '',
        name: widget.hero.name,
        level: widget.hero.level,
        totalStr: widget.hero.totalStr,
        def: widget.hero.totalDef,
        maxHp: widget.hero.totalMaxHp,
        currentHp: widget.hero.hp,
        elementalStats: widget.hero.elementalStats ?? '',
        raca: widget.hero.nomeTituloLinhagem,
        gold: widget.hero.gold,
        imagePath: widget.hero.emblemaPath ?? 'assets/hero_placeholder.webp',
      );

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ArenaBattleScreen(player: playerArena, opponent: oponenteReal),
        ),
      ).then((_) {
        widget.onUpdate();
      });
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        _mostrarMensagem("Erro ao conectar na Arena: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Validação se o clã existe localmente ou na checagem
    final bool temCla = _currentClanId != null && _currentClanId!.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/online_fundo.webp"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              Card(
                elevation: 10,
                color: Colors.red[900]?.withOpacity(0.80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Colors.amber, width: 1.5),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gavel_rounded, color: Colors.amber, size: 30),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "ZONA ONLINE",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- ARENA PVP ---
              _regionCard(
                context,
                "Arena de Batalha",
                "Enfrente outros jogadores em tempo real e dispute a glória",
                "assets/icons/arena.webp",
                () => _entrarNaArena(),
              ),

              // --- RANKING GLOBAL ---
              _regionCard(
                context,
                "Ranking de Heróis",
                "Veja quem são os maiores guerreiros de todo o reino",
                "assets/icons/ranking.webp",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RankingScreen(),
                    ),
                  );
                },
              ),

              // --- SISTEMA DE CLÃS (ATUALIZADO) ---
              _regionCard(
                context,
                "Sistema de Clãs",
                temCla
                    ? "Gerencie seu clã e veja seus aliados"
                    : "Una os maiores guerreiros de todo o reino",
                "assets/icons/ranking.webp",
                () {
                  if (temCla) {
                    // Se JÁ TEM clã, vai para os DETALHES passando o hero e o onUpdate
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClanDetailsScreen(
                          clanId: _currentClanId!,
                          hero: widget.hero,
                          onUpdate: () {
                            // Quando a tela de detalhes pedir atualização, o Hub atualiza também
                            _buscarClanIdAtualizado();
                            widget.onUpdate();
                          },
                        ),
                      ),
                    ).then((_) {
                      _buscarClanIdAtualizado();
                      widget.onUpdate();
                    });
                  } else {
                    // Se NÃO TEM clã, vai para a CRIAÇÃO / LISTAGEM
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClanCreateScreen(),
                      ),
                    ).then((v) {
                      _buscarClanIdAtualizado();
                      if (v == true) {
                        widget.onUpdate();
                      }
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
