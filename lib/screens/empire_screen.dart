import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'market_screen.dart';
import 'throne_room.dart';
import 'blacksmith_screen.dart';

class EmpireScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;
  const EmpireScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<EmpireScreen> createState() => _EmpireScreenState();
}

class _EmpireScreenState extends State<EmpireScreen> {
  // Widget de Card customizado para as ações do Império
  Widget _empireActionCard(
    String title,
    String sub,
    String imagePath,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      color: Colors.indigo[900]?.withOpacity(0.4),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: SizedBox(
          width: 50,
          height: 50,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          sub,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        onTap: onTap,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white24,
          size: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. IMAGEM DE FUNDO (Full Screen)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/empire_bg.webp"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),

          // 2. CONTEÚDO PRINCIPAL
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // HEADER ESTILIZADO (Nome do Imperador)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        color: Colors.white38,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Text(
                            "IMPÉRIO DE ASHA",
                            style: TextStyle(
                              color: Colors.amber[100]?.withOpacity(0.8),
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "MENDES I",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(blurRadius: 10, color: Colors.orange),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.workspace_premium,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Icon(Icons.fort_rounded, size: 50, color: Colors.white24),
                const SizedBox(height: 10),
                const Text(
                  "CAPITAL DO IMPÉRIO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
                const Text(
                  "Escolha o local que deseja visitar",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 30),

                // LISTA DE LOCAIS (Navegação)
                _empireActionCard(
                  "Mercado Imperial",
                  "Venda seus materiais",
                  "assets/icons/mercado.webp",
                  Colors.blueAccent,
                  () => _goTo(
                    context,
                    MarketScreen(hero: widget.hero, onUpdate: widget.onUpdate),
                  ),
                ),

                _empireActionCard(
                  "Sala do Trono",
                  "Audiência e Tributos",
                  "assets/icons/trono.webp",
                  Colors.purpleAccent,
                  () => _goTo(
                    context,
                    ThroneRoom(hero: widget.hero, onUpdate: widget.onUpdate),
                  ),
                ),

                _empireActionCard(
                  "Ferreiro do Império",
                  "Melhore seus itens",
                  "assets/icons/ferreiro.webp",
                  Colors.orangeAccent,
                  () => _goTo(
                    context,
                    BlacksmithScreen(
                      hero: widget.hero,
                      onUpdate: widget.onUpdate,
                    ),
                  ),
                ),

                const Spacer(),

                // RODAPÉ COM LORE
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "\"Mendes se vangloria de seu súdito leal.\"",
                    style: TextStyle(
                      color: Colors.white30,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. BOTÃO VOLTAR (Customizado no topo esquerdo)
          Positioned(
            top: 50,
            left: 15,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para navegação limpa
  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => screen));
  }
}
