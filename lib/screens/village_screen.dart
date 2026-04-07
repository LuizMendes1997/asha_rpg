import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'recruitment_screen.dart';
import 'finance_screen.dart';
import 'guild_screen.dart';

class VillageScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const VillageScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<VillageScreen> createState() => _VillageScreenState();
}

class _VillageScreenState extends State<VillageScreen> {
  final int precoEstalagem = 15;

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

  // --- FUNÇÃO ATUALIZADA PARA ACEITAR IMAGEM ---
  Widget _regionCard(
    BuildContext context,
    String title,
    String subtitle,
    String imagePath, // Mudamos para String
    VoidCallback onTap,
  ) {
    return Card(
      color: Colors.grey[900]?.withOpacity(0.85),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 40,
          height: 40,
          filterQuality: FilterQuality.none, // Pixel art nítido
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
      appBar: AppBar(
        title: const Text("Vila Kalirian"),
        backgroundColor: Colors.brown[900]?.withOpacity(0.9),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // --- 1. IMAGEM DE FUNDO (WEBP) ---
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

          Container(color: Colors.black.withOpacity(0.3)),

          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "STATUS: ${widget.hero.tituloNobre}".toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // CARD DA ESTALAGEM (JÁ COM IMAGEM)
              Card(
                color: Colors.grey[900]?.withOpacity(0.85),
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
                    ),
                    onPressed: _descansar,
                    child: const Text("DESCANSAR"),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // CARD FINANCEIRO (AGORA COM IMAGEM)
              _regionCard(
                context,
                "Escritório de Finanças",
                "Gerencie impostos e alimentos",
                "assets/icons/financas.webp", // Ajuste o nome do arquivo se necessário
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => FinanceScreen(
                        hero: widget.hero,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  );
                },
              ),

              // CARD DE RECRUTAMENTO (AGORA COM IMAGEM)
              _regionCard(
                context,
                "Praça da Vila",
                "Convide pessoas para morar aqui",
                "assets/icons/praca.webp", // Ajuste o nome do arquivo se necessário
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecruitmentScreen(
                        hero: widget.hero,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  );
                },
              ),

              // Dentro do build da VillageScreen
              _regionCard(
                context,
                "Guilda",
                "Os aventureiros se juntam para recolher recompensas de suas missões",
                "assets/icons/praca.webp", // Ajuste o nome do arquivo se necessário
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
            ],
          ),
        ],
      ),
    );
  }
}
