import 'dart:math';
import 'item_data.dart';
import '../models/game_state.dart';

class LootTable {
  static final _random = Random();

  static List<Item> getDrops(String monsterName) {
    List<Item> droppedItems = [];

    if (_random.nextDouble() <= 0.99) {
      Item drop = ItemData.fragmentosDivinos.copy();
      drop.quantity = 1;
      droppedItems.add(drop);
    }

    switch (monsterName) {
      // --- MONSTROS DA VILA ---
      case "Abelha Operária":
        if (_random.nextDouble() <= 0.4) {
          droppedItems.add(ItemData.ferraoAbelha.copy());
        }
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.capuzPano.copy());
        }
        break;
      case "Cobra Venenosa":
        if (_random.nextDouble() <= 0.4) {
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

      // 🌟 DROPS DOS NOVOS MONSTROS DA VILA (Foco: Arma comum / Peitoral inicial)
      case "Vespa Mutante":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(
            ItemData.espadacomum.copy(),
          ); // Arma comum vira drop alternativo aqui
        }
        break;
      case "Espantalho Assombrado":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(
            ItemData.espadacomum.copy(),
          ); // Peitoral muito básico da vila
        }
        break;

      case "Águia Real":
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
          droppedItems.add(
            ItemData.peitoralCouro.copy(),
          ); // Peitoral de Couro existente
        }
        break;
      case "Slime":
        droppedItems.add(ItemData.aguaSlime.copy());
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.botasBronze.copy());
        }
        break;

      // 🌟 DROPS DOS NOVOS MONSTROS DA FLORESTA (Foco: Arma cortante / Peitoral intermediário)
      case "Urso Cinzento":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(
            ItemData.peitoralCouro.copy(),
          ); // Peitoral intermediário robusto
        }
        break;
      case "Fada Travessa":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(
            ItemData.laminaPrata.copy(),
          ); // Arma intermediária com tema de selva
        }
        break;

      case "Rainha Aranha":
        droppedItems.add(ItemData.patadeAranha.copy());
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.laminaPrata.copy());
        }
        break;

      // --- ACAMPAMENTO DE BANDIDOS ---
      // 🌟 DROPS DOS NOVOS MONSTROS DO ACAMPAMENTO (Foco: Armas / Peitorais de bandido)
      case "Saqueador Mercenário":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(
            ItemData.elmoVigia.copy(),
          ); // Arma ágil de fogo ou corte
        }
        break;
      case "Cão de Caça":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(
            ItemData.armadoVendaval.copy(),
          ); // Peitoral de malha leve dos criminosos
        }
        break;

      case "Assassino":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.elmoVigia.copy());
        }
        break;
      case "Açougueiro":
        if (_random.nextDouble() <= 0.5) {
          droppedItems.add(ItemData.botasBronze.copy());
        }
        break;
      case "Vice-Líder":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.cotaDestemido.copy());
        }
        break;
      case "Líder Bandido":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.armadoVendaval.copy());
        }
        break;

      // --- LAGOA ENCANTADA ---
      case "Dríade":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.gritoAlvorecer.copy());
        }
        break;
      case "Verme":
        if (_random.nextDouble() <= 0.5) {
          droppedItems.add(ItemData.placaPaladino.copy());
        }
        break;

      // 🌟 DROPS DOS NOVOS MONSTROS DA LAGOA ENCANTADA (Foco: Itens End-game fortes)
      case "Sereia Corrompida":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(
            ItemData.gritoAlvorecer.copy(),
          ); // Arma de fim de jogo com tema de água
        }
        break;
      case "Jacaré do Pântano":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(
            ItemData.devoradoraSois.copy(),
          ); // Peitoral de alta armadura e defesa
        }
        break;

      case "Tritão":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.passoTrovao.copy());
        }
        break;
      case "Leviatã":
        if (_random.nextDouble() <= 0.2) {
          droppedItems.add(ItemData.devoradoraSois.copy());
        }
        break;
    }

    return droppedItems.map((item) => item.gerarElementoAleatorio()).toList();
  }
}
