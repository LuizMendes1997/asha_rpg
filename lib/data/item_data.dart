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
  static Item fragmentosDivinos = Item(
    name: "Fragmentos Divinos",
    type: ItemType.material,
    price: 0,
    isStackable: true,
    iconPath: 'assets/icons/fragmentosDivinos.webp',
    quantity: 1,
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
    def: 1,
    price: 20,
    isStackable: false,
    iconPath: 'assets/icons/capuz_pano.webp',
  );

  static Item tunicaLona = Item(
    name: "Túnica de Lona",
    type: ItemType.armor,
    hpBonus: 10,
    price: 30,
    isStackable: false,
    iconPath: 'assets/icons/tunica_lona.webp',
  );

  static Item sandaliaVelha = Item(
    name: "Sandália Velha",
    type: ItemType.boots,
    def: 1,
    price: 10,
    isStackable: false,
    iconPath: 'assets/icons/sandalia_velha.webp',
  );

  // --- TIER 2: COURO ---
  static Item elmoCouro = Item(
    name: "Elmo de Couro",
    type: ItemType.helmet,
    def: 7,
    price: 60,
    isStackable: false,
    iconPath: 'assets/icons/elmo_couro.webp',
  );

  static Item peitoralCouro = Item(
    name: "Peitoral de Couro",
    type: ItemType.armor,
    hpBonus: 25,
    price: 70,
    isStackable: false,
    iconPath: 'assets/icons/peitoral_couro.webp',
  );

  static Item botaMontaria = Item(
    name: "Bota de Montaria",
    type: ItemType.boots,
    def: 5,
    price: 60,
    isStackable: false,
    iconPath: 'assets/icons/bota_montaria.webp',
  );

  // --- TIER 3: FERRO / MÁGICO ---
  static Item elmoVigia = Item(
    name: "Elmo do Vigia",
    type: ItemType.helmet,
    def: 15,
    price: 150,
    isStackable: false,
    iconPath: 'assets/icons/elmo_vigia.webp',
  );

  static Item cotaDestemido = Item(
    name: "Cota do Destemido",
    type: ItemType.armor,
    hpBonus: 40,
    price: 140,
    isStackable: false,
    iconPath: 'assets/icons/cota_destemido.webp',
  );

  static Item botasBronze = Item(
    name: "Botas de Bronze",
    type: ItemType.boots,
    def: 12,
    price: 100,
    isStackable: false,
    iconPath: 'assets/icons/botas_bronze.webp',
  );

  // --- TIER 4: AÇO / RÚNICO ---
  static Item gritoAlvorecer = Item(
    name: "Grito do Alvorecer",
    type: ItemType.helmet,
    def: 45,
    price: 200,
    isStackable: false,
    iconPath: 'assets/icons/grito_alvorecer.webp',
  );

  static Item placaPaladino = Item(
    name: "Placa de Paladino",
    type: ItemType.armor,
    hpBonus: 100,
    price: 250,
    isStackable: false,
    iconPath: 'assets/icons/placa_paladino.webp',
  );

  static Item passoTrovao = Item(
    name: "Passo de Trovão",
    type: ItemType.boots,
    def: 30,
    price: 180,
    isStackable: false,
    iconPath: 'assets/icons/passo_trovao.webp',
  );

  // --- TIER 5: CELESTIAL ---
  static Item coroaInfinito = Item(
    name: "Coroa do Infinito",
    type: ItemType.helmet,
    def: 60,
    price: 200,
    isStackable: false,
    iconPath: 'assets/icons/coroa_infinito.webp',
  );

  static Item mantoEternidade = Item(
    name: "Manto da Eternidade",
    type: ItemType.armor,
    hpBonus: 500,
    price: 100,
    isStackable: false,
    iconPath: 'assets/icons/manto_eternidade.webp',
  );

  static Item rastroEstelar = Item(
    name: "Rastro Estelar",
    type: ItemType.boots,
    def: 45,
    price: 100,
    isStackable: false,
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

  static Item espadacomum = Item(
    name: "Espada Comum",
    type: ItemType.weapon,
    power: 12,
    price: 45,
    isStackable: false,
    iconPath: 'assets/icons/espadacomum.webp',
  );

  static Item laminaPrata = Item(
    name: "Lâmina de Prata Refinada",
    type: ItemType.weapon,
    power: 22,
    price: 120,
    isStackable: false,
    iconPath: 'assets/icons/laminaprata.webp',
  );

  static Item armadoVendaval = Item(
    name: "Espada do Vendaval",
    type: ItemType.weapon,
    power: 35,
    price: 150,
    isStackable: false,
    iconPath: 'assets/icons/espadadovendaval.webp',
  );

  static Item devoradoraSois = Item(
    name: "Devoradora de Sóis",
    type: ItemType.weapon,
    power: 80,
    price: 300,
    isStackable: false,
    iconPath: 'assets/icons/devoradoradesois.webp',
  );
}
