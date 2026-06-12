import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_state.dart'; // Importando o modelo do herói

class ShopScreen extends StatefulWidget {
  final HeroModel hero; // Mudado de String heroId para HeroModel hero
  final VoidCallback onUpdate;

  const ShopScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  final List<Map<String, dynamic>> skins = [
    {
      'path': 'assets/races/drakdefogo.webp',
      'name': 'Drakoniano de Fogo',
      'def': 3,
    },
    {
      'path': 'assets/races/drakfeiticeira.webp',
      'name': 'Drakoniana Feiticeira',
      'def': 3,
    },
    {
      'path': 'assets/races/elfassasino.webp',
      'name': 'elfo assasino de Aço',
      'def': 3,
    },
    {'path': 'assets/races/Elfdiablic.webp', 'name': 'Elfo diablico', 'def': 3},
    {'path': 'assets/races/elfmaga.webp', 'name': 'Maga Elfica', 'def': 3},
    {
      'path': 'assets/races/rainhawoman.webp',
      'name': 'Rainha Humana',
      'def': 3,
    },
    {'path': 'assets/races/reihuman.webp', 'name': 'Rei Humano', 'def': 73},
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final skin = skins[currentIndex];

    return Scaffold(
      // Fundo com gradiente elegante
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),

              const Spacer(),

              // Vitrine Central com Borda Glow
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213e),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => _changeSkin(-1),
                      ),
                      Expanded(
                        child: Image.asset(
                          skin['path'],
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => _changeSkin(1),
                      ),
                    ],
                  ),
                ),
              ),

              // Bloco de Atributos Estilizado
              _buildInfoCard(skin),

              const Spacer(),

              _buildEquipButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const Text(
            " LOJA DE EMBLEMAS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> skin) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: const Border(
          left: BorderSide(color: Colors.cyanAccent, width: 4),
        ),
      ),
      child: Column(
        children: [
          Text(
            skin['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Defesa: +${skin['def']}",
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () async {
        // Colocamos o "!" no final do id para garantir que não é nulo
        await supabase
            .from('profiles')
            .update({'emblema_path': skins[currentIndex]['path']})
            .eq('id', widget.hero.id!);

        widget.onUpdate();

        if (mounted) {
          Navigator.pop(context);
        }
      },
      child: const Text(
        "EQUIPAR",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  void _changeSkin(int delta) {
    setState(() {
      currentIndex = (currentIndex + delta) % skins.length;
      if (currentIndex < 0) currentIndex = skins.length - 1;
    });
  }
}
