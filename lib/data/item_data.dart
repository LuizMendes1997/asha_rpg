import '../models/game_state.dart';

class ItemData {
  // --- MATERIAIS DE MONSTROS ---
  static Item linguaGoblin = Item(
    name: "Língua de Goblin",
    type: ItemType.material,
    price: 2,
    isStackable: true,
    iconPath: 'assets/icons/linguaGoblin.webp',
  );

  static Item patadeAranha = Item(
    name: "Pata de Aranha",
    type: ItemType.material,
    price: 50,
    isStackable: true,
    iconPath: 'assets/icons/patadeAranha.webp',
  );

  static Item peleLobo = Item(
    name: "Pele de Lobo",
    type: ItemType.material,
    price: 5,
    isStackable: true,
    iconPath: 'assets/icons/peleLobo.webp',
  );

  static Item aguaSlime = Item(
    name: "Água de Slime",
    type: ItemType.material,
    price: 1,
    isStackable: true,
    iconPath: 'assets/icons/aguaSlime.webp',
  );

  static Item ferraoAbelha = Item(
    name: "Ferrão de Abelha",
    type: ItemType.material,
    price: 2,
    isStackable: true,
    iconPath: 'assets/icons/ferrao.webp',
  );

  static Item pedeCoelho = Item(
    name: "Pé de Coelho",
    type: ItemType.material,
    price: 8,
    isStackable: true,
    iconPath: 'assets/icons/pe_coelho.webp',
  );

  static Item caudaRato = Item(
    name: "Cauda de Rato",
    type: ItemType.material,
    price: 3,
    isStackable: true,
    iconPath: 'assets/icons/caudaRato.webp',
  );

  static Item penaDourada = Item(
    name: "Pena Dourada",
    type: ItemType.material,
    price: 25,
    isStackable: true,
    iconPath: 'assets/icons/pena_dourada.webp',
  );

  // --- TIER 1: INICIANTE ---
  static Item capuzPano = Item(
    name: "Capuz de Pano",
    type: ItemType.helmet,
    def: 2,
    price: 20,
    iconPath: 'assets/icons/capuz_pano.webp',
  );

  static Item tunicaLona = Item(
    name: "Túnica de Lona",
    type: ItemType.armor,
    hpBonus: 10,
    price: 30,
    iconPath: 'assets/icons/tunica_lona.webp',
  );

  static Item sandaliaVelha = Item(
    name: "Sandália Velha",
    type: ItemType.boots,
    def: 1,
    price: 10,
    iconPath: 'assets/icons/sandalia_velha.webp',
  );

  // --- TIER 2: COURO ---
  static Item elmoCouro = Item(
    name: "Elmo de Couro",
    type: ItemType.helmet,
    def: 5,
    price: 100,
    iconPath: 'assets/icons/elmo_couro.webp',
  );

  static Item peitoralCouro = Item(
    name: "Peitoral de Couro",
    type: ItemType.armor,
    hpBonus: 30,
    price: 150,
    iconPath: 'assets/icons/peitoral_couro.webp',
  );

  static Item botaMontaria = Item(
    name: "Bota de Montaria",
    type: ItemType.boots,
    def: 3,
    price: 60,
    iconPath: 'assets/icons/bota_montaria.webp',
  );

  // --- TIER 3: FERRO / MÁGICO ---
  static Item elmoVigia = Item(
    name: "Elmo do Vigia",
    type: ItemType.helmet,
    def: 12,
    price: 400,
    iconPath: 'assets/icons/elmo_vigia.webp',
  );

  static Item cotaDestemido = Item(
    name: "Cota do Destemido",
    type: ItemType.armor,
    hpBonus: 80,
    price: 550,
    iconPath: 'assets/icons/cota_destemido.webp',
  );

  static Item botasBronze = Item(
    name: "Botas de Bronze",
    type: ItemType.boots,
    def: 8,
    price: 300,
    iconPath: 'assets/icons/botas_bronze.webp',
  );

  // --- TIER 4: AÇO / RÚNICO ---
  static Item gritoAlvorecer = Item(
    name: "Grito do Alvorecer",
    type: ItemType.helmet,
    def: 25,
    price: 1200,
    iconPath: 'assets/icons/grito_alvorecer.webp',
  );

  static Item placaPaladino = Item(
    name: "Placa de Paladino",
    type: ItemType.armor,
    hpBonus: 200,
    price: 1800,
    iconPath: 'assets/icons/placa_paladino.webp',
  );

  static Item passoTrovao = Item(
    name: "Passo de Trovão",
    type: ItemType.boots,
    def: 18,
    price: 950,
    iconPath: 'assets/icons/passo_trovao.webp',
  );

  // --- TIER 5: CELESTIAL ---
  static Item coroaInfinito = Item(
    name: "Coroa do Infinito",
    type: ItemType.helmet,
    def: 60,
    price: 5000,
    iconPath: 'assets/icons/coroa_infinito.webp',
  );

  static Item mantoEternidade = Item(
    name: "Manto da Eternidade",
    type: ItemType.armor,
    hpBonus: 500,
    price: 7500,
    iconPath: 'assets/icons/manto_eternidade.webp',
  );

  static Item rastroEstelar = Item(
    name: "Rastro Estelar",
    type: ItemType.boots,
    def: 45,
    price: 3800,
    iconPath: 'assets/icons/rastro_estelar.webp',
  );

  // Exemplo de arma inicial seguindo seu modelo
  static Item adagaVelha = Item(
    name: "Adaga Velha",
    type: ItemType.weapon,
    power: 3,
    price: 15,
    isStackable: false,
    iconPath: 'assets/icons/adaga_velha.webp',
  );
}
