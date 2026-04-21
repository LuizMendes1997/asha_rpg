import 'dart:math';
import 'item_data.dart';
import '../models/game_state.dart';

class LootTable {
  static final _random = Random();

  static List<Item> getDrops(String monsterName) {
    List<Item> droppedItems = [];
    if (_random.nextDouble() <= 0.99) {
      Item drop = ItemData.fragmentosDivinos.copy();
      drop.quantity = 1; // Força ser 1
      droppedItems.add(drop);
    }
    switch (monsterName) {
      // --- MONSTROS DA VILA ---
      case "Abelha Operária":
        if (_random.nextDouble() <= 0.4) {
          // <--- ABRE BLOCO
          droppedItems.add(ItemData.ferraoAbelha.copy());
        } // <--- FECHA BLOCO
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.capuzPano.copy());
        }
        break;
      case "Cobra Venenosa":
        if (_random.nextDouble() <= 0.4) {
          // <--- ABRE BLOCO
          droppedItems.add(ItemData.sandaliaVelha.copy());
        }
        break;
      case "Rato de Esgoto":
        if (_random.nextDouble() <= 0.8) {
          droppedItems.add(ItemData.caudaRato.copy());
        }
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.tunicaLona.copy());
        }
        break;

      case "Aguia Real":
        droppedItems.add(ItemData.penaDourada.copy());
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.espadacomum.copy());
        }
        break;

      // --- MONSTROS DA FLORESTA ---
      case "Goblin":
        if (_random.nextDouble() <= 0.8) {
          droppedItems.add(ItemData.linguaGoblin.copy());
        }
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.elmoCouro.copy());
        }
        break;

      case "Lobo Selvagem":
        if (_random.nextDouble() <= 0.5) {
          droppedItems.add(ItemData.peleLobo.copy());
        }
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.peitoralCouro.copy());
        }
        break;

      case "Slime":
        droppedItems.add(ItemData.aguaSlime.copy());
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.botasBronze.copy());
        }
        break;

      case "Aranha de Elite":
        droppedItems.add(ItemData.patadeAranha.copy());
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.laminaPrata.copy());
        }
        break;
      // --- Acampamento de Bandidos ---
      case "Assasino":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.elmoVigia.copy());
        }
        break;

      case "Acougueiro":
        if (_random.nextDouble() <= 0.5) {
          droppedItems.add(ItemData.botasBronze.copy());
        }
        break;

      case "Lider Bandido":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.armadoVendaval.copy());
        }
        break;

      case "Vice Lider":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.cotaDestemido.copy());
        }
        break;

      // --- Lagoa Encantada ---
      case "Driade":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.gritoAlvorecer.copy());
        }
        break;

      case "Verme":
        if (_random.nextDouble() <= 0.5) {
          droppedItems.add(ItemData.placaPaladino.copy());
        }
        break;

      case "Leviata":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.devoradoraSois.copy());
        }
        break;

      case "Tritao":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.passoTrovao.copy());
        }
        break;
    }

    return droppedItems;
  }
}
