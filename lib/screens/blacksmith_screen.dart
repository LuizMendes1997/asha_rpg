import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  late VideoPlayerController _controller;
  bool _hasVideoError = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/blacksmith_loop.mp4')
      ..initialize()
          .then((_) {
            _controller.setLooping(true);
            _controller.setVolume(0.0);
            _controller.play();
            if (mounted) {
              setState(() {});
            }
          })
          .catchError((error) {
            debugPrint("ERRO AO CARREGAR VÍDEO: $error");
            if (mounted) {
              setState(() {
                _hasVideoError = true;
              });
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- LÓGICA DE OVERLAY ---
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

  // --- LÓGICA DE APRIMORAMENTO AJUSTADA ---
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
        // Garante que não passe de 10
        item.level = (item.level + 1).clamp(0, 10);
        _showFloatingText("+1", Colors.greenAccent);
      } else {
        if (item.level > 0) {
          // Garante que nunca fique menor que 0
          item.level = (item.level - 1).clamp(0, 10);
          _showFloatingText("-1", Colors.redAccent);
        } else {
          // Se já for 0 e falhar, apenas avisa que falhou
          item.level = 0;
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
      body: Stack(
        children: [
          if (_hasVideoError)
            const Center(
              child: Text(
                "❌ Erro ao carregar vídeo.\nVerifique o pubspec e reinicie o app.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (_controller.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            ),

          Container(color: Colors.black.withOpacity(0.6)),

          Column(
            children: [
              AppBar(
                title: const Text(
                  "FORJA DE VULCANO",
                  style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
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
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(Item item) {
    double chance = 1.0;
    if (item.level >= 2) {
      chance = (1.0 - ((item.level - 1) * 0.1)).clamp(0.1, 1.0) * 100;
    } else {
      chance = 100;
    }
    final statData = item.mainStat;
    final bool isEquipped = _isItemEquipped(item);
    int custo = (item.level + 1) * 50;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEquipped ? Colors.green.withOpacity(0.5) : Colors.white10,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            item.iconPath,
            filterQuality: FilterQuality.none,
            fit: BoxFit.contain,
          ),
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
            Text(
              "${statData['label']}: ${statData['value']} ➔ ${statData['next']}. Chance ${chance.toString()}%",
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

  List<Item> _getSortedItems() {
    final List<Item> equipped = [
      widget.hero.equippedWeapon,
      widget.hero.equippedArmor,
      widget.hero.equippedHelmet,
      widget.hero.equippedBoots,
      widget.hero.equippedNecklace,
      widget.hero.equippedRing,
      widget.hero.equippedRing2,
    ].whereType<Item>().toList();

    final List<Item> warehouse = widget.hero.warehouse
        .where((i) => i.type != ItemType.potion && i.type != ItemType.material)
        .toList();

    return {...equipped, ...warehouse}.toList();
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

  Widget _buildEmptyState() => const Center(
    child: Text(
      "Nenhum item aprimorável...",
      style: TextStyle(color: Colors.white24),
    ),
  );
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
        builder: (context, child) => Transform.translate(
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
        ),
      ),
    );
  }
}
