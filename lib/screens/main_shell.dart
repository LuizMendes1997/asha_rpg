import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'village_screen.dart';
import 'world_map.dart';
import 'empire_screen.dart';
import 'inventory_screen.dart'; // Vamos criar essa!

class MainShell extends StatefulWidget {
  final HeroModel hero;
  const MainShell({super.key, required this.hero});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      VillageScreen(hero: widget.hero, onUpdate: _refresh),
      WorldMap(hero: widget.hero, onUpdate: _refresh),
      InventoryScreen(hero: widget.hero, onUpdate: _refresh), // A BOLSA
      EmpireScreen(hero: widget.hero, onUpdate: _refresh),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // --- HUD SEM O RAIO ---
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[900],
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "LVL ${widget.hero.level}",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/gold_coin.webp', // Seu ícone 32x32
                            height: 18,
                            filterQuality:
                                FilterQuality.none, // Mantém o pixel art nítido
                          ),

                          Text(
                            " ${widget.hero.gold}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildStatBar(
                    "HP: ${widget.hero.hp}/${widget.hero.totalMaxHp}",
                    widget.hero.hp / widget.hero.maxHp,
                    Colors.red[900]!,
                    Colors.redAccent,
                  ),
                  const SizedBox(height: 5),
                  _buildStatBar(
                    "EXP: ${widget.hero.exp}/${widget.hero.nextLevelExp}",
                    widget.hero.exp / widget.hero.nextLevelExp,
                    Colors.blue[900]!,
                    Colors.cyan,
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _screens),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white60,
        currentIndex: _selectedIndex,
        // Mude o onTap do seu BottomNavigationBar para isto:
        onTap: (index) {
          if (index == 1 && widget.hero.hp <= 0) {
            // Se tentar ir para o Mundo com 0 HP
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Você está exausto! Descanse na Vila antes de partir.",
                ),

                duration: Duration(seconds: 2),
              ),
            );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed, // Mantém o fixo para 4 itens
        items: [
          // <--- REMOVI O 'const' DAQUI
          itemMenu('assets/icons/vila.webp', 'Vila'),
          itemMenu('assets/icons/mundo.webp', 'Mundo'),
          itemMenu('assets/icons/bolsa.webp', 'Bolsa'),
          itemMenu('assets/icons/imperio.webp', 'Império'),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, double progress, Color c1, Color c2) {
    return Stack(
      children: [
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c1, c2]),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  BottomNavigationBarItem itemMenu(String path, String label) {
    return BottomNavigationBarItem(
      icon: Image.asset(path, height: 26, filterQuality: FilterQuality.none),
      label: label,
    );
  }
}
