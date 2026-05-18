import 'package:flutter/material.dart';
import 'dart:async'; // Necessário para o Timer
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
  bool _isFerreiroLocked = false;
  bool _showFerreiroAngry = false;

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

  // Lógica do clique com trava e overlay unificado
  void _handleFerreiroClick() {
    if (_isFerreiroLocked)
      return; // Ignora cliques repetidos se estiver travado

    if (widget.hero.totalDoado < 450) {
      setState(() {
        _isFerreiroLocked = true;
        _showFerreiroAngry = true;
      });

      // Esconde o overlay e libera o botão exatamente após 3 segundos
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showFerreiroAngry = false;
            _isFerreiroLocked = false;
          });
        }
      });
    } else {
      _goTo(
        context,
        BlacksmithScreen(hero: widget.hero, onUpdate: widget.onUpdate),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. IMAGEM DE FUNDO
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
                _buildHeader(),
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
                  ),
                ),
                const Text(
                  "Escolha o local que deseja visitar",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 30),

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
                  _handleFerreiroClick,
                ),

                const Spacer(),
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

          // 3. OVERLAY DO ANÃO MANDANDO SUMIR (Imagem + Frase juntas na tela)
          if (_showFerreiroAngry)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(
                  0.8,
                ), // Escurece o fundo do mapa
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orangeAccent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/icons/ferreiros.webp",
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Drax:",
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "\"Você não é digno da minha forja, não ligo para plebeus que não ajudam meu imperador. Vire um conde pelo menos.\"",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 4. BOTÃO VOLTAR
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

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_rounded, color: Colors.white38, size: 22),
          SizedBox(width: 12),
          Column(
            children: [
              Text(
                "IMPÉRIO DE ASHA",
                style: TextStyle(color: Colors.white60, fontSize: 10),
              ),
              Text(
                "MENDES I",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(width: 12),
          Icon(Icons.workspace_premium, color: Colors.amber, size: 24),
        ],
      ),
    );
  }

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => screen));
  }
}
