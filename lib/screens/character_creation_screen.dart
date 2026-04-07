import 'package:flutter/material.dart';
import '../models/game_state.dart'; // Ajuste o caminho se necessário
import '../data/item_data.dart'; // Para dar os itens iniciais
import 'main_shell.dart'; // Para onde vamos navegar

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final TextEditingController _charNameController = TextEditingController();
  final TextEditingController _villageNameController = TextEditingController();

  bool isMale = true;
  int selectedRaceIndex = 0;

  final List<Map<String, dynamic>> races = [
    {
      "name": "Humano",
      "type": Raca.humano, // Usando seu Enum
      "desc": "Equilíbrio absoluto. Adaptáveis a qualquer situação.",
      "attr": {"FOR": 10, "DEF": 10, "HP": 100},
      "folder": "human",
    },
    {
      "name": "Draconiano",
      "type": Raca
          .dragoniano, // Verifique se no seu enum está 'dragoniano' ou 'draconiano'
      "desc": "Poder bruto e escamas resistentes. Nascidos do fogo.",
      "attr": {"FOR": 15, "DEF": 12, "HP": 130},
      "folder": "draconian",
    },
    {
      "name": "Elfo",
      "type": Raca.elfo,
      "desc": "Agilidade sobrenatural. Mestres da precisão e do tempo.",
      "attr": {"FOR": 8, "DEF": 7, "HP": 90},
      "folder": "elf",
    },
  ];

  String get currentImagePath {
    String raceFolder = races[selectedRaceIndex]['folder'];
    String genderSuffix = isMale ? "_m.webp" : "_f.webp";
    return "assets/races/$raceFolder$genderSuffix";
  }

  @override
  Widget build(BuildContext context) {
    var race = races[selectedRaceIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [const Color(0xFF2C0B00).withOpacity(0.3), Colors.black],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          child: Column(
            children: [
              const Text(
                "FORJA DE HERÓIS",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 30),
              _buildInput("NOME DO HERÓI", _charNameController, Icons.shield),
              const SizedBox(height: 15),
              _buildInput("NOME DA VILA", _villageNameController, Icons.fort),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navArrow(Icons.arrow_back_ios, () {
                    setState(
                      () => selectedRaceIndex =
                          (selectedRaceIndex - 1 + races.length) % races.length,
                    );
                  }),
                  Column(
                    children: [
                      Container(
                        height: 220,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.2),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Image.asset(
                            currentImagePath,
                            key: ValueKey(currentImagePath),
                            width: double.infinity,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        race['name'].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  _navArrow(Icons.arrow_forward_ios, () {
                    setState(
                      () => selectedRaceIndex =
                          (selectedRaceIndex + 1) % races.length,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _genderBtn("MASC", true),
                  const SizedBox(width: 15),
                  _genderBtn("FEMI", false),
                ],
              ),
              const SizedBox(height: 35),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900]?.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Text(
                      race['desc'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.white10),
                    ),
                    _statusRow("FORÇA", race['attr']['FOR'], Colors.redAccent),
                    _statusRow(
                      "DEFESA",
                      race['attr']['DEF'],
                      Colors.blueAccent,
                    ),
                    _statusRow(
                      "HP BASE",
                      race['attr']['HP'],
                      Colors.greenAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[900],
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _finish,
                child: const Text(
                  "INICIAR AVENTURA",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.amber, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _navArrow(IconData icon, VoidCallback tap) {
    return IconButton(
      icon: Icon(icon, color: Colors.amber, size: 30),
      onPressed: tap,
    );
  }

  Widget _genderBtn(String label, bool value) {
    bool isSelected = isMale == value;
    return GestureDetector(
      onTap: () => setState(() => isMale = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.transparent,
          border: Border.all(color: Colors.amber),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _statusRow(String label, int val, Color col) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          Text(
            "+$val",
            style: TextStyle(
              color: col,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  void _finish() {
    if (_charNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O herói precisa de um nome!")),
      );
      return;
    }

    final raceData = races[selectedRaceIndex];

    // Criando o herói com os dados selecionados
    final hero = HeroModel(
      name: _charNameController.text,
      villageName: _villageNameController.text, // Passando o nome da vila
      raca: raceData['type'],
      // Atribuindo os status base da raça escolhida
      str: raceData['attr']['FOR'],
      maxHp: raceData['attr']['HP'],
      hp: raceData['attr']['HP'], // Começa com vida cheia
      gold: 1000,
    );

    // Itens iniciais
    hero.addItem(ItemData.adagaVelha.copy());
    hero.addItem(ItemData.tunicaLona.copy());
    hero.gold = 1000;

    // Navega para o jogo e remove a tela de criação da pilha
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainShell(hero: hero)),
    );
  }
}
