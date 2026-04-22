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
  // FUNÇÃO MÁGICA PARA A ANIMAÇÃO FLUTUANTE
  void _showFloatingText(String text, Color color) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _FloatingTextAnimation(
        text: text,
        color: color,
        onComplete: () => overlayEntry.remove(),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  void _upgradeItem(Item item) {
    if (item.level >= 10) {
      _showFloatingText("MAX!", Colors.grey);
      return;
    }

    int custo = (item.level + 1) * 50;
    if (widget.hero.gold < custo) {
      _showFloatingText("SEM OURO!", Colors.redAccent);
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
        _showFloatingText("+1", Colors.greenAccent);
      } else {
        if (item.level > 0) {
          item.level -= 1;
          _showFloatingText("-1", Colors.redAccent);
        } else {
          _showFloatingText("FALHOU!", Colors.orangeAccent);
        }
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

  // ... (Mantenha seus métodos _buildHeader, _buildItemIcon, _buildUpgradeCard, etc. iguais aos originais)
  // APENAS REMOVA AS FUNÇÕES _showSuccessSnippet e _showErrorSnippet lá debaixo.

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
          const Icon(
            Icons.gavel,
            size: 70,
            color: Colors.orangeAccent,
          ), // Usei icon pra não dar erro de asset
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
    final stat = item.mainStat;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF262626), Color(0xFF3D1400)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.level >= 5
              ? Colors.orange.withOpacity(0.5)
              : Colors.white10,
        ),
      ),
      child: ListTile(
        leading: Icon(Icons.shield_outlined, color: Colors.white),
        title: Text(
          item.displayName,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Chance: ${(chance * 100).toInt()}% | Custo: ${custo}g",
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B0000),
          ),
          onPressed: () => _upgradeItem(item),
          child: const Text(
            "FORJAR",
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
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
      if (item != null) list.add(item);
    }
    return list;
  }

  Widget _buildEmptyState() => const Center(
    child: Text("Nada para forjar...", style: TextStyle(color: Colors.white24)),
  );
}

// --- CLASSE DA ANIMAÇÃO (COLOQUE NO FINAL DO ARQUIVO) ---

class _FloatingTextAnimation extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onComplete;

  const _FloatingTextAnimation({
    required this.text,
    required this.color,
    required this.onComplete,
  });

  @override
  State<_FloatingTextAnimation> createState() => _FloatingTextAnimationState();
}

class _FloatingTextAnimationState extends State<_FloatingTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Se for sucesso (+1), sobe. Se for falha (-1), desce.
    double beginOffset =
        widget.text.contains("-") || widget.text.contains("FALHA") ? -20 : 20;

    _offsetAnimation = Tween<double>(
      begin: 0,
      end: -beginOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - 50, // Centralizado
      top: MediaQuery.of(context).size.height / 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _offsetAnimation.value),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(blurRadius: 10, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
