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
  // Widget de Card atualizado para exibir as imagens .webp que você criou
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
        // Exibe sua arte .webp (Chibi/Pixel) no lugar do ícone genérico
        leading: Container(
          width: 50,
          height: 50,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            // Mantém os pixels nítidos mesmo se a imagem original for pequena
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
      appBar: AppBar(
        title: const Text("Império de Asha | Mendes I"),
        backgroundColor: Colors.indigo[900]?.withOpacity(0.8),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. IMAGEM DE FUNDO (Capa do Império)
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

          // 2. CONTEÚDO DA INTERFACE
          Container(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Icon(Icons.fort_rounded, size: 60, color: Colors.white24),
                const SizedBox(height: 10),
                const Text(
                  "CAPITAL DO IMPÉRIO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
                const Text(
                  "Escolha o local que deseja visitar",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                  ),
                ),
                const SizedBox(height: 40),

                // NAVEGAÇÃO COM OS ÍCONES CUSTOMIZADOS
                _empireActionCard(
                  "Mercado Imperial",
                  "Venda seus materiais",
                  "assets/icons/mercado.webp",
                  Colors.blueAccent,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => MarketScreen(
                        hero: widget.hero,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  ),
                ),

                _empireActionCard(
                  "Sala do Trono",
                  "Audiência e Tributos",
                  "assets/icons/trono.webp",
                  Colors.purpleAccent,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => ThroneRoom(
                        hero: widget.hero,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  ),
                ),

                _empireActionCard(
                  "Ferreiro do Império",
                  "Melhore seus itens",
                  "assets/icons/ferreiro.webp",
                  Colors.orangeAccent,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => BlacksmithScreen(
                        hero: widget.hero,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  ),
                ),

                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    "\"Mendes se vangloria de seu súdito leal.\"",
                    style: TextStyle(
                      color: Colors.white38,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black)],
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
