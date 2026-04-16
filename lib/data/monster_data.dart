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
  static Monster get aguiaReal => Monster(
    name: "Aguia Real",
    hp: 80,
    atk: 15,
    expValue: 150,
    isBoss: true,
    imagePath: 'assets/monsters/aguiareal.webp',
  );

  static Monster get rainhaAranha => Monster(
    name: "Rainha Aranha",
    hp: 120,
    atk: 25,
    expValue: 250,
    isBoss: true,
    imagePath: 'assets/monsters/aranha.webp',
  );

  static Monster get assasino => Monster(
    name: "Assasino",
    hp: 120,
    atk: 25,
    expValue: 250,
    isBoss: true,
    imagePath: 'assets/monsters/assasino.webp',
  );
  static Monster get acougueiro => Monster(
    name: "Acougueiro",
    hp: 120,
    atk: 25,
    expValue: 250,
    isBoss: true,
    imagePath: 'assets/monsters/acougueiro.webp',
  );
  static Monster get viceLider => Monster(
    name: "Vice Lider",
    hp: 120,
    atk: 25,
    expValue: 250,
    isBoss: true,
    imagePath: 'assets/monsters/vicelider.webp',
  );
  static Monster get liderBandido => Monster(
    name: "Lider Bandido",
    hp: 120,
    atk: 25,
    expValue: 250,
    isBoss: true,
    imagePath: 'assets/monsters/liderbandido.webp',
  );
  static Monster get driade => Monster(
    name: "Driade",
    hp: 80,
    atk: 15,
    expValue: 120,
    isBoss: false,
    imagePath: 'assets/monsters/driade.webp',
  );

  static Monster get leviata => Monster(
    name: "Leviata",
    hp: 500,
    atk: 45,
    expValue: 1200,
    isBoss: true,
    imagePath: 'assets/monsters/leviata.webp',
  );

  static Monster get verme => Monster(
    name: "Verme",
    hp: 40,
    atk: 10,
    expValue: 50,
    isBoss: false,
    imagePath: 'assets/monsters/verme.webp',
  );

  static Monster get tritao => Monster(
    name: "Tritao",
    hp: 150,
    atk: 28,
    expValue: 300,
    isBoss: false,
    imagePath: 'assets/monsters/tritao.webp',
  );
}
