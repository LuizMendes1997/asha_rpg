import 'dart:async';
import 'package:flutter/material.dart';
import '../data/item_data.dart';

class GuildScreen extends StatefulWidget {
  final dynamic hero;
  final VoidCallback onUpdate;

  const GuildScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends State<GuildScreen> {
  // --- CONFIGURAÇÃO DA ANIMAÇÃO DA LYRA ---
  int _currentFrameIndex = 0;
  Timer? _animationTimer;

  final List<String> _lyraFrames = [
    'assets/images/lyra_wave_3.webp',
    'assets/images/lyra_wave_1.webp',
    'assets/images/lyra_wave_3.webp',
  ];

  // --- ESTADOS PARA CONTROLAR A ABERTURA DOS QUADROS ---
  bool _showMural = false;
  bool _showBalcao = false;

  // --- CONTROLLERS PARA OS CAMPOS DE TEXTO DE QUANTIDADE ---
  final TextEditingController _ferraoController = TextEditingController(
    text: "1",
  );
  final TextEditingController _caudaController = TextEditingController(
    text: "1",
  );

  @override
  void initState() {
    super.initState();

    _animationTimer = Timer.periodic(const Duration(milliseconds: 800), (
      timer,
    ) {
      if (mounted) {
        setState(() {
          if (_currentFrameIndex < _lyraFrames.length - 1) {
            _currentFrameIndex++;
          } else {
            _animationTimer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _ferraoController.dispose();
    _caudaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 1. IMAGEM DE FUNDO (Cenário da Guilda)
            Container(
              width: screenSize.width,
              height: screenSize.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/guilda.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 2. FILTRO ESCURO DA TAVERNA
            Container(color: Colors.black.withOpacity(0.15)),

            // 3. A ATENDENTE LYRA
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    key: ValueKey<int>(_currentFrameIndex),
                    width: screenSize.width * 0.9,
                    height: screenSize.height * 0.43,
                    child: Transform.scale(
                      scale: 2.2,
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // 👤 SOMBRA DA SILHUETA
                          Positioned(
                            bottom: 10,
                            right: 110,
                            child: SizedBox(
                              width: screenSize.width * 0.4,
                              height: screenSize.height * 0.2,
                              child: Image.asset(
                                _lyraFrames[_currentFrameIndex],
                                fit: BoxFit.cover,
                                alignment: Alignment.bottomCenter,
                                color: Colors.black.withOpacity(0.35),
                                colorBlendMode: BlendMode.srcIn,
                              ),
                            ),
                          ),

                          // 🧝‍♀️ LYRA REAL
                          Image.asset(
                            _lyraFrames[_currentFrameIndex],
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
                            filterQuality: FilterQuality.high,
                            color: Colors.amber.withOpacity(0.04),
                            colorBlendMode: BlendMode.colorBurn,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4. INTERFACES CLICÁVEIS (Mural e Balcão)
            _buildInteractiveAreas(screenSize),

            // 5. BOTÃO DE VOLTAR
            Positioned(
              top: 10,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // INTERRUPTORES DOS PAINÉIS
            if (_showMural) _buildMuralQuadro(screenSize),
            if (_showBalcao) _buildBalcaoQuadro(screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveAreas(Size screenSize) {
    return Stack(
      children: [
        Positioned(
          top: screenSize.height * 0.35,
          left: screenSize.width * 0.01,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showMural = true;
                _showBalcao = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber, width: 1.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    "Mural",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: screenSize.height * 0.48,
          right: screenSize.width * 0.01,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showBalcao = true;
                _showMural = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.greenAccent, width: 1.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gavel, color: Colors.greenAccent),
                  SizedBox(width: 8),
                  Text(
                    "Balcão",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMuralQuadro(Size screenSize) {
    return Center(
      child: Container(
        width: screenSize.width * 0.85,
        height: screenSize.height * 0.5,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber, width: 2),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment, color: Colors.amber, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "MURAL DE MISSÕES",
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.amber, thickness: 1, height: 20),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "⚔️ Infestação no Porão",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Acabe com os ratos gigantes que estão destruindo os estoques de comida da guilda.",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.yellow,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Recompensa: ",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "10 Golds",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => setState(() => _showMural = false),
                child: const Icon(Icons.close, color: Colors.white, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalcaoQuadro(Size screenSize) {
    int totalFerrao = 0;
    int totalCauda = 0;

    for (var item in widget.hero.warehouse) {
      if (item.name == "Ferrão de Abelha")
        totalFerrao += (item.quantity as num).toInt();
      if (item.name == "Cauda de Rato")
        totalCauda += (item.quantity as num).toInt();
    }

    return Center(
      child: Container(
        width: screenSize.width * 0.85,
        height: screenSize.height * 0.52,
        padding: const EdgeInsets.all(
          12,
        ), // Reduzido levemente para dar mais margem interna
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.greenAccent, width: 2),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.gavel, color: Colors.greenAccent, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "BALCÃO DE TROCAS",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.greenAccent,
                  thickness: 1,
                  height: 20,
                ),
                const SizedBox(height: 6),

                Expanded(
                  child: ListView(
                    children: [
                      // TROCA 1: Ferrão de Abelha -> Lingote de Bronze
                      _buildTrocaRow(
                        itemEntregaNome: "Ferrão de Abelha",
                        itemEntregaPath: "assets/icons/ferrao.webp",
                        itemRecebePath: "assets/icons/lingotedebronze.webp",
                        quantidadePossuida: totalFerrao,
                        controller: _ferraoController,
                        onTrocar: () {
                          int qtdDesejada =
                              int.tryParse(_ferraoController.text) ?? 1;
                          if (qtdDesejada < 1) qtdDesejada = 1;

                          if (totalFerrao < qtdDesejada) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "❌ Material insuficiente! Você precisa de $qtdDesejada Ferrões.",
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            int removidos = 0;
                            for (
                              int i = widget.hero.warehouse.length - 1;
                              i >= 0;
                              i--
                            ) {
                              var item = widget.hero.warehouse[i];
                              if (item.name == "Ferrão de Abelha") {
                                int itemQty = (item.quantity as num).toInt();
                                int faltaRemover = qtdDesejada - removidos;

                                if (itemQty <= faltaRemover) {
                                  removidos += itemQty;
                                  widget.hero.warehouse.removeAt(i);
                                } else {
                                  item.quantity = itemQty - faltaRemover;
                                  removidos += faltaRemover;
                                }
                              }
                              if (removidos >= qtdDesejada) break;
                            }

                            for (int i = 0; i < qtdDesejada; i++) {
                              final reward = ItemData.lingoteDeBronze.copy();
                              widget.hero.addItem(reward);
                            }
                            widget.onUpdate();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "✨ Sucesso! Convertidos $qtdDesejada Ferrões.",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // TROCA 2: Cauda de Rato -> Couro
                      _buildTrocaRow(
                        itemEntregaNome: "Cauda de Rato",
                        itemEntregaPath: "assets/icons/caudaRato.webp",
                        itemRecebePath: "assets/icons/couro.webp",
                        quantidadePossuida: totalCauda,
                        controller: _caudaController,
                        onTrocar: () {
                          int qtdDesejada =
                              int.tryParse(_caudaController.text) ?? 1;
                          if (qtdDesejada < 1) qtdDesejada = 1;

                          if (totalCauda < qtdDesejada) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "❌ Material insuficiente! Você precisa de $qtdDesejada Caudas.",
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            int removidos = 0;
                            for (
                              int i = widget.hero.warehouse.length - 1;
                              i >= 0;
                              i--
                            ) {
                              var item = widget.hero.warehouse[i];
                              if (item.name == "Cauda de Rato") {
                                int itemQty = (item.quantity as num).toInt();
                                int faltaRemover = qtdDesejada - removidos;

                                if (itemQty <= faltaRemover) {
                                  removidos += itemQty;
                                  widget.hero.warehouse.removeAt(i);
                                } else {
                                  item.quantity = itemQty - faltaRemover;
                                  removidos += faltaRemover;
                                }
                              }
                              if (removidos >= qtdDesejada) break;
                            }

                            for (int i = 0; i < qtdDesejada; i++) {
                              final reward = ItemData.couro.copy();
                              widget.hero.addItem(reward);
                            }
                            widget.onUpdate();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "✨ Sucesso! Convertidas $qtdDesejada Caudas.",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => setState(() => _showBalcao = false),
                child: const Icon(Icons.close, color: Colors.white, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 🔨 WIDGET DA LINHA DE TROCA (REESTRUTURADO E COMPACTO CONTR OVERFLOW)
  // ==========================================================================
  Widget _buildTrocaRow({
    required String itemEntregaNome,
    required String itemEntregaPath,
    required String itemRecebePath,
    required int quantidadePossuida,
    required TextEditingController controller,
    required VoidCallback onTrocar,
  }) {
    int qtdDefinida = int.tryParse(controller.text) ?? 1;
    if (qtdDefinida < 1) qtdDefinida = 1;
    bool temIngredientesSuficientes =
        quantidadePossuida >= qtdDefinida && quantidadePossuida > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // 1. Ícones de troca (tamanho fixo controlado)
          Image.asset(
            itemEntregaPath,
            width: 26,
            height: 26,
            errorBuilder: (c, e, s) =>
                const Icon(Icons.gavel, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.arrow_forward, color: Colors.greenAccent, size: 12),
          const SizedBox(width: 2),
          Image.asset(
            itemRecebePath,
            width: 26,
            height: 26,
            errorBuilder: (c, e, s) =>
                const Icon(Icons.gavel, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 8),

          // 2. Textos descritivos (Único Expanded que absorve o espaço dinâmico com segurança)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  itemEntregaNome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  "Possui: $quantidadePossuida | Custo: ${qtdDefinida}x",
                  style: TextStyle(
                    color: temIngredientesSuficientes
                        ? Colors.amber
                        : Colors.redAccent,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // 3. Campo numérico pequeno (Tamanho fixo)
          Container(
            width: 38,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              cursorColor: Colors.greenAccent,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 6),

          // 4. Botão de Troca compacto (Tamanho fixo)
          SizedBox(
            height: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: temIngredientesSuficientes
                    ? Colors.greenAccent.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                side: BorderSide(
                  color: temIngredientesSuficientes
                      ? Colors.greenAccent
                      : Colors.white10,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: onTrocar,
              child: Text(
                "Trocar",
                style: TextStyle(
                  color: temIngredientesSuficientes
                      ? Colors.white
                      : Colors.white30,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
