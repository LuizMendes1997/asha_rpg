import 'quest_model.dart';
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
  int nivelLinhagem;
  int totalDoado;
  int populacaoCidadaos;
  int populacaoMendigos;
  int limiteMendigos;
  int ouroAcumuladoVila;
  final double producaoPorHabitante = 0.5;

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
    this.hp = 100,
    this.maxHp = 100,
    this.gold = 0,
    this.str = 10,
    this.def = 0,
    this.villageName = "Vila Inicial",
    this.nivelLinhagem = 1,
    this.totalDoado = 0,
    this.populacaoCidadaos = 0,
    this.populacaoMendigos = 0,
    this.limiteMendigos = 3,
    this.ouroAcumuladoVila = 0,
  });

  String get nomeTituloLinhagem {
    if (raca == Raca.elfo) {
      if (nivelLinhagem >= 20) return "Deidade Élfica";
      if (nivelLinhagem >= 15) return "Santo Arcanista";
      if (nivelLinhagem >= 10) return "Guerreiro Superior";
      if (nivelLinhagem >= 5) return "Sentinela da Floresta";
      return "Elfo Comum";
    }
    if (raca == Raca.dragoniano) {
      if (nivelLinhagem >= 20) return "Imperador Eterno";
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

  String get tituloNobre {
    if (totalDoado >= 30000) return "Rei";
    if (totalDoado >= 10000) return "Príncipe";
    if (totalDoado >= 5000) return "Arquiduque";
    if (totalDoado >= 1000) return "Duque";
    if (totalDoado >= 450) return "Conde";
    return "Plebeu";
  }

  void doar(int valor) {
    if (gold >= valor) {
      gold -= valor;
      totalDoado += valor;
    }
  }

  int get bonusSTR {
    if (raca == Raca.dragoniano) return 5 * nivelLinhagem;
    if (raca == Raca.humano) return 2 * nivelLinhagem;
    return 0;
  }

  int get bonusDEF {
    if (raca == Raca.elfo) return 5 * nivelLinhagem;
    if (raca == Raca.humano) return 3 * nivelLinhagem;
    return 0;
  }

  int get bonusHP {
    if (raca == Raca.elfo) return 15 * (nivelLinhagem - 1);
    return 0;
  }

  int get totalStr =>
      str +
      bonusSTR +
      (equippedWeapon?.totalPower ?? 0) +
      (equippedRing?.totalPower ?? 0) +
      (equippedRing2?.totalPower ?? 0);

  int get totalDef =>
      def +
      bonusDEF +
      (equippedArmor?.totalDef ?? 0) +
      (equippedHelmet?.totalDef ?? 0) +
      (equippedBoots?.totalDef ?? 0);

  int get totalMaxHp => maxHp + bonusHP + (equippedArmor?.totalHpBonus ?? 0);

  bool get podeAventurar => hp > 0;

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

  void processarFinancas() {
    int totalPessoas = populacaoCidadaos + populacaoMendigos;
    if (totalPessoas <= 0) return;
    int geracao = (totalPessoas * producaoPorHabitante).toInt();
    if (geracao <= 0) geracao = 1;
    ouroAcumuladoVila += geracao;
  }

  void addItem(Item newItem) {
    if (newItem.isStackable) {
      int index = warehouse.indexWhere(
        (item) =>
            item.name.trim().toLowerCase() == newItem.name.trim().toLowerCase(),
      );
      if (index != -1) {
        warehouse[index].quantity += newItem.quantity;
        return;
      }
    }
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
