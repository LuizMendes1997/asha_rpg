import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("RANKING MUNDIAL"),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Buscamos os top 50 jogadores por nível e depois por exp
        future: _fetchRanking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum herói encontrado...",
                style: TextStyle(color: Colors.white24),
              ),
            );
          }

          final players = snapshot.data!;

          return ListView.builder(
            itemCount: players.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final player = players[index];
              final isTop3 = index < 3;

              return Card(
                color: isTop3
                    ? Colors.amber.withOpacity(0.1)
                    : Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: _buildRankBadge(index + 1),
                  title: Text(
                    player['username'] ?? "Desconhecido",
                    style: TextStyle(
                      color: isTop3 ? Colors.amber : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text("Linhagem Nível: ${player['nivel_linhagem']}"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Lvl ${player['level']}",
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${player['exp']} XP",
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Função que busca os dados no Supabase
  Future<List<Map<String, dynamic>>> _fetchRanking() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('profiles')
        .select('username, level, exp, nivel_linhagem')
        .order('level', ascending: false) // Primeiro por nível
        .order('exp', ascending: false) // Desempate por EXP
        .limit(50); // Top 50

    return List<Map<String, dynamic>>.from(response);
  }

  // Widget para mostrar a posição (1º, 2º, 3º com cores diferentes)
  Widget _buildRankBadge(int rank) {
    Color color = Colors.white24;
    if (rank == 1) color = Colors.amber;
    if (rank == 2) color = Colors.grey[400]!;
    if (rank == 3) color = Colors.orangeAccent;

    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          "$rank",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
