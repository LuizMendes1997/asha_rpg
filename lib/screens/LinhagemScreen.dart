import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../data/item_data.dart';

class LinhagemScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const LinhagemScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<LinhagemScreen> createState() => _LinhagemScreenState();
}

class _LinhagemScreenState extends State<LinhagemScreen> {
  // Custo de evolução: Nível 1->2 (1000), 2->3 (2000), etc.
  int get custoEvolucao => widget.hero.nivelLinhagem * 2;
  int get custoFragmentos => widget.hero.nivelLinhagem * 3;
  int get usuariogold => widget.hero.gold;
  int get fragmentosAtuais {
    return widget.hero.warehouse
        .where((item) => item.name == "Fragmentos Divinos")
        .fold(0, (soma, item) => soma + item.quantity);
  }

  void _tentarEvoluir() {
    if (widget.hero.gold >= custoEvolucao &&
        fragmentosAtuais >= custoFragmentos) {
      setState(() {
        // 1. Paga o ouro
        widget.hero.gold -= custoEvolucao;

        // 2. Tira os fragmentos da warehouse (FORMA SEGURA)
        int removidos = 0;

        for (int i = widget.hero.warehouse.length - 1; i >= 0; i--) {
          var item = widget.hero.warehouse[i];

          if (item.name == "Fragmentos Divinos") {
            int faltaRemover = custoFragmentos - removidos;

            if (item.quantity <= faltaRemover) {
              // O slot atual tem menos ou o exato que precisamos: remove o slot todo
              removidos += item.quantity;
              widget.hero.warehouse.removeAt(i);
            } else {
              // O slot tem MAIS do que precisamos: apenas subtrai a quantidade
              item.quantity -= faltaRemover;
              removidos += faltaRemover;
            }
          }

          // Se já atingiu o custo, para o loop
          if (removidos >= custoFragmentos) break;
        }

        // 3. Evolui o nível
        widget.hero.evoluirLinhagem();
      });

      widget.onUpdate();

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
      // Dica: Ajustei a mensagem para mostrar o que falta
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
    // Configurações visuais baseadas na raça
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
      default: // Humano
        racaColor = Colors.redAccent;
        racaIcon = Icons.shield_moon_rounded;
    }

    // Cor especial para patamares lendários (Santo/Deus)
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
          // Fundo de Imagem (Background do Templo)
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

                // Representação Visual da Linhagem
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Brilho de fundo
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
                      // Ícone Central
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

                const SizedBox(height: 30),

                // Nomes e Títulos
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

                const SizedBox(height: 40),

                // Painel de Atributos
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

                // Botão de Evolução
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
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Alinha os textos à esquerda
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
                                const SizedBox(
                                  height: 4,
                                ), // Pequeno espaço entre os dois textos
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
