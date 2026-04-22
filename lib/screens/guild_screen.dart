import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/quest_model.dart';

class GuildScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const GuildScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends State<GuildScreen> {
  // Lista de missões que a guilda oferece
  final List<Quest> availableQuests = [
    Quest(
      title: "Infestação de Ratos",
      description: "Acabe com 5 ratos que estão roendo os estoques.",
      targetMonsterName: "rato",
      requiredKillCount: 5,
      rewardGold: 100,
      rewardExp: 50,
    ),
    Quest(
      title: "O Terror Noturno",
      description: "Cace 2 cobras que estão rondando a vila.",
      targetMonsterName: "cobra",
      requiredKillCount: 2,
      rewardGold: 250,
      rewardExp: 120,
    ),
    Quest(
      title: "Caça ao Lobo Alpha",
      description: "Elimine o lobo que lidera a alcateia.",
      targetMonsterName: "lobo",
      requiredKillCount: 1,
      rewardGold: 500,
      rewardExp: 300,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text(
          "GUILDA DE CAÇADORES",
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2C1B10),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                "💰 ${widget.hero.gold}g",
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBanner(),
          Expanded(
            child: ListView.builder(
              itemCount: availableQuests.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final quest = availableQuests[index];

                // Busca se essa missão já está com o herói
                final activeQuestIndex = widget.hero.activeQuests.indexWhere(
                  (q) => q.title == quest.title,
                );

                bool jaPegou = activeQuestIndex != -1;
                Quest? questEmAndamento = jaPegou
                    ? widget.hero.activeQuests[activeQuestIndex]
                    : null;
                bool prontoParaEntregar =
                    jaPegou &&
                    questEmAndamento!.currentKillCount >=
                        questEmAndamento.requiredKillCount;

                return _buildQuestCard(
                  quest,
                  jaPegou,
                  prontoParaEntregar,
                  questEmAndamento,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A120B),
        border: Border(bottom: BorderSide(color: Colors.amber, width: 0.5)),
      ),
      child: const Column(
        children: [
          Icon(Icons.shield, size: 50, color: Colors.amber),
          SizedBox(height: 10),
          Text(
            "\"Traga as cabeças, leve o ouro.\"",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(
    Quest questOriginal,
    bool jaPegou,
    bool pronto,
    Quest? active,
  ) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: pronto ? Colors.green.withOpacity(0.5) : Colors.white10,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questOriginal.title,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    jaPegou
                        ? "Progresso: ${active!.currentKillCount} / ${active.requiredKillCount}"
                        : questOriginal.description,
                    style: TextStyle(
                      color: jaPegou ? Colors.blueAccent : Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Recompensa: ${questOriginal.rewardGold}g | ${questOriginal.rewardExp}xp",
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            _buildActionButton(questOriginal, jaPegou, pronto, active),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    Quest questOriginal,
    bool jaPegou,
    bool pronto,
    Quest? active,
  ) {
    if (pronto) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
        onPressed: () {
          setState(() {
            widget.hero.gold += active!.rewardGold;
            widget.hero.gainExp(active.rewardExp);
            widget.hero.activeQuests.remove(active); // Entrega e remove
          });
          widget.onUpdate();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Missão Finalizada! Recompensas recebidas."),
            ),
          );
        },
        child: const Text("RECEBER", style: TextStyle(color: Colors.white)),
      );
    }

    if (jaPegou) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          "EM CURSO",
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4E342E)),
      onPressed: () {
        setState(() {
          widget.hero.activeQuests.add(questOriginal.copy());
        });
        widget.onUpdate();
      },
      child: const Text("ACEITAR", style: TextStyle(color: Colors.white)),
    );
  }
}
