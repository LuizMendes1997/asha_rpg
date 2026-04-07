import 'package:flutter/material.dart';
import 'package:asha_rpg/models/game_state.dart';
import 'package:asha_rpg/models/quest_model.dart';

class GuildScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;
  const GuildScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends State<GuildScreen> {
  // Exemplo de missões disponíveis (Pode vir de um arquivo de dados depois)
  List<Quest> availableQuests = [
    Quest(
      title: "Infestação de Slimes",
      description: "Acabe com 5 Slimes que aterrorizam a horta.",
      targetMonsterName: "Slime",
      requiredKillCount: 5,
      rewardGold: 100,
      rewardExp: 50,
    ),
    Quest(
      title: "O Terror Noturno",
      description: "Cace 2 Lobos Famintos na floresta.",
      targetMonsterName: "Lobo",
      requiredKillCount: 2,
      rewardGold: 250,
      rewardExp: 120,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Guilda de Caçadores"),
        backgroundColor: Colors.brown[900],
      ),
      body: ListView.builder(
        itemCount: availableQuests.length,
        itemBuilder: (context, index) {
          final quest = availableQuests[index];
          bool jaPegou = widget.hero.activeQuests.any(
            (q) => q.title == quest.title,
          );

          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                quest.title,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "${quest.description}\nRecompensa: ${quest.rewardGold}g",
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: jaPegou
                  ? const Text(
                      "EM ANDAMENTO",
                      style: TextStyle(color: Colors.blue),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.hero.activeQuests.add(quest);
                        });
                        widget.onUpdate();
                      },
                      child: const Text("ACEITAR"),
                    ),
            ),
          );
        },
      ),
    );
  }
}
