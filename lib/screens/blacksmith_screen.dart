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

// Adicionado o SingleTickerProviderStateMixin para controlar as animações de efeito
class _BlacksmithScreenState extends State<BlacksmithScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _hasVideoError = false;
  Item? _itemSelecionado;

  // --- CONTROLADORES DE ANIMAÇÃO DO PROTÓTIPO ---
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  Color? _overrideBgColor;
  Color? _overrideBorderColor;

  @override
  void initState() {
    super.initState();

    // Configuração do vídeo de fundo
    _controller = VideoPlayerController.asset('assets/blacksmith_loop.mp4')
      ..initialize()
          .then((_) {
            _controller.setLooping(true);
            _controller.setVolume(0.0);
            _controller.play();
            if (mounted) setState(() {});
          })
          .catchError((error) {
            debugPrint("ERRO AO CARREGAR VÍDEO: $error");
            if (mounted) {
              setState(() => _hasVideoError = true);
            }
          });

    // --- CONFIGURAÇÃO DO TREMOR (SHAKE) ---
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Cria um efeito vai-e-vem rápido horizontalmente
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 12.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 12.0, end: -12.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -12.0, end: 9.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 9.0, end: -9.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -9.0, end: 5.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    // Ouvinte para redesenhar a tela a cada frame da animação (necessário para as faíscas)
    _shakeController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

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

  // --- LÓGICA DE APRIMORAMENTO COM EFEITOS APLICADOS ---
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
        item.level = (item.level + 1).clamp(0, 10);
        _showFloatingText("+1", Colors.greenAccent);

        // Aplica o tom verde fluorescente de sucesso
        _overrideBgColor = Colors.green.withOpacity(0.25);
        _overrideBorderColor = Colors.greenAccent;
      } else {
        if (item.level > 0) {
          item.level = (item.level - 1).clamp(0, 10);
          _showFloatingText("-1", Colors.redAccent);
        } else {
          item.level = 0;
          _showFloatingText("FALHOU!", Colors.orangeAccent);
        }

        // Aplica o tom vermelho/laranja de falha
        _overrideBgColor = Colors.red.withOpacity(0.25);
        _overrideBorderColor = Colors.redAccent;
      }

      widget.hero.calculateStats();

      // Dispara o tremor e o estouro de faíscas
      _shakeController.forward(from: 0.0);
    });

    widget.onUpdate();
    widget.hero.saveToSupabase();

    // Remove o efeito de cor após 600ms, restaurando o visual dark padrão
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _overrideBgColor = null;
          _overrideBorderColor = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Item> upgradeableItems = _getSortedItems();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // VÍDEO DE FUNDO
          if (_hasVideoError)
            const Center(
              child: Text(
                "❌ Erro ao carregar vídeo.",
                style: TextStyle(color: Colors.redAccent),
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

          Container(color: Colors.black.withOpacity(0.55)),

          // INTERFACE PRINCIPAL
          SafeArea(
            child: Column(
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

                // METADE SUPERIOR: BIGORNA COM ANIMAÇÃO
                Expanded(flex: 4, child: Center(child: _buildForgeSlot())),

                const Divider(color: Colors.white24, height: 1, thickness: 1),

                // METADE INFERIOR: LISTA
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Colors.black87,
                    child: upgradeableItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: upgradeableItems.length,
                            padding: const EdgeInsets.all(12),
                            itemBuilder: (context, index) =>
                                _buildInventoryTile(upgradeableItems[index]),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CONSTRUÇÃO DA BIGORNA COM FXS DE TREMOR E FAÍSCAS ---
  Widget _buildForgeSlot() {
    if (_itemSelecionado == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10, width: 1),
        ),
        child: const Text(
          "Selecione um equipamento abaixo\npara colocar na bigorna",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.4),
        ),
      );
    }

    final item = _itemSelecionado!;
    final statData = item.mainStat;
    int custo = (item.level + 1) * 50;

    double chance = 100;
    if (item.level >= 2) {
      chance = (1.0 - ((item.level - 1) * 0.1)).clamp(0.1, 1.0) * 100;
    }

    // Usamos AnimatedBuilder para aplicar a translação lateral (efeito tremor)
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bloco Principal da Bigorna
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Alterna dinamicamente as cores caso ocorra um acerto ou erro
              color: _overrideBgColor ?? Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _overrideBorderColor ?? Colors.amber.withOpacity(0.6),
                width: _overrideBorderColor != null ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      _overrideBorderColor ??
                      Colors.orangeAccent.withOpacity(0.1),
                  blurRadius: _overrideBorderColor != null ? 25 : 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      item.iconPath,
                      width: 54,
                      height: 54,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Nível Atual: +${item.level}",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${statData['label']}: ${statData['value']} ➔ ${statData['next']}",
                        style: TextStyle(
                          color: statData['color'],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Sucesso: ${chance.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _upgradeItem(item),
                        child: Text(
                          item.level >= 10
                              ? "NÍVEL MÁXIMO"
                              : "FORJAR (-${custo}g)",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Camada de Partículas/Faíscas (renderiza apenas se estiver ativamente sacudindo)
          if (_shakeController.isAnimating) ..._buildSparksEffect(),
        ],
      ),
    );
  }

  // --- GERAÇÃO MATEMÁTICA DAS FAÍSCAS EXPANSIVAS ---
  List<Widget> _buildSparksEffect() {
    final progress = _shakeController.value;
    final opacity = (1.0 - progress).clamp(
      0.0,
      1.0,
    ); // Some gradativamente conforme viajam
    final distance = progress * 110; // Distância total de explosão das faíscas

    // Distribui 6 partículas em ângulos radiais perfeitos ao redor do centro
    final List<double> angles = [0, 60, 120, 180, 240, 300];

    return angles.map((angle) {
      final rad = angle * pi / 180;
      return Transform.translate(
        offset: Offset(cos(rad) * distance, sin(rad) * distance),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.orangeAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.amber, blurRadius: 6, spreadRadius: 2),
                BoxShadow(color: Colors.red, blurRadius: 10),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildInventoryTile(Item item) {
    final bool isEquipped = _isItemEquipped(item);
    final bool isSelected = _itemSelecionado == item;
    final statData = item.mainStat;

    return GestureDetector(
      onTap: () {
        setState(() {
          _itemSelecionado = item;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.1) : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.amber
                : (isEquipped ? Colors.green.withOpacity(0.4) : Colors.white10),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          leading: Image.asset(
            item.iconPath,
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                "+${item.level}",
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "${statData['label']}: ${statData['value']} ➔ ${statData['next']}",
              style: TextStyle(
                color: statData['color'] ?? Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          trailing: isEquipped
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    border: Border.all(color: Colors.green.withOpacity(0.7)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "EQUIPADO",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.white30,
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
      top: MediaQuery.of(context).size.height * 0.28,
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
                    fontSize: 44,
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
