import 'package:flutter/material.dart';
import '../models/game_state.dart';

class ThroneRoom extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const ThroneRoom({super.key, required this.hero, required this.onUpdate});

  @override
  State<ThroneRoom> createState() => _ThroneRoomState();
}

class _ThroneRoomState extends State<ThroneRoom> {
  final TextEditingController _tributeController = TextEditingController();

  void _oferecerTributo() {
    int? valor = int.tryParse(_tributeController.text);
    if (valor != null && valor > 0 && widget.hero.gold >= valor) {
      setState(() {
        widget.hero.doar(valor);
        // Ao doar, o limite de mendigos sobe baseado no novo título
        _tributeController.clear();
      });
      widget.onUpdate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "O Imperador agora te vê como um ${widget.hero.tituloNobre}!",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Audiência Real"),
        backgroundColor: Colors.purple[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.workspace_premium,
              size: 80,
              color: Colors.purpleAccent,
            ),
            Text(
              widget.hero.tituloNobre,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Total Oferecido: ${widget.hero.totalDoado}g",
              style: const TextStyle(color: Colors.amber, fontSize: 16),
            ),
            const Divider(color: Colors.white24, height: 40),
            const Text(
              "QUANTO DESEJA OFERECER AO IMPERADOR?",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tributeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Quantidade de Ouro",
                hintStyle: TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[900],
                ),
                onPressed: _oferecerTributo,
                child: const Text(
                  "OFERECER TRIBUTO",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _infoRank("Próximo Nível", _getProximoRankInfo()),
          ],
        ),
      ),
    );
  }

  String _getProximoRankInfo() {
    if (widget.hero.totalDoado < 450) return "Conde (450g)";
    if (widget.hero.totalDoado < 1000) return "Duque (1000g)";
    if (widget.hero.totalDoado < 5000) return "Arquiduque (5000g)";
    if (widget.hero.totalDoado < 10000) return "Príncipe (10000g)";
    if (widget.hero.totalDoado < 30000) return "Rei (30000g)";
    return "Nível Máximo Atingido";
  }

  Widget _infoRank(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
