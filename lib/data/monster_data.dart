import '../models/game_state.dart';

class MonsterData {
  // --- MONSTROS DA VILA ---
  static Monster get abelha => Monster(
    name: "Abelha Operária",
    hp: 12,
    atk: 3,
    def: 0,
    expValue: 5,
    elemento: Elemento.vento,
    imagePath: 'assets/monsters/abelha.webp',
  );

  static Monster get cobra => Monster(
    name: "Cobra Venenosa",
    hp: 25,
    atk: 6,
    def: 2,
    expValue: 15,
    elemento: Elemento.terra,
    imagePath: 'assets/monsters/cobra.webp',
  );

  static Monster get rato => Monster(
    name: "Rato de Esgoto",
    hp: 15,
    atk: 4,
    def: 1,
    expValue: 8,
    elemento: Elemento.terra,
    imagePath: 'assets/monsters/rato.webp',
  );

  // 🌟 NOVO MONSTRO DA VILA 1
  static Monster get vespaMutante => Monster(
    name: "Vespa Mutante",
    hp: 20,
    atk: 5,
    def: 1,
    expValue: 10,
    elemento: Elemento.vento,
    imagePath: 'assets/monsters/vespa_mutante.webp',
  );

  // 🌟 NOVO MONSTRO DA VILA 2
  static Monster get espantalhoAssombrado => Monster(
    name: "Espantalho Assombrado",
    hp: 35,
    atk: 7,
    def: 3,
    expValue: 18,
    elemento: Elemento.terra,
    imagePath: 'assets/monsters/espantalho.webp',
  );

  static Monster get aguiaReal => Monster(
    name: "Águia Real",
    hp: 100,
    atk: 10,
    def: 4,
    expValue: 40,
    isBoss: true,
    elemento: Elemento.vento,
    imagePath: 'assets/monsters/aguiareal.webp',
  );

  // --- MONSTROS DA FLORESTA ---
  static Monster get goblin => Monster(
    name: "Goblin",
    hp: 60,
    atk: 15,
    def: 7,
    expValue: 25,
    elemento: Elemento.terra,
    imagePath: 'assets/monsters/goblin.webp',
  );

  static Monster get lobo => Monster(
    name: "Lobo Selvagem",
    hp: 85,
    atk: 18,
    def: 8,
    expValue: 45,
    elemento: Elemento.vento,
    imagePath: 'assets/monsters/lobo.webp',
  );

  static Monster get slime => Monster(
    name: "Slime",
    hp: 45,
    atk: 12,
    def: 5,
    expValue: 20,
    elemento: Elemento.agua,
    imagePath: 'assets/monsters/slime.webp',
  );

  // 🌟 NOVO MONSTRO DA FLORESTA 1
  static Monster get ursoCinzento => Monster(
    name: "Urso Cinzento",
    hp: 110,
    atk: 22,
    def: 14,
    expValue: 55,
    elemento: Elemento.terra,
    imagePath: 'assets/monsters/urso_cinzento.webp',
  );

  // 🌟 NOVO MONSTRO DA FLORESTA 2
  static Monster get fadaTravessa => Monster(
    name: "Fada Travessa",
    hp: 70,
    atk: 20,
    def: 6,
    expValue: 40,
    elemento: Elemento.vento,
    imagePath: 'assets/monsters/fada_travessa.webp',
  );

  static Monster get rainhaAranha => Monster(
    name: "Rainha Aranha",
    hp: 180,
    atk: 25,
    def: 12,
    expValue: 80,
    isBoss: true,
    elemento: Elemento.terra,
    imagePath: 'assets/monsters/aranha.webp',
  );

  // --- ACAMPAMENTO DE BANDIDOS ---
  // 🌟 NOVO MONSTRO DO ACAMPAMENTO 1 (Comum)
  static Monster get saqueadorMercenario => Monster(
    name: "Saqueador Mercenário",
    hp: 100,
    atk: 24,
    def: 12,
    expValue: 35,
    elemento: Elemento.fogo,
    imagePath: 'assets/monsters/saqueador.webp',
  );

  // 🌟 NOVO MONSTRO DO ACAMPAMENTO 2 (Comum)
  static Monster get caoDeCaca => Monster(
    name: "Cão de Caça",
    hp: 90,
    atk: 28,
    def: 10,
    expValue: 35,
    elemento: Elemento.fogo,
    imagePath: 'assets/monsters/cao_caca.webp',
  );

  static Monster get assassino => Monster(
    name: "Assassino",
    hp: 120,
    atk: 30,
    def: 15,
    expValue: 40,
    isBoss: true,
    elemento: Elemento.fogo,
    imagePath: 'assets/monsters/assasino.webp',
  );

  static Monster get acougueiro => Monster(
    name: "Açougueiro",
    hp: 180,
    atk: 35,
    def: 20,
    expValue: 50,
    isBoss: true,
    elemento: Elemento.fogo,
    imagePath: 'assets/monsters/acougueiro.webp',
  );

  static Monster get viceLider => Monster(
    name: "Vice-Líder",
    hp: 250,
    atk: 45,
    def: 25,
    expValue: 75,
    isBoss: true,
    elemento: Elemento.fogo,
    imagePath: 'assets/monsters/vicelider.webp',
  );

  static Monster get liderBandido => Monster(
    name: "Líder Bandido",
    hp: 450,
    atk: 60,
    def: 35,
    expValue: 150,
    isBoss: true,
    elemento: Elemento.fogo,
    imagePath: 'assets/monsters/liderbandido.webp',
  );

  // --- LAGOA ENCANTADA ---
  static Monster get driade => Monster(
    name: "Dríade",
    hp: 350,
    atk: 70,
    def: 50,
    expValue: 120,
    elemento: Elemento.terra,
    imagePath: 'assets/monsters/driade.webp',
  );

  static Monster get verme => Monster(
    name: "Verme",
    hp: 220,
    atk: 55,
    def: 40,
    expValue: 90,
    elemento: Elemento.terra,
    imagePath: 'assets/monsters/verme.webp',
  );

  // 🌟 NOVO MONSTRO DA LAGOA 1
  static Monster get sereiaCorrompida => Monster(
    name: "Sereia Corrompida",
    hp: 400,
    atk: 80,
    def: 45,
    expValue: 130,
    elemento: Elemento.agua,
    imagePath: 'assets/monsters/sereia_corrompida.webp',
  );

  // 🌟 NOVO MONSTRO DA LAGOA 2
  static Monster get jacareDoPantano => Monster(
    name: "Jacaré do Pântano",
    hp: 480,
    atk: 75,
    def: 70,
    expValue: 135,
    elemento: Elemento.agua,
    imagePath: 'assets/monsters/jacare_pantano.webp',
  );

  static Monster get tritao => Monster(
    name: "Tritão",
    hp: 500,
    atk: 85,
    def: 60,
    expValue: 140,
    elemento: Elemento.agua,
    imagePath: 'assets/monsters/tritao.webp',
  );

  static Monster get leviata => Monster(
    name: "Leviatã",
    hp: 1200,
    atk: 120,
    def: 80,
    expValue: 300,
    isBoss: true,
    elemento: Elemento.agua,
    imagePath: 'assets/monsters/leviata.webp',
  );
}
