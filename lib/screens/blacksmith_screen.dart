import 'package:flutter/material.dart';
import '../models/game_state.dart'; // Ajuste para o seu caminho real
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
  // --- LÓGICA DE OVERLAY PARA TEXTO FLUTUANTE ---
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

  // --- LÓGICA DE APRIMORAMENTO ---
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

      // Chance: 100% até o +2, depois cai 10% por nível
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
    widget.hero.saveToSupabase();
  }

  @override
  Widget build(BuildContext context) {
    final List<Item> upgradeableItems = _getSortedItems();

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
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
      child: const Column(
        children: [
          Icon(Icons.gavel, size: 50, color: Colors.orangeAccent),
          SizedBox(height: 10),
          Text(
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
    final statData = item.mainStat;
    final bool isEquipped = _isItemEquipped(item);
    int custo = (item.level + 1) * 50;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEquipped ? Colors.green.withOpacity(0.5) : Colors.white10,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                item.iconPath,
                filterQuality: FilterQuality.none, // Mantém o Pixel Art nítido
                fit: BoxFit.contain,
              ),
            ),
            if (isEquipped)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(blurRadius: 4, color: Colors.black54),
                    ],
                  ),
                  child: const Text(
                    "E",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          item.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "${statData['label']}: ${statData['value']} ➔ ${statData['next']}",
              style: TextStyle(
                color: statData['color'],
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              "Custo: ${custo}g",
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B0000),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _upgradeItem(item),
          child: const Text(
            "FORJAR",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // --- AUXILIARES ---

  List<Item> _getSortedItems() {
    // 1. Pegar todos os slots equipados que não são nulos
    final List<Item> equipped = [
      widget.hero.equippedWeapon,
      widget.hero.equippedArmor,
      widget.hero.equippedHelmet,
      widget.hero.equippedBoots,
      widget.hero.equippedNecklace,
      widget.hero.equippedRing,
      widget.hero.equippedRing2,
    ].whereType<Item>().toList();

    // 2. Pegar itens do armazém (excluindo consumíveis/materiais)
    final List<Item> warehouse = widget.hero.warehouse
        .where((i) => i.type != ItemType.potion && i.type != ItemType.material)
        .toList();

    // 3. Unir e remover duplicatas de referência
    final Set<Item> allUnique = {...equipped, ...warehouse};

    return allUnique.toList();
  }

  bool _isItemEquipped(Item item) {
    return [
      widget.hero.equippedWeapon,
      widget.hero.equippedArmor,
      widget.hero.equippedHelmet,
      widget.hero.equippedBoots,
      widget.hero.equippedNecklace,
      widget.hero.equippedRing,
      widget.hero.equippedRing2,
    ].contains(item);
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Nenhum item aprimorável encontrado...",
        style: TextStyle(color: Colors.white24),
      ),
    );
  }
}

// --- CLASSE DA ANIMAÇÃO FLUTUANTE ---

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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Se for negativo ou falha, desce. Se for positivo, sobe.
    double direction =
        (widget.text.contains("-") || widget.text.contains("FALHA")) ? 40 : -40;

    _offsetAnimation = Tween<double>(
      begin: 0,
      end: direction,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: MediaQuery.of(context).size.height * 0.4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _offsetAnimation.value),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.color,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
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
