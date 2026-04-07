import 'quest_model.dart';

enum Raca { humano, elfo, dragoniano }

enum ItemType { weapon, armor, helmet, boots, necklace, ring, potion, material }

class Item {
  final String name;
  final ItemType type;
  final int power; // Poder base (Ex: Espada = 10)
  final int price;
  final String iconPath;
  int quantity;
  final bool isStackable;
  int level; // <--- NOVO: Nível de refino (0, 1, 2...)
  final int def; // Adicione se não tiver
  final int hpBonus;
  Item({
    required this.name,
    required this.type,
    required this.iconPath,
    this.power = 0,
    this.price = 0,
    this.quantity = 1,
    this.isStackable = true,
    this.level = 0,
    this.def = 0,
    this.hpBonus = 0, // Começa no zero
  });

  // Cálculo de poder: Poder Base + (Nível * 2)
  // Use isso na hora de calcular o dano na BattleScreen!
  int get totalPower => power + (level * 2);

  // Nome dinâmico: "Espada Curta +2"
  String get displayName => level > 0 ? "$name +$level" : name;

  Item copy() {
    return Item(
      name: name,
      type: type,
      iconPath: iconPath,
      power: power,
      def: def,
      hpBonus: hpBonus,
      price: price,
      quantity: quantity,
      isStackable: isStackable,
      level: level, // Não esqueça de copiar o level!
    );
  }
}

class Monster {
  final String name;
  final int hp;
  final int atk;
  final int expValue;
  final String imagePath; // <--- O caminho para o seu WebP 32x32 ou maior
  final bool isBoss;
  Monster({
    required this.name,
    required this.hp,
    required this.atk,
    required this.expValue,
    required this.imagePath,
    this.isBoss = false, // Torne obrigatório
  });
}

class HeroModel {
  Raca raca;
  int nivelLinhagem = 0;
  String name;
  int hp, maxHp, gold, str;
  List<Item> warehouse = [];
  Item? equippedWeapon;
  Item? equippedArmor;
  Item? equippedHelmet;
  Item? equippedBoots;
  Item? equippedNecklace;
  Item? equippedRing;
  Item? equippedRing2;
  int level = 1;
  String villageName;
  int exp = 0;
  int nextLevelExp = 100;
  bool get podeAventurar => hp > 0;
  // --- NOVAS VARIÁVEIS DE POPULAÇÃO ---
  int populacaoCidadaos = 0;
  int populacaoMendigos = 0;
  int limiteMendigos = 3;
  final double producaoPorHabitante = 0.5;
  int ouroAcumuladoVila = 0;
  DateTime? ultimaColeta;
  // --- NOVAS VARIÁVEIS DE NOBREZA ---
  int totalDoado = 0;
  String tituloNobre = "Plebeu";
  int rankNobre = 0;
  // Configurações de Finanças
  final int precoAlimento = 1;
  final int producaoPorCivil = 3; // 3 ouros
  final int horasParaProduzir = 2;
  void processarFinancas() {
    int totalPessoas = populacaoCidadaos + populacaoMendigos;
    if (totalPessoas <= 0) return;

    // Ouro gerado diretamente pela quantidade de pessoas
    int geracaoDesteCiclo = (totalPessoas * producaoPorHabitante).toInt();

    // Garantir que pelo menos 1 de ouro seja gerado se houver gente
    if (geracaoDesteCiclo <= 0 && totalPessoas > 0) geracaoDesteCiclo = 1;

    ouroAcumuladoVila += geracaoDesteCiclo;
  }

  int get bonusSTR {
    if (raca == Raca.dragoniano) return 5 * (nivelLinhagem + 1);
    if (raca == Raca.humano) return 2 * (nivelLinhagem + 1);
    return 0;
  }

  int get bonusDEF {
    if (raca == Raca.elfo) return 5 * (nivelLinhagem + 1);
    return 2 * (nivelLinhagem + 1);
  }

  // Quando o jogador evolui no Local de Evolução:
  void evoluirLinhagem() {
    nivelLinhagem++;
    calculateStats(); // Recalcula tudo com os novos bônus
  }
  // Remova o método comprarComida, pois não haverá mais estoque de comida

  void calculateStats() {
    // Como você usa Getters (totalStr, totalMaxHp),
    // basta garantir que o HP atual não ultrapasse o novo máximo
    if (hp > totalMaxHp) {
      hp = totalMaxHp;
    }
    // Se você tiver outros cálculos complexos no futuro, coloque-os aqui.
  }

  // Requisitos para a Sala do Trono
  static const List<Map<String, dynamic>> requisitosNobreza = [
    {"titulo": "Plebeu", "minDoado": 0},
    {"titulo": "Escudeiro", "minDoado": 500},
    {"titulo": "Cavaleiro", "minDoado": 2000},
    {"titulo": "Barão", "minDoado": 10000},
  ];

  HeroModel({
    this.raca = Raca.humano, // Valor padrão: Humano
    this.nivelLinhagem = 1, // Começa no nível 1 da linhagem
    this.name = "Mendigo",
    this.hp = 100,
    this.maxHp = 100,
    this.villageName = "Vila Inicial",
    this.gold = 0,
    this.str = 10,
  });

  // --- GETTERS CALCULADOS ---
  List<Quest> activeQuests = [];

  // Método para chamar quando um monstro morre na BattleScreen
  void onMonsterDefeated(String monsterName) {
    for (var quest in activeQuests) {
      if (quest.targetMonsterName == monsterName && !quest.isCompleted) {
        quest.currentKillCount++;
        if (quest.currentKillCount >= quest.requiredKillCount) {
          quest.isCompleted = true;
        }
      }
    }
  }

  void collectQuestReward(Quest quest) {
    if (quest.isCompleted) {
      gold += quest.rewardGold;
      gainExp(quest.rewardExp);
      activeQuests.remove(quest);
    }
  }

  // Força total com a arma
  int get totalStr {
    int bonus = 0;
    bonus += bonusSTR; // Bônus da Raça/Linhagem
    bonus += equippedWeapon?.totalPower ?? 0;
    bonus += equippedRing?.totalPower ?? 0;
    bonus += equippedRing2?.totalPower ?? 0; // Somando o Anel 2
    return str + bonus;
  }

  // Defesa total: Agora sem calças e luvas
  int get totalDef {
    int defBonus = 0;
    defBonus += bonusDEF; // Bônus da Raça/Linhagem
    defBonus += equippedArmor?.def ?? 0;
    defBonus += equippedHelmet?.def ?? 0;
    defBonus += equippedBoots?.def ?? 0;

    // Se a armadura/elmo também tiverem "power" (como no nosso Tier 4 e 5), some aqui se desejar
    return defBonus;
  }

  // HP Máximo Total
  int get totalMaxHp =>
      maxHp +
      (populacaoCidadaos + populacaoMendigos) +
      (equippedArmor?.hpBonus ?? 0);

  // --- MÉTODOS DE PROGRESSÃO ---

  void gainExp(int amount) {
    exp += amount;
    while (exp >= nextLevelExp) {
      _levelUp();
    }
  }

  void _levelUp() {
    level++;
    exp -= nextLevelExp;
    nextLevelExp = (nextLevelExp * 1.5).toInt();
    maxHp += 10;
    hp = totalMaxHp; // Cura total baseada no novo máximo com bônus
    str += 2;
    calculateStats();
  }

  // --- MÉTODOS DE POPULAÇÃO ---

  bool adicionarMendigo() {
    if (populacaoMendigos < limiteMendigos) {
      populacaoMendigos++;
      return true;
    }
    return false;
  }

  // --- MÉTODOS DE NOBREZA (TRIBUTOS) ---

  void doar(int valor) {
    if (gold >= valor) {
      gold -= valor;
      totalDoado += valor;
    }
  }

  // --- GESTÃO DE ITENS ---

  // --- GESTÃO DE ITENS (ATUALIZADA) ---

  void addItem(Item newItem) {
    if (newItem.isStackable) {
      int index = warehouse.indexWhere((item) => item.name == newItem.name);
      if (index != -1) {
        warehouse[index].quantity += newItem.quantity;
        return;
      }
    }
    // Adiciona uma cópia para evitar problemas de referência
    warehouse.add(newItem.copy());
  }

  void equipItem(Item item) {
    // Função auxiliar para devolver item antigo ao armazém
    void swap(Item? current) {
      if (current != null) addItem(current);
    }

    switch (item.type) {
      case ItemType.weapon:
        swap(equippedWeapon);
        equippedWeapon = item;
        break;
      case ItemType.armor:
        swap(equippedArmor);
        equippedArmor = item;
        break;
      case ItemType.helmet:
        swap(equippedHelmet);
        equippedHelmet = item;
        break;
      case ItemType.boots:
        swap(equippedBoots);
        equippedBoots = item;
        break;
      case ItemType.necklace:
        swap(equippedNecklace);
        equippedNecklace = item;
        break;
      case ItemType.ring:
        // Lógica para 2 anéis:
        if (equippedRing == null) {
          equippedRing = item;
        } else if (equippedRing2 == null) {
          equippedRing2 = item;
        } else {
          // Se ambos estão cheios, troca o primeiro
          swap(equippedRing);
          equippedRing = item;
        }
        break;
      default:
        return; // Itens tipo Poção ou Material não equipam
    }

    warehouse.remove(item);
    calculateStats();
  }

  // NOVO MÉTODO: Para retirar o item e ele voltar a ser vendável
  // No HeroModel, adicione o parâmetro 'type' entre os parênteses:
  void unequipItem(ItemType type, {bool isSecondSlot = false}) {
    Item? removed;

    switch (type) {
      case ItemType.weapon:
        removed = equippedWeapon;
        equippedWeapon = null;
        break;
      case ItemType.armor:
        removed = equippedArmor;
        equippedArmor = null;
        break;
      case ItemType.helmet:
        removed = equippedHelmet;
        equippedHelmet = null;
        break;
      case ItemType.boots:
        removed = equippedBoots;
        equippedBoots = null;
        break;
      case ItemType.necklace:
        removed = equippedNecklace;
        equippedNecklace = null;
        break;
      case ItemType.ring:
        // Se você tiver uma lógica na UI para o anel 2:
        if (isSecondSlot) {
          removed = equippedRing2;
          equippedRing2 = null;
        } else {
          removed = equippedRing;
          equippedRing = null;
        }
        break;
      default:
        break;
    }

    if (removed != null) {
      addItem(removed);
      calculateStats();
    }
  }
}
