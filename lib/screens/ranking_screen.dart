import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  // 0: Level, 1: Linhagem, 2: Missões, 3: Torre, 4: Guilda
  int _currentTabIndex = 0;

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
        future: _fetchRankingData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum registro encontrado...",
                style: TextStyle(color: Colors.white24),
              ),
            );
          }

          final allItems = snapshot.data!;
          final top3 = allItems.take(3).toList();
          final remainingItems = allItems.skip(3).toList();

          return Column(
            children: [
              const SizedBox(height: 16),
              // 🏆 CONSTRÓI O PÓDIO OLÍMPICO NO TOPO
              _buildOlympicPodium(top3),
              const Divider(color: Colors.white10, height: 24, thickness: 1),

              // 📜 LISTÃO REUTILIZÁVEL (Do 4º colocado em diante)
              Expanded(
                child: ListView.builder(
                  itemCount: remainingItems.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (context, index) {
                    final item = remainingItems[index];
                    final trueRank = index + 4;

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                "$trueRank",
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign
                                    .center, // CORRIGIDO: De Alignment para TextAlign
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildAvatar(item['emblema'], size: 36),
                          ],
                        ),
                        title: Text(
                          item['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          item['subtitle'],
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        trailing: Text(
                          item['score'],
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.grey[900]),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) => setState(() => _currentTabIndex = index),
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.white38,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.star), label: "Level"),
            BottomNavigationBarItem(
              icon: Icon(Icons.bloodtype),
              label: "Linhagem",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in),
              label: "Missões",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.fort), label: "Torre"),
            BottomNavigationBarItem(icon: Icon(Icons.shield), label: "Guilda"),
          ],
        ),
      ),
    );
  }

  // 📥 Busca e normaliza os dados de tabelas diferentes
  Future<List<Map<String, dynamic>>> _fetchRankingData() async {
    final supabase = Supabase.instance.client;
    List<dynamic> rawData = [];

    if (_currentTabIndex == 4) {
      final res = await supabase
          .from('clans')
          .select('name, emblema_path, total_damage_score')
          .order('total_damage_score', ascending: false)
          .limit(50);
      rawData = res;
    } else {
      String primaryOrder = 'level';
      String? secondaryOrder = 'exp';

      if (_currentTabIndex == 1) {
        primaryOrder = 'nivel_linhagem';
        secondaryOrder = 'level';
      }
      if (_currentTabIndex == 2) {
        primaryOrder = 'missoes_completadas';
        secondaryOrder = null;
      }
      if (_currentTabIndex == 3) {
        primaryOrder = 'max_tower_floor';
        secondaryOrder = null;
      }

      // CORRIGIDO: Mudado de 'var' para 'dynamic' para evitar o erro de PostgrestTransformBuilder
      dynamic query = supabase
          .from('profiles')
          .select(
            'username, emblema_path, level, exp, nivel_linhagem, missoes_completadas, max_tower_floor',
          );

      if (secondaryOrder != null) {
        query = query
            .order(primaryOrder, ascending: false)
            .order(secondaryOrder, ascending: false);
      } else {
        query = query.order(primaryOrder, ascending: false);
      }

      rawData = await query.limit(50);
    }

    return rawData.map((item) {
      final isClan = _currentTabIndex == 4;
      String name = isClan
          ? (item['name'] ?? 'Clã Sem Nome')
          : (item['username'] ?? 'Desconhecido');
      String? emblema = item['emblema_path'];
      String score = '';
      String subtitle = '';

      switch (_currentTabIndex) {
        case 0:
          score = "Lvl ${item['level']}";
          subtitle = "${item['exp']} XP";
          break;
        case 1:
          score = "Linhagem Lvl ${item['nivel_linhagem']}";
          subtitle = "Herói de Lvl ${item['level']}";
          break;
        case 2:
          score = "${item['missoes_completadas'] ?? 0} Feitas";
          subtitle = "Missões Diárias e História";
          break;
        case 3:
          score = "Andar ${item['max_tower_floor'] ?? 0}";
          subtitle = "Recorde na Torre do Caos";
          break;
        case 4:
          score = "${item['total_damage_score'] ?? 0} Pts";
          subtitle = "Poder de Ataque de Clã";
          break;
      }

      return {
        'name': name,
        'emblema': emblema,
        'score': score,
        'subtitle': subtitle,
      };
    }).toList();
  }

  // 🏛️ MONTAGEM DO PÓDIO OLÍMPICO (Visual estilizado iIi)
  Widget _buildOlympicPodium(List<Map<String, dynamic>> top3) {
    final has1st = top3.isNotEmpty;
    final has2nd = top3.length > 1;
    final has3rd = top3.length > 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment
            .end, // CORRIGIDO: De CrossAxisAlignment.bottom para .end
        children: [
          // 🥈 2º LUGAR (Esquerda)
          Expanded(
            child: has2nd
                ? _buildPodiumColumn(
                    item: top3[1],
                    rank: 2,
                    height: 110,
                    color: const Color(0xFFC0C0C0),
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 12),

          // 🥇 1º LUGAR (Centro)
          Expanded(
            child: has1st
                ? _buildPodiumColumn(
                    item: top3[0],
                    rank: 1,
                    height: 145,
                    color: const Color(0xFFFFD700),
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 12),

          // 🥉 3º LUGAR (Direita)
          Expanded(
            child: has3rd
                ? _buildPodiumColumn(
                    item: top3[2],
                    rank: 3,
                    height: 95,
                    color: const Color(0xFFCD7F32),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required Map<String, dynamic> item,
    required int rank,
    required double height,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvatar(item['emblema'], size: rank == 1 ? 64 : 52),
        const SizedBox(height: 8),

        Text(
          item['name'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),

        Text(
          item['score'],
          maxLines: 1,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.4), color.withOpacity(0.05)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border(
              top: BorderSide(color: color, width: 3),
              left: BorderSide(color: color.withOpacity(0.3), width: 1),
              right: BorderSide(color: color.withOpacity(0.3), width: 1),
            ),
          ),
          child: Center(
            child: Text(
              "$rankº",
              // CORRIGIDO: Removido o parâmetro inexistente 'shadowColors'
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? path, {required double size}) {
    if (path == null || path.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[800],
        child: Icon(Icons.person, color: Colors.white38, size: size * 0.5),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: ClipOval(
        child: path.startsWith('http')
            ? Image.network(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, color: Colors.white38),
              )
            : Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, color: Colors.white38),
              ),
      ),
    );
  }
}
