import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'dart:math';

class BlacksmithScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const BlacksmithScreen({
    super.key,
    required this.hero,
    required this.onUpdate,
  });

  @override
  State<BlacksmithScreen> createState() => _BlacksmithScreenState();
}

class _BlacksmithScreenState extends State<BlacksmithScreen> {
  void _upgradeItem(Item item) {
    if (item.level >= 10) {
      _showErrorSnippet("Este item atingiu a perfeição (+10)!");
      return;
    }

    int custo = (item.level + 1) * 50;
    if (widget.hero.gold < custo) {
      _showErrorSnippet("Ouro insuficiente! O ferreiro não trabalha de graça.");
      return;
    }

    setState(() {
      widget.hero.gold -= custo;
      double chance = 1.0;

      if (item.level >= 2) {
        chance = (1.0 - ((item.level - 1) * 0.1)).clamp(0.1, 1.0);
      }

      bool sucesso = Random().nextDouble() <= chance;

      if (sucesso) {
        item.level += 1;
        _showSuccessSnippet("🔥 SUCESSO! ${item.displayName} forjado!");
      } else {
        if (item.level > 0) {
          item.level -= 1;
        }
        _showErrorSnippet(
          "⚡ FALHA! O metal trincou... (Regrediu para +${item.level})",
        );
      }
      widget.hero.calculateStats();
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final List<Item> upgradeableItems = _getUpgradeableItems();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          "FORJA DE VULCANO",
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2C0B00),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                "💰 ${widget.hero.gold}g",
                style: const TextStyle(color: Colors.amber, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: upgradeableItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: upgradeableItems.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) =>
                        _buildUpgradeCard(upgradeableItems[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF2C0B00), Colors.black.withOpacity(0.8)],
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/icons/anvil.webp',
            height: 70,
            filterQuality: FilterQuality.none,
          ),
          const SizedBox(height: 10),
          const Text(
            "\"O aço nunca mente.\"",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(Item item) {
    int custo = (item.level + 1) * 50;
    double chance = item.level < 2
        ? 1.0
        : (1.0 - ((item.level - 1) * 0.1)).clamp(0.1, 1.0);

    // Pegando dados dinâmicos do Item (ATK, DEF ou HP)
    final stat = item.mainStat;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF262626), Color(0xFF3D1400)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.level >= 5
              ? Colors.orange.withOpacity(0.5)
              : Colors.white10,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildItemIcon(item),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _statusMiniLabel(
                        stat["label"],
                        "${stat["value"]}",
                        stat["color"],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 10,
                          color: Colors.white24,
                        ),
                      ),
                      Text(
                        "${stat["next"]}",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _statusMiniLabel(
                    "CHANCE",
                    "${(chance * 100).toInt()}%",
                    _getChanceColor(chance),
                  ),
                ],
              ),
            ),
            _buildForgeButton(item, custo),
          ],
        ),
      ),
    );
  }

  Widget _buildItemIcon(Item item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        item.iconPath,
        width: 40,
        filterQuality: FilterQuality.none,
      ),
    );
  }

  Widget _buildForgeButton(Item item, int custo) {
    return SizedBox(
      width: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B0000),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _upgradeItem(item),
        child: Column(
          children: [
            const Icon(Icons.build, size: 18, color: Colors.white),
            Text(
              "${custo}g",
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Color _getChanceColor(double chance) {
    if (chance > 0.7) {
      return Colors.green;
    } else if (chance > 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _statusMiniLabel(String label, String value, Color color) {
    return Text(
      "$label: $value",
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Nada para forjar aqui...",
        style: TextStyle(color: Colors.white24),
      ),
    );
  }

  List<Item> _getUpgradeableItems() {
    final List<Item> list = [];
    list.addAll(
      widget.hero.warehouse.where(
        (i) => i.type != ItemType.material && i.type != ItemType.potion,
      ),
    );

    final equipped = [
      widget.hero.equippedWeapon,
      widget.hero.equippedArmor,
      widget.hero.equippedHelmet,
      widget.hero.equippedBoots,
      widget.hero.equippedNecklace,
      widget.hero.equippedRing,
      widget.hero.equippedRing2,
    ];

    for (var item in equipped) {
      if (item != null) {
        list.add(item);
      }
    }
    return list;
  }

  void _showSuccessSnippet(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange[800]),
    );
  }

  void _showErrorSnippet(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[900]),
    );
  }
}
