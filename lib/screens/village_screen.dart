import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'recruitment_screen.dart';
import 'finance_screen.dart';
import 'guild_screen.dart';
import 'LinhagemScreen.dart';

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
      // Removido o AppBar para usar o Card customizado dentro do body
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
                        'assets/icons/vila.webp', // Ícone da Vila
                        height: 32,
                        filterQuality: FilterQuality.none,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.hero.villageName.toUpperCase(),
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
                "Escritório de Finanças",
                "Gerencie impostos e alimentos",
                "assets/icons/financas.webp",
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

              _regionCard(
                context,
                "Praça da Vila",
                "Convide pessoas para morar aqui",
                "assets/icons/praca.webp",
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
              _regionCard(
                context,
                "Templo da Ancestralidade",
                "Evolua seu sangue e desperte novos poderes",
                "assets/icons/linhagem.webp", // Certifique-se de ter esse ícone ou use um temporário
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
                "assets/icons/guilda.webp", // Sugestão: troque para assets/icons/guilda.webp se tiver
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
