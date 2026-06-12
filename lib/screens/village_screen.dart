import 'package:flutter/material.dart';
import 'dart:math';
import '../models/game_state.dart';
import 'guild_screen.dart';
import 'LinhagemScreen.dart';
import 'chat_screen.dart';
import 'ShopScreen.dart';
import 'ranking_screen.dart';

class VillageScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const VillageScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<VillageScreen> createState() => _VillageScreenState();
}

class _VillageScreenState extends State<VillageScreen> {
  int get precoEstalagem => (widget.hero.maxHp / 2).toInt();

  void _descansar() {
    if (widget.hero.gold >= precoEstalagem) {
      if (widget.hero.hp >= widget.hero.totalMaxHp) {
        _mostrarMensagem("Você já está totalmente descansado!");
        return;
      }

      setState(() {
        widget.hero.gold -= precoEstalagem;
        widget.hero.hp = widget.hero.totalMaxHp;
      });

      widget.onUpdate();
      widget.hero.saveToSupabase();
      _mostrarMensagem("Você dormiu profundamente... HP Restaurado!");
    } else {
      _mostrarMensagem(
        "Ouro insuficiente! Você precisa de $precoEstalagem de ouro.",
      );
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
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.location_on, color: Colors.white38, size: 40),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- 1. IMAGEM DE FUNDO ---
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/vila_fundo.webp"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay escuro para destacar o conteúdo
          Container(color: Colors.black.withOpacity(0.3)),

          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // --- CABEÇALHO: NOME DA VILA EM CARD ---
              Card(
                elevation: 10,
                color: Colors.indigo[900]?.withOpacity(0.85),
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
                      Image.asset(
                        'assets/icons/vila.webp',
                        height: 32,
                        filterQuality: FilterQuality.none,
                      ),
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Text(
                          "Village",
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

              const SizedBox(height: 12),

              // --- STATUS NOBRE CENTRALIZADO ---
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Text(
                    "👑 ${widget.hero.tituloNobre}".toUpperCase(),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- CARD DA ESTALAGEM ---
              Card(
                color: Colors.grey[900]?.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/casa.webp',
                    width: 40,
                    height: 40,
                    filterQuality: FilterQuality.none,
                  ),
                  title: const Text(
                    "Estalagem do Descanso",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Recupere todo o seu HP\nCusto: $precoEstalagem Ouro",
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _descansar,
                    child: const Text(
                      "DESCANSAR",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // --- DEMAIS REGIÕES ---
              _regionCard(
                context,
                "Templo da Ancestralidade",
                "Evolua seu sangue e desperte novos poderes",
                "assets/icons/linhagem.webp",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LinhagemScreen(
                        hero: widget.hero,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  );
                },
              ),
              _regionCard(
                context,
                "Guilda",
                "Recompensas e missões de aventureiros",
                "assets/icons/guilda.webp",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuildScreen(
                        hero: widget.hero,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  );
                },
              ),
              _regionCard(
                context,
                "Chat",
                "Fale bem e chama geral pra porrada",
                "assets/icons/guilda.webp",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        hero: widget.hero,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  );
                },
              ),
              _regionCard(
                context,
                "Mural dos Lendários",
                "Contemple o Ranking Mundial de Heróis",
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
            ],
          ),

          // 🎁 PRESENTE ANIMADO NO CANTO SUPERIOR DIREITO
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: WigglingGift(hero: widget.hero, onUpdate: widget.onUpdate),
          ),
        ],
      ),
    );
  }
}

// 🎁 WIDGET DE ANIMAÇÃO DO PRESENTE
class WigglingGift extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const WigglingGift({super.key, required this.hero, required this.onUpdate});

  @override
  State<WigglingGift> createState() => _WigglingGiftState();
}

class _WigglingGiftState extends State<WigglingGift>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // A animação dura 2 segundos e fica repetindo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
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
        // Cálculo matemático para fazer ele tremer rápido e depois pausar.
        final progress = _controller.value;
        double angle = 0.0;

        // Só treme durante os primeiros 30% do tempo (para dar uma pausa natural depois)
        if (progress < 0.3) {
          angle = sin(progress * 8 * pi) * 0.2;
        }

        return Transform.rotate(angle: angle, child: child);
      },
      child: GestureDetector(
        onTap: () {
          // 🛒 NAVEGANDO PARA A LOJA E PASSANDO OS DADOS
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ShopScreen(hero: widget.hero, onUpdate: widget.onUpdate),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[800],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.card_giftcard,
            color: Colors.white,
            size: 28, // Tamanho ideal ajustado diretamente no ícone
          ),
        ),
      ),
    );
  }
}
