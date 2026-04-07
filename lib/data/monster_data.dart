import '../models/game_state.dart';

class MonsterData {
  // --- MONSTROS DA VILA ---
  static Monster get abelha => Monster(
    name: "Abelha Operária",
    hp: 12,
    atk: 4,
    expValue: 5,
    imagePath: 'assets/monsters/abelha.webp',
  );

  static Monster get cobra => Monster(
    name: "Cobra Venenosa",
    hp: 15,
    atk: 2,
    expValue: 8,
    imagePath: 'assets/monsters/cobra.webp',
  );

  static Monster get rato => Monster(
    name: "Rato de Esgoto",
    hp: 20,
    atk: 5,
    expValue: 8,
    imagePath: 'assets/monsters/rato.webp',
  );

  static Monster get aguiaReal => Monster(
    name: "Águia Real",
    hp: 80,
    atk: 15,
    expValue: 60,
    isBoss: true,
    imagePath: 'assets/monsters/aguia.webp',
  );

  // --- MONSTROS DA FLORESTA ---
  static Monster get goblin => Monster(
    name: "Goblin",
    hp: 30,
    atk: 5,
    expValue: 20,
    imagePath: 'assets/monsters/goblin.webp',
  );

  static Monster get lobo => Monster(
    name: "Lobo Selvagem",
    hp: 50,
    atk: 12,
    expValue: 45,
    imagePath: 'assets/monsters/lobo.webp',
  );

  static Monster get slime => Monster(
    name: "Slime",
    hp: 20,
    atk: 7,
    expValue: 10,
    imagePath: 'assets/monsters/slime.webp',
  );

  static Monster get aranhaGigante => Monster(
    name: "Aranha de Elite",
    hp: 120,
    atk: 25,
    expValue: 250,
    isBoss: true,
    imagePath: 'assets/monsters/aranha.webp',
  );
}
