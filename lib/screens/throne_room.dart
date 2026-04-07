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
        _tributeController.clear();
      });
      widget.onUpdate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O Imperador aceitou sua oferta!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final proximoRankIdx = widget.hero.rankNobre + 1;
    final temProximo = proximoRankIdx < HeroModel.requisitosNobreza.length;
    final requisitos = temProximo
        ? HeroModel.requisitosNobreza[proximoRankIdx]
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Audiência Real"),
        backgroundColor: Colors.purple[900],
      ),
      body: SingleChildScrollView(
        // Para não quebrar com o teclado
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.workspace_premium,
              size: 80,
              color: Colors.purpleAccent,
            ),
            Text(
              "Título: ${widget.hero.tituloNobre}",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Total Doado: ${widget.hero.totalDoado}g",
              style: const TextStyle(color: Colors.amber),
            ),

            const Divider(color: Colors.white24, height: 40),

            // PARTE DE DOAR TRIBUTO
            const Text(
              "ENTREGAR TRIBUTO AO IMPERADOR",
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
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[900],
              ),
              onPressed: _oferecerTributo,
              child: const Text(
                "OFERECER OURO",
                style: TextStyle(color: Colors.black),
              ),
            ),

            const Divider(color: Colors.white24, height: 40),

            // PARTE DE ASCENSÃO
            if (temProximo) ...[
              Text(
                "Próximo Nível: ${requisitos!['titulo']}",
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                "Necessário ter doado: ${requisitos['minDoado']}g",
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: widget.hero.totalDoado >= requisitos['minDoado']
                    ? () {
                        setState(() {
                          widget.hero.rankNobre++;
                          widget.hero.tituloNobre = requisitos['titulo'];
                        });
                        widget.onUpdate();
                      }
                    : null,
                child: const Text("PEDIR ASCENSÃO DE RANK"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
