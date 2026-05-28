import 'dart:math';
import 'package:flutter/material.dart';
import 'quest_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'clan_model.dart';

enum Raca { humano, elfo, dragoniano }

enum Raridade { normal, comum, incomum, raro, epico, lendario }

enum ItemType { weapon, armor, helmet, boots, necklace, ring, potion, material }

// 🧭 1. NOVO ENUM PARA O SISTEMA ELEMENTAL
enum Elemento { nenhum, fogo, vento, terra, agua }

class Item {
  final Raridade raridade;
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

  // Atributo elemental adicionado
  final Elemento elemento;

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
    this.elemento = Elemento.nenhum,
    this.raridade = Raridade.normal,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.index,
      'power': power,
      'price': price,
      'iconPath': iconPath,
      'quantity': quantity,
      'isStackable': isStackable,
      'level': level,
      'def': def,
      'hpBonus': hpBonus,
      'elemento': elemento.index,
      'raridade': raridade.index, // Salvando o elemento no banco
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      name: map['name'],
      type: ItemType.values[map['type']],
      iconPath: map['iconPath'],
      power: map['power'] ?? 0,
      price: map['price'] ?? 0,
      quantity: map['quantity'] ?? 1,
      isStackable: map['isStackable'] ?? true,
      level: map['level'] ?? 0,
      def: map['def'] ?? 0,
      hpBonus: map['hpBonus'] ?? 0,
      elemento: Elemento.values[map['elemento'] ?? 0],
      raridade: Raridade.values[map['raridade'] ?? 0], // Recuperando do banco
    );
  }

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
      elemento: elemento,
    );
  }

  // 🎰 2. FUNÇÃO DE RNG PARA DROPS DOS MONSTROS
  Item gerarElementoAleatorio() {
    if (type == ItemType.potion || type == ItemType.material) return this;

    final random = Random();
    final elementosValidos = [
      Elemento.fogo,
      Elemento.vento,
      Elemento.terra,
      Elemento.agua,
    ];
    final elementoSorteado =
        elementosValidos[random.nextInt(elementosValidos.length)];

    return Item(
      name: name,
      type: type,
      iconPath: iconPath,
      power: power,
      price: price,
      quantity: quantity,
      isStackable: false, // Itens elementais não acumulam
      level: level,
      def: def,
      hpBonus: hpBonus,
      elemento: elementoSorteado,
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
  final Elemento elemento;

  Monster({
    required this.name,
    required this.hp,
    required this.atk,
    required this.def,
    required this.expValue,
    required this.imagePath,
    required this.elemento,
    this.isBoss = false,
  });
}

class HeroModel {
  // Adicione dentro de HeroModel
  String? clanId;
  // Como você não quer mudar muito sua estrutura, vamos deixar o objeto Clan
  // opcional no HeroModel para facilitar o acesso rápido.
  Clan? myClan;
  int missoesCompletadas;
  String? id;
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
  int nivelLinhagem;
  int totalDoado;

  int maxTowerFloor;
  int questProgress;
  String? currentQuestId;

  // Nova variável local para armazenar a string formatada que vai pro Supabase
  String? elementalStats;

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
    this.missoesCompletadas = 0,
    this.id,
    this.name = "Guerreiro",
    this.raca = Raca.humano,
    this.level = 1,
    this.exp = 0,
    this.nextLevelExp = 100,
    this.hp = 100,
    this.maxHp = 100,
    this.gold = 0,
    this.str = 10,
    this.def = 0,
    this.nivelLinhagem = 1,
    this.totalDoado = 0,
    this.maxTowerFloor = 0,
    this.questProgress = 0,
    this.currentQuestId,
    this.elementalStats,
  });
  // Adicione em HeroModel.dart
  void fundirItens(Item item1, Item item2) {
    if (item1.name != item2.name ||
        item1.raridade != item2.raridade ||
        item1.elemento != item2.elemento)
      return;
    if (item1.raridade == Raridade.lendario) return;

    warehouse.remove(item1);
    warehouse.remove(item2);

    Item novoItem = Item(
      name: item1.name,
      type: item1.type,
      iconPath: item1.iconPath,
      raridade: Raridade.values[item1.raridade.index + 1],
      elemento: item1.elemento,
      power: (item1.power * 1.5).toInt(),
      def: (item1.def * 1.5).toInt(),
      hpBonus: (item1.hpBonus * 1.5).toInt(),
    );

    warehouse.add(novoItem);
    saveToSupabase();
  }

  Map<String, dynamic> toMap() {
    return {
      'username': name,
      'race': raca.index,
      'level': level,
      'exp': exp,
      'next_level_exp': nextLevelExp,
      'hp': hp,
      'max_hp': maxHp,
      'gold': gold,
      'str': str,
      'def': def,
      'nivel_linhagem': nivelLinhagem,
      'total_doado': totalDoado,
      'max_tower_floor': maxTowerFloor,
      'quest_progress': questProgress,
      'current_quest_id': currentQuestId,
      'missoes_completadas': missoesCompletadas,
      'elemental_stats': elementalStats, // Adicionado no mapa de persistência
      'warehouse': warehouse.map((i) => i.toMap()).toList(),
      'equipped_weapon': equippedWeapon?.toMap(),
      'equipped_armor': equippedArmor?.toMap(),
      'equipped_helmet': equippedHelmet?.toMap(),
      'equipped_boots': equippedBoots?.toMap(),
      'equipped_necklace': equippedNecklace?.toMap(),
      'equipped_ring': equippedRing?.toMap(),
      'equipped_ring2': equippedRing2?.toMap(),
    };
  }

  factory HeroModel.fromMap(String userId, Map<String, dynamic> map) {
    var hero = HeroModel(
      id: userId,
      name: map['username'] ?? 'Guerreiro',
      raca: Raca.values[map['race'] ?? 0],
      level: map['level'] ?? 1,
      exp: map['exp'] ?? 0,
      nextLevelExp: map['next_level_exp'] ?? 100,
      hp: map['hp'] ?? 100,
      maxHp: map['max_hp'] ?? 100,
      gold: map['gold'] ?? 0,
      str: map['str'] ?? 10,
      def: map['def'] ?? 0,
      nivelLinhagem: map['nivel_linhagem'] ?? 1,
      totalDoado: map['total_doado'] ?? 0,
      maxTowerFloor: map['max_tower_floor'] ?? 0,
      questProgress: map['quest_progress'] ?? 0,
      currentQuestId: map['current_quest_id'],
      missoesCompletadas: map['missoes_completadas'] ?? 0,
      elementalStats: map['elemental_stats'], // Recuperando do banco
    );

    if (map['warehouse'] != null) {
      hero.warehouse = (map['warehouse'] as List)
          .map((i) => Item.fromMap(i))
          .toList();
    }
    if (map['equipped_weapon'] != null)
      hero.equippedWeapon = Item.fromMap(map['equipped_weapon']);
    if (map['equipped_armor'] != null)
      hero.equippedArmor = Item.fromMap(map['equipped_armor']);
    if (map['equipped_helmet'] != null)
      hero.equippedHelmet = Item.fromMap(map['equipped_helmet']);
    if (map['equipped_boots'] != null)
      hero.equippedBoots = Item.fromMap(map['equipped_boots']);
    if (map['equipped_necklace'] != null)
      hero.equippedNecklace = Item.fromMap(map['equipped_necklace']);
    if (map['equipped_ring'] != null)
      hero.equippedRing = Item.fromMap(map['equipped_ring']);
    if (map['equipped_ring2'] != null)
      hero.equippedRing2 = Item.fromMap(map['equipped_ring2']);

    return hero;
  }

  Future<void> saveToSupabase() async {
    if (id == null) return;
    try {
      await Supabase.instance.client
          .from('profiles')
          .update(this.toMap())
          .eq('id', id!);
      debugPrint("Dados salvos com sucesso.");
    } catch (e) {
      debugPrint("Erro ao salvar dados: $e");
    }
  }

  // 📊 4. CÉREBRO ELEMENTAL: CALCULA OS BÔNUS ATIVOS DO HERÓI
  Map<Elemento, int> obterBonusElementaisAtivos() {
    final contagemPecas = <Elemento, int>{};

    final equipamentosAtuais = [
      equippedWeapon,
      equippedArmor,
      equippedHelmet,
      equippedBoots,
      equippedNecklace,
      equippedRing,
      equippedRing2,
    ];

    for (var item in equipamentosAtuais) {
      // Corrigido aqui: Removido o Elemento.none que não existia no enum
      if (item != null && item.elemento != Elemento.nenhum) {
        contagemPecas[item.elemento] = (contagemPecas[item.elemento] ?? 0) + 1;
      }
    }

    final bonusAtivados = <Elemento, int>{};

    contagemPecas.forEach((elemento, quantidade) {
      if (quantidade >= 3) {
        bonusAtivados[elemento] = quantidade * 5;
      }
    });

    return bonusAtivados;
  }

  // 🔄 ATUALIZA O CACHE STRING PARA SALVAR NO BANCO
  void atualizarCacheElemental() {
    final bonus = obterBonusElementaisAtivos();
    if (bonus.isEmpty) {
      elementalStats = null;
    } else {
      // Cria a string no formato "index_elemento:porcentagem,index_elemento:porcentagem"
      elementalStats = bonus.entries
          .map((e) => "${e.key.index}:${e.value}")
          .join(',');
    }
  }

  // --- LÓGICA DO JOGO (GETTERS RESTAURADOS) ---

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
      saveToSupabase();
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
      maxHp += 15;
      hp = totalMaxHp;
      str += 3;
    }
    calculateStats();
    saveToSupabase();
  }

  void evoluirLinhagem() {
    nivelLinhagem++;
    calculateStats();
    saveToSupabase();
  }

  void calculateStats() {
    if (hp > totalMaxHp) hp = totalMaxHp;
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
        if (equippedRing == null) {
          equippedRing = item;
        } else if (equippedRing2 == null) {
          equippedRing2 = item;
        } else {
          swap(equippedRing);
          equippedRing = item;
        }
        break;
      default:
        return;
    }
    warehouse.remove(item);
    calculateStats();
    atualizarCacheElemental(); // Atualiza a string do cache antes de salvar
    saveToSupabase();
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
      atualizarCacheElemental(); // Atualiza a string do cache antes de salvar
      saveToSupabase();
    }
  }
}
