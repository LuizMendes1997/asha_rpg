import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'village_screen.dart';
import 'world_map.dart';
import 'empire_screen.dart';
import 'inventory_screen.dart';

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
      InventoryScreen(hero: widget.hero, onUpdate: _refresh),
      EmpireScreen(hero: widget.hero, onUpdate: _refresh),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // --- NOVO HUD ESTILIZADO EM CARD ---
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900]?.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Badge do Level
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            "LVL ${widget.hero.level}",
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        // Badge do Ouro
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/gold_coin.webp',
                                height: 16,
                                filterQuality: FilterQuality.none,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${widget.hero.gold}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Barras de Status
                    _buildStatBar(
                      "HP: ${widget.hero.hp}/${widget.hero.totalMaxHp}",
                      widget.hero.hp / widget.hero.totalMaxHp,
                      Colors.red[900]!,
                      Colors.redAccent,
                      Icons.favorite,
                    ),
                    const SizedBox(height: 8),
                    _buildStatBar(
                      "EXP: ${widget.hero.exp}/${widget.hero.nextLevelExp}",
                      widget.hero.exp / widget.hero.nextLevelExp,
                      Colors.blue[900]!,
                      Colors.cyan,
                      Icons.star,
                    ),
                  ],
                ),
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
        onTap: (index) {
          if (index == 1 && widget.hero.hp <= 0) {
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
        type: BottomNavigationBarType.fixed,
        items: [
          itemMenu('assets/icons/vila.webp', 'Vila'),
          itemMenu('assets/icons/mundo.webp', 'Mundo'),
          itemMenu('assets/icons/bolsa.webp', 'Bolsa'),
          itemMenu('assets/icons/imperio.webp', 'Império'),
        ],
      ),
    );
  }

  Widget _buildStatBar(
    String label,
    double progress,
    Color c1,
    Color c2,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: c1.withOpacity(0.8), size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.white10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [c1, c2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: c1.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                    ),
                  ),
                ),
              ),
            ],
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
