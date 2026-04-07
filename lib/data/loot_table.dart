import 'dart:math';
import 'item_data.dart';
import '../models/game_state.dart';

class LootTable {
  static final _random = Random();

  static List<Item> getDrops(String monsterName) {
    List<Item> droppedItems = [];

    switch (monsterName) {
      // --- MONSTROS DA VILA ---
      case "Abelha Operária":
        if (_random.nextDouble() <= 0.9) {
          // <--- ABRE BLOCO
          droppedItems.add(ItemData.ferraoAbelha.copy());
        } // <--- FECHA BLOCO
        break;

      case "Coelho Saltitante":
        if (_random.nextDouble() <= 0.8) {
          droppedItems.add(ItemData.pedeCoelho.copy());
        }
        break;

      case "Rato de Esgoto":
        if (_random.nextDouble() <= 0.8) {
          droppedItems.add(ItemData.caudaRato.copy());
        }
        break;

      case "Águia Real":
        droppedItems.add(ItemData.penaDourada.copy());

        break;

      // --- MONSTROS DA FLORESTA ---
      case "Goblin":
        if (_random.nextDouble() <= 0.8) {
          droppedItems.add(ItemData.linguaGoblin.copy());
        }
        if (_random.nextDouble() <= 0.4) {
          droppedItems.add(ItemData.adagaVelha.copy());
        }
        break;

      case "Lobo Selvagem":
        if (_random.nextDouble() <= 0.5) {
          droppedItems.add(ItemData.peleLobo.copy());
        }
        break;

      case "Slime":
        droppedItems.add(ItemData.aguaSlime.copy());
        break;

      case "Aranha de Elite":
        droppedItems.add(ItemData.patadeAranha.copy());
        if (_random.nextDouble() <= 0.4) {
          droppedItems.add(ItemData.adagaVelha.copy());
        }
        break;
    }

    return droppedItems;
  }
}
