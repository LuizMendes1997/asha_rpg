import 'package:flutter/material.dart';
import '../models/game_state.dart';

class LinhagemScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const LinhagemScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<LinhagemScreen> createState() => _LinhagemScreenState();
}

class _LinhagemScreenState extends State<LinhagemScreen> {
  int get custoEvolucao => widget.hero.nivelLinhagem * 2;
  int get custoFragmentos => widget.hero.nivelLinhagem * 3;
  int get usuariogold => widget.hero.gold;

  int get fragmentosAtuais {
    return widget.hero.warehouse
        .where((item) => item.name == "Fragmentos Divinos")
        .fold(0, (soma, item) => soma + item.quantity);
  }

  // Lógica para as 5 estrelas: 1 a 5, resetando a cada patamar
  int get estrelasProgresso {
    int progresso = widget.hero.nivelLinhagem % 5;
    return (progresso == 0 && widget.hero.nivelLinhagem > 0) ? 5 : progresso;
  }

  void _tentarEvoluir() {
    if (widget.hero.gold >= custoEvolucao &&
        fragmentosAtuais >= custoFragmentos) {
      setState(() {
        widget.hero.gold -= custoEvolucao;
        int removidos = 0;

        for (int i = widget.hero.warehouse.length - 1; i >= 0; i--) {
          var item = widget.hero.warehouse[i];
          if (item.name == "Fragmentos Divinos") {
            int faltaRemover = custoFragmentos - removidos;
            if (item.quantity <= faltaRemover) {
              removidos += item.quantity;
              widget.hero.warehouse.removeAt(i);
            } else {
              item.quantity -= faltaRemover;
              removidos += faltaRemover;
            }
          }
          if (removidos >= custoFragmentos) break;
        }
        widget.hero.evoluirLinhagem();
      });

      widget.onUpdate();
      widget.hero.saveToSupabase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Linhagem elevada para: ${widget.hero.nomeTituloLinhagem}!",
          ),
          backgroundColor: Colors.amber[900],
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      String msg = widget.hero.gold < custoEvolucao
          ? "Ouro insuficiente."
          : "Fragmentos insuficientes.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color racaColor;
    IconData racaIcon;

    switch (widget.hero.raca) {
      case Raca.dragoniano:
        racaColor = Colors.orangeAccent;
        racaIcon = Icons.local_fire_department_rounded;
        break;
      case Raca.elfo:
        racaColor = Colors.cyanAccent;
        racaIcon = Icons.auto_awesome;
        break;
      default:
        racaColor = Colors.redAccent;
        racaIcon = Icons.shield_moon_rounded;
    }

    Color tituloColor = widget.hero.nivelLinhagem >= 15
        ? Colors.amber
        : racaColor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("TEMPLO DA ANCESTRALIDADE"),
        backgroundColor: Colors.indigo[900]?.withOpacity(0.3),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/lineage_bg.webp"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: tituloColor.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: tituloColor, width: 3),
                          color: Colors.black45,
                        ),
                        child: Icon(racaIcon, size: 70, color: tituloColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // SISTEMA DE ESTRELAS (1 a 5)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    bool ativa = index < estrelasProgresso;
                    return Icon(
                      ativa ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: ativa ? tituloColor : Colors.white10,
                      size: 32,
                      shadows: ativa
                          ? [Shadow(color: tituloColor, blurRadius: 10)]
                          : null,
                    );
                  }),
                ),

                const SizedBox(height: 15),
                Text(
                  widget.hero.nomeTituloLinhagem.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tituloColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 15,
                        color: tituloColor.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Nível de Linhagem: ${widget.hero.nivelLinhagem}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "PODER HERDADO",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildStatRow(
                        "Bônus de Força",
                        "+${widget.hero.bonusSTR}",
                        Colors.orangeAccent,
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      _buildStatRow(
                        "Bônus de Defesa",
                        "+${widget.hero.bonusDEF}",
                        Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  height: 85,
                  margin: const EdgeInsets.only(bottom: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[900]?.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: tituloColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      elevation: 10,
                    ),
                    onPressed: _tentarEvoluir,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "ELEVAR LINHAGEM",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Fragmentos: $fragmentosAtuais / $custoFragmentos",
                                  style: TextStyle(
                                    color: fragmentosAtuais >= custoFragmentos
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Ouro: $usuariogold / $custoEvolucao",
                                  style: TextStyle(
                                    color: widget.hero.gold >= custoEvolucao
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 5, color: color.withOpacity(0.5))],
          ),
        ),
      ],
    );
  }
}
