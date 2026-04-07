import 'package:flutter/material.dart';
import '../models/game_state.dart';

class RecruitmentScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const RecruitmentScreen({
    super.key,
    required this.hero,
    required this.onUpdate,
  });

  @override
  State<RecruitmentScreen> createState() => _RecruitmentScreenState();
}

class _RecruitmentScreenState extends State<RecruitmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Centro de População"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _statusCard(),
            const SizedBox(height: 20),
            const Text(
              "PESSOAS DISPONÍVEIS",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white24),

            _recruitTile(
              name: widget.hero.tituloNobre,
              description: "Se quiser, eu te defendo dos monstros!",
              limit:
                  "${widget.hero.populacaoMendigos} / ${widget.hero.limiteMendigos}",
              icon: Icons.person_outline,
              onTap: () {
                if (widget.hero.adicionarMendigo()) {
                  setState(() {});
                  widget.onUpdate(); // Atualiza o HP no HUD global
                  _msg("Uma pessoa se juntou à vila! +1 HP");
                } else {
                  _msg(
                    "Limite de pessoas atingido! Implore para seu imperador um novo titulo.",
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            "População Total",
            "${widget.hero.populacaoCidadaos + widget.hero.populacaoMendigos}",
          ),
          _statItem(
            "Bônus de HP",
            "+${widget.hero.populacaoCidadaos + widget.hero.populacaoMendigos}",
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _recruitTile({
    required String name,
    required String description,
    required String limit,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.grey[900],
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 30),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "$description\nLimite: $limit",
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          child: const Text("CONVIDAR"),
        ),
      ),
    );
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }
}
