import '../models/game_state.dart';

class MonsterData {
  // --- MONSTROS DA VILA ---
  static Monster get abelha => Monster(
    name: "Abelha Operária",
    hp: 12,
    atk: 3,
    def: 0,
    expValue: 5,
    imagePath: 'assets/monsters/abelha.webp',
  );

  static Monster get cobra => Monster(
    name: "Cobra Venenosa",
    hp: 25,
    atk: 6,
    def: 2,
    expValue: 15,
    imagePath: 'assets/monsters/cobra.webp',
  );

  static Monster get rato => Monster(
    name: "Rato de Esgoto",
    hp: 15,
    atk: 4,
    def: 1,
    expValue: 8,
    imagePath: 'assets/monsters/rato.webp',
  );
  static Monster get aguiaReal => Monster(
    name: "Aguia Real",
    hp: 100,
    atk: 10,
    def: 4,
    expValue: 40,
    isBoss: true,
    imagePath: 'assets/monsters/aguiareal.webp',
  );
  // --- MONSTROS DA FLORESTA ---
  static Monster get goblin => Monster(
    name: "Goblin",
    hp: 60,
    atk: 15,
    def: 7,
    expValue: 25,
    imagePath: 'assets/monsters/goblin.webp',
  );

  static Monster get lobo => Monster(
    name: "Lobo Selvagem",
    hp: 85,
    atk: 18,
    def: 8,
    expValue: 45,
    imagePath: 'assets/monsters/lobo.webp',
  );

  static Monster get slime => Monster(
    name: "Slime",
    hp: 45,
    atk: 12,
    def: 5,
    expValue: 20,
    imagePath: 'assets/monsters/slime.webp',
  );

  static Monster get rainhaAranha => Monster(
    name: "Rainha Aranha",
    hp: 180,
    atk: 25,
    def: 12,
    expValue: 80,
    isBoss: true,
    imagePath: 'assets/monsters/aranha.webp',
  );

  static Monster get assasino => Monster(
    name: "Assasino",
    hp: 120,
    atk: 30,
    def: 15,
    expValue: 40,
    isBoss: true,
    imagePath: 'assets/monsters/assasino.webp',
  );
  static Monster get acougueiro => Monster(
    name: "Acougueiro",
    hp: 180,
    atk: 35,
    def: 20,
    expValue: 50,
    isBoss: true,
    imagePath: 'assets/monsters/acougueiro.webp',
  );
  static Monster get viceLider => Monster(
    name: "Vice Lider",
    hp: 250,
    atk: 45,
    def: 25,
    expValue: 75,
    isBoss: true,
    imagePath: 'assets/monsters/vicelider.webp',
  );
  static Monster get liderBandido => Monster(
    name: "Lider Bandido",
    hp: 450,
    atk: 60,
    def: 35,
    expValue: 150,
    isBoss: true,
    imagePath: 'assets/monsters/liderbandido.webp',
  );
  static Monster get driade => Monster(
    name: "Driade",
    hp: 350,
    atk: 70,
    def: 50,
    expValue: 120,
    isBoss: false,
    imagePath: 'assets/monsters/driade.webp',
  );

  static Monster get leviata => Monster(
    name: "Leviata",
    hp: 1200,
    atk: 120,
    def: 80,
    expValue: 300,
    isBoss: true,
    imagePath: 'assets/monsters/leviata.webp',
  );

  static Monster get verme => Monster(
    name: "Verme",
    hp: 220,
    atk: 55,
    def: 40,
    expValue: 90,
    isBoss: false,
    imagePath: 'assets/monsters/verme.webp',
  );

  static Monster get tritao => Monster(
    name: "Tritao",
    hp: 500,
    atk: 85,
    def: 60,
    expValue: 140,
    isBoss: false,
    imagePath: 'assets/monsters/tritao.webp',
  );
}
