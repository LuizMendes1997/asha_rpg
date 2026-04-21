import 'quest_model.dart'; // Mantive o import pois HeroModel usa a classe Quest
import 'package:flutter/material.dart';

enum Raca { humano, elfo, dragoniano }

enum ItemType { weapon, armor, helmet, boots, necklace, ring, potion, material }

class Item {
  final String name;
  final ItemType type;
  final int power;
  final int price;
  final String iconPath;
  int quantity;
  final bool isStackable;
  int level;
  final int def;
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
    this.hpBonus = 0,
  });
  int get totalDef => def + (level * 2);
  int get totalHpBonus => hpBonus + (level * 5);
  int get totalPower => power + (level * 2);
  String get displayName => level > 0 ? "$name +$level" : name;
  Map<String, dynamic> get mainStat {
    if (power > 0) {
      return {
        "label": "ATK",
        "value": totalPower,
        "next": totalPower + 2,
        "color": Colors.redAccent,
      };
    }
    if (def > 0) {
      return {
        "label": "DEF",
        "value": totalDef,
        "next": totalDef + 2,
        "color": Colors.blueAccent,
      };
    }
    if (hpBonus > 0) {
      return {
        "label": "HP",
        "value": totalHpBonus,
        "next": totalHpBonus + 5,
        "color": Colors.greenAccent,
      };
    }
    return {"label": "---", "value": 0, "next": 0, "color": Colors.white};
  }

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
      level: level,
    );
  }
}

class Monster {
  final String name;
  final int hp;
  final int atk;
  final int def;
  final int expValue;
  final String imagePath;
  final bool isBoss;

  Monster({
    required this.name,
    required this.hp,
    required this.atk,
    required this.def,
    required this.expValue,
    required this.imagePath,
    this.isBoss = false,
  });
}

class HeroModel {
  // --- ATRIBUTOS BÁSICOS ---
  String name;
  Raca raca;
  int level;
  int exp;
  int nextLevelExp;
  int hp;
  int maxHp;
  int gold;
  int str;
  int def;
  String villageName;

  // --- LINHAGEM E NOBREZA ---
  int nivelLinhagem;
  int totalDoado;

  // --- VILA E ECONOMIA ---
  int populacaoCidadaos;
  int populacaoMendigos;
  int limiteMendigos;
  int ouroAcumuladoVila;
  final double producaoPorHabitante = 0.5;

  // --- EQUIPAMENTOS E INVENTÁRIO ---
  List<Item> warehouse = [];
  Item? equippedWeapon;
  Item? equippedArmor;
  Item? equippedHelmet;
  Item? equippedBoots;
  Item? equippedNecklace;
  Item? equippedRing;
  Item? equippedRing2;
  List<Quest> activeQuests = [];

  HeroModel({
    this.name = "Mendigo",
    this.raca = Raca.humano,
    this.level = 1,
    this.exp = 0,
    this.nextLevelExp = 100,
    this.hp = 0,
    this.maxHp = 0,
    this.gold = 0,
    this.str = 0,
    this.def = 0,
    this.villageName = "Vila Inicial",
    this.nivelLinhagem = 1,
    this.totalDoado = 0,
    this.populacaoCidadaos = 0,
    this.populacaoMendigos = 0,
    this.limiteMendigos = 3,
    this.ouroAcumuladoVila = 0,
  });

  // --- TÍTULOS DINÂMICOS (PARA RANKING) ---

  String get nomeTituloLinhagem {
    if (raca == Raca.elfo) {
      if (nivelLinhagem >= 20) return "Deidade Élfica";
      if (nivelLinhagem >= 15) return "Santo Arcanista";
      if (nivelLinhagem >= 10) return "Guerreiro Superior";
      if (nivelLinhagem >= 5) return "Sentinela da Floresta";
      return "Elfo Comum";
    }
    if (raca == Raca.dragoniano) {
      if (nivelLinhagem >= 20) return "Deus Eterno";
      if (nivelLinhagem >= 15) return "Soberano do Caos";
      if (nivelLinhagem >= 10) return "Lorde Dragão";
      if (nivelLinhagem >= 5) return "Drakon de Elite";
      return "Dragoniano Menor";
    }
    if (nivelLinhagem >= 20) return "Deus Humano";
    if (nivelLinhagem >= 15) return "Semideus da Guerra";
    if (nivelLinhagem >= 10) return "Santo Guerreiro";
    if (nivelLinhagem >= 5) return "Herói";
    return "Humano";
  }

  String tituloNobre = "Plebeu";
  int rankNobre = 0;
  static const List<Map<String, dynamic>> requisitosNobreza = [
    {"titulo": "Plebeu", "minDoado": 0},
    {"titulo": "Conde", "minDoado": 450},
    {"titulo": "Duque", "minDoado": 1000},
    {"titulo": "Arquiduque", "minDoado": 5000},
    {"titulo": "Príncipe", "minDoado": 10000},
    {"titulo": "Rei", "minDoado": 30000},
  ];
  void doar(int valor) {
    if (gold >= valor) {
      gold -= valor;
      totalDoado += valor;
    }
  }
  // --- CÁLCULOS DE ATRIBUTOS (GETTERS) ---

  int get bonusSTR {
    if (raca == Raca.dragoniano) return 4 * (nivelLinhagem - 1);
    return 0;
  }

  int get bonusDEF {
    if (raca == Raca.humano) return 3 * (nivelLinhagem - 1);
    return 0;
  }

  int get bonusHP {
    if (raca == Raca.elfo) return 15 * (nivelLinhagem - 1);
    return 0;
  }

  // --- CÁLCULOS DE ATRIBUTOS (GETTERS) CORRIGIDOS ---

  int get totalStr =>
      str +
      bonusSTR +
      (equippedWeapon?.totalPower ?? 0) +
      (equippedRing?.totalPower ?? 0) +
      (equippedRing2?.totalPower ?? 0);

  int get totalDef =>
      def +
      bonusDEF +
      (equippedHelmet?.totalDef ?? 0) + // Mudado de .def para .totalDef
      (equippedBoots?.totalDef ?? 0); // Mudado de .def para .totalDef

  int get totalMaxHp =>
      maxHp +
      bonusHP +
      (equippedArmor?.totalHpBonus ?? 0) +
      (equippedNecklace?.totalHpBonus ?? 0); // Adicionado caso colar dê HP

  bool get podeAventurar => hp > 0;

  // --- MÉTODOS DE PROGRESSÃO ---

  void gainExp(int amount) {
    exp += amount;
    while (exp >= nextLevelExp) {
      level++;
      exp -= nextLevelExp;
      nextLevelExp = (nextLevelExp * 1.5).toInt();
      maxHp += 10;
      hp = totalMaxHp;
      str += 2;
    }
    calculateStats();
  }

  void evoluirLinhagem() {
    nivelLinhagem++;
    calculateStats();
  }

  void calculateStats() {
    if (hp > totalMaxHp) hp = totalMaxHp;
  }

  // --- ECONOMIA DA VILA ---

  void processarFinancas() {
    int totalPessoas = populacaoCidadaos + populacaoMendigos;
    if (totalPessoas <= 0) return;
    int geracao = (totalPessoas * producaoPorHabitante).toInt();
    if (geracao <= 0) geracao = 1;
    ouroAcumuladoVila += geracao;
  }

  bool adicionarMendigo() {
    if (populacaoMendigos < limiteMendigos) {
      populacaoMendigos++;
      return true;
    }
    return false;
  }

  // --- QUESTS E COMBATE ---

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

  // --- GESTÃO DE INVENTÁRIO ---

  void addItem(Item newItem) {
    if (newItem.isStackable) {
      // Busca ignorando maiúsculas/minúsculas e espaços extras
      int index = warehouse.indexWhere(
        (item) =>
            item.name.trim().toLowerCase() == newItem.name.trim().toLowerCase(),
      );

      if (index != -1) {
        // DEBUG: Descomente a linha abaixo para ver no console se ele achou
        print("Achou o item ${newItem.name}, somando ${newItem.quantity}");
        warehouse[index].quantity += newItem.quantity;
        return;
      }
    }

    // Se não achou ou não for stackable, adiciona um novo slot
    warehouse.add(newItem.copy());
  }

  void equipItem(Item item) {
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
        if (equippedRing == null)
          equippedRing = item;
        else if (equippedRing2 == null)
          equippedRing2 = item;
        else {
          swap(equippedRing);
          equippedRing = item;
        }
        break;
      default:
        return;
    }
    warehouse.remove(item);
    calculateStats();
  }

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
