import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'ranking_screen.dart'; // Import da sua tela de ranking original
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
  void _mostrarMensagem(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // Método unificado para criar os botões/cards de acesso
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
            // Fallback caso o ícone específico sumir
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

  // Lógica de matchmaking da Arena tirada da VillageScreen
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
    return Scaffold(
      body: Stack(
        children: [
          // --- 1. IMAGEM DE FUNDO (Estilo Vila) ---
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/online_fundo.webp",
                ), // Mude para o seu background do coliseu/online
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay escuro
          Container(color: Colors.black.withOpacity(0.4)),

          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // --- CABEÇALHO EM CARD REFORÇADO ---
              Card(
                elevation: 10,
                color: Colors.red[900]?.withOpacity(
                  0.80,
                ), // Tom avermelhado para combate/online
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Colors.amber, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.gavel_rounded,
                        color: Colors.amber,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "ZONA ONLINE",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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

              // --- ATALHO 1: ARENA PVP ---
              _regionCard(
                context,
                "Arena de Batalha",
                "Enfrente outros jogadores em tempo real e dispute a glória",
                "assets/icons/arena.webp", // Certifique-se de ter esse asset ou use o fallback do Icon
                () => _entrarNaArena(),
              ),

              // --- ATALHO 2: RANKING GLOBAL ---
              _regionCard(
                context,
                "Ranking de Heróis",
                "Veja quem são os maiores guerreiros de todo o reino",
                "assets/icons/ranking.webp", // Ícone de troféu ou ranking
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RankingScreen(),
                    ),
                  );
                },
              ),
              _regionCard(
                context,
                "Sistema de Clãs", // Mudei o nome para algo mais épico
                widget.hero.clanId != null
                    ? "Gerencie seu clã e veja seus aliados"
                    : "Una os maiores guerreiros de todo o reino",
                "assets/icons/ranking.webp",
                () {
                  // LÓGICA DE REDIRECIONAMENTO
                  if (widget.hero.clanId != null &&
                      widget.hero.clanId!.isNotEmpty) {
                    // Se JÁ TEM clã, vai para os DETALHES
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClanDetailsScreen(clanId: widget.hero.clanId!),
                      ),
                    ).then((_) => widget.onUpdate()); // Atualiza ao voltar
                  } else {
                    // Se NÃO TEM clã, vai para a CRIAÇÃO
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClanCreateScreen(),
                      ),
                    ).then((v) {
                      // Se a criação retornar true, significa que o clã foi criado
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
