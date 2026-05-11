import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_state.dart';
import 'main_shell.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final TextEditingController _charNameController = TextEditingController();
  bool isMale = true;
  int selectedRaceIndex = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> races = [
    {
      "name": "Humano",
      "type": Raca.humano,
      "desc": "Equilíbrio absoluto entre força e defesa.",
      "attr": {"FOR": 6, "DEF": 3, "HP": 100},
      "folder": "human",
    },
    {
      "name": "Draconiano",
      "type": Raca.dragoniano,
      "desc": "Poder bruto e escamas resistentes.",
      "attr": {"FOR": 10, "DEF": 5, "HP": 120},
      "folder": "draconian",
    },
    {
      "name": "Elfo",
      "type": Raca.elfo,
      "desc": "Agilidade e alta vitalidade arcana.",
      "attr": {"FOR": 5, "DEF": 2, "HP": 150},
      "folder": "elf",
    },
  ];

  String get currentImagePath {
    String folder = races[selectedRaceIndex]['folder'];
    return "assets/races/$folder${isMale ? "_m.webp" : "_f.webp"}";
  }

  // Widget para mostrar as barrinhas/valores de atributos
  Widget _buildAttributeRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finish() async {
    final String name = _charNameController.text.trim();
    if (name.isEmpty || name.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O nome deve ter pelo menos 3 caracteres!"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final raceData = races[selectedRaceIndex];
    final hero = HeroModel(
      id: user.id,
      name: name,
      raca: raceData['type'],
      str: raceData['attr']['FOR'],
      def: raceData['attr']['DEF'],
      maxHp: raceData['attr']['HP'],
      hp: raceData['attr']['HP'],
      gold: 500,
    );

    try {
      await supabase.from('profiles').insert({
        'id': user.id,
        'username': hero.name,
        'race': hero.raca.index,
        'level': 1,
        'exp': 0,
        'hp': hero.hp,
        'max_hp': hero.maxHp,
        'str': hero.str,
        'def': hero.def,
        'gold': hero.gold,
        'nivel_linhagem': 1,
        'total_doado': 0,
        'warehouse': [],
        'max_tower_floor': 0,
        'current_quest_id': null,
        'quest_progress': 0,
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainShell(hero: hero)),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var race = races[selectedRaceIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Colors.grey.shade900, Colors.black],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            children: [
              const Text(
                "FORJA DE HERÓIS",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _charNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "NOME DO PERSONAGEM",
                  labelStyle: TextStyle(color: Colors.amber[700]),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.shield, color: Colors.amber),
                ),
              ),
              const SizedBox(height: 20),

              // SELETOR DE RAÇA (Corrigido para evitar overflow)
              Row(
                children: [
                  _navButton(Icons.arrow_back_ios, () {
                    setState(
                      () => selectedRaceIndex =
                          (selectedRaceIndex - 1 + races.length) % races.length,
                    );
                  }),
                  Expanded(
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black26,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          currentImagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  _navButton(Icons.arrow_forward_ios, () {
                    setState(
                      () => selectedRaceIndex =
                          (selectedRaceIndex + 1) % races.length,
                    );
                  }),
                ],
              ),

              const SizedBox(height: 15),
              Text(
                race['name'].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // ATRIBUTOS (Recolocados)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildAttributeRow(
                      "FORÇA",
                      "${race['attr']['FOR']}",
                      Colors.redAccent,
                    ),
                    _buildAttributeRow(
                      "DEFESA",
                      "${race['attr']['DEF']}",
                      Colors.blueAccent,
                    ),
                    _buildAttributeRow(
                      "VITALIDADE",
                      "${race['attr']['HP']} HP",
                      Colors.greenAccent,
                    ),
                  ],
                ),
              ),

              Text(
                race['desc'],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _genderTile(
                    "MASC",
                    isMale,
                    () => setState(() => isMale = true),
                  ),
                  const SizedBox(width: 15),
                  _genderTile(
                    "FEMI",
                    !isMale,
                    () => setState(() => isMale = false),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.amber)
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        onPressed: _finish,
                        child: const Text(
                          "INICIAR JORNADA",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.amber, size: 35),
      onPressed: onTap,
    );
  }

  Widget _genderTile(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.amber : Colors.transparent,
          border: Border.all(color: Colors.amber),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.black : Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
