import 'package:flutter/material.dart';
import '../models/game_state.dart';

class InventoryScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;
  const InventoryScreen({
    super.key,
    required this.hero,
    required this.onUpdate,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Gestão de Itens"),
          backgroundColor: Colors.grey[900],
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: "Armazém"),
              Tab(text: "Equipados"),
            ],
          ),
        ),
        body: TabBarView(children: [_buildWarehouse(), _buildEquipped()]),
      ),
    );
  }

  Widget _buildEquipped() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // --- PAINEL DE STATUS SUPERIOR ---
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statInfo(
                  "⚔️ ATAQUE",
                  "${widget.hero.totalStr}",
                  Colors.redAccent,
                ),
                _statInfo(
                  "🛡️ DEFESA",
                  "${widget.hero.totalDef}",
                  Colors.blueAccent,
                ),
                _statInfo(
                  "❤️ HP",
                  "${widget.hero.hp}/${widget.hero.totalMaxHp}",
                  Colors.greenAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // --- GRID DE EQUIPAMENTOS (ESTRUTURA COMPACTA) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Coluna da Esquerda
              Column(
                children: [
                  _visualSlot(
                    "ELMO",
                    widget.hero.equippedHelmet,
                    ItemType.helmet,
                  ),
                  const SizedBox(height: 20),
                  _visualSlot(
                    "PEITORAL",
                    widget.hero.equippedArmor,
                    ItemType.armor,
                  ),
                ],
              ),

              // Centro: Imagem do Herói
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const Icon(Icons.person, size: 140, color: Colors.white10),
                    Text(
                      widget.hero.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Coluna da Direita
              Column(
                children: [
                  _visualSlot(
                    "ARMA",
                    widget.hero.equippedWeapon,
                    ItemType.weapon,
                  ),
                  const SizedBox(height: 20),
                  _visualSlot(
                    "BOTA",
                    widget.hero.equippedBoots,
                    ItemType.boots,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // ACESSÓRIOS (Colar e Dois Anéis)
          const Text(
            "ACESSÓRIOS",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _visualSlot(
                "COLAR",
                widget.hero.equippedNecklace,
                ItemType.necklace,
              ),
              const SizedBox(width: 15),
              _visualSlot("ANEL 1", widget.hero.equippedRing, ItemType.ring),
              const SizedBox(width: 15),
              // Slot extra de Anel (Para funcionar, você deve ter 'equippedRing2' no seu HeroModel)
              _visualSlot("ANEL 2", widget.hero.equippedRing2, ItemType.ring),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "DICA: Toque em um item equipado para removê-lo.",
            style: TextStyle(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _visualSlot(String label, Item? item, ItemType type) {
    return GestureDetector(
      onTap: item != null
          ? () {
              setState(() {
                widget.hero.unequipItem(type);
              });
              widget.onUpdate();
            }
          : null,
      child: Column(
        children: [
          Stack(
            // Usamos Stack para sobrepor o nível ao ícone
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: item != null
                        ? Colors.amber.withOpacity(0.8)
                        : Colors.white12,
                    width: 2,
                  ),
                ),
                child: item != null
                    ? Image.asset(
                        item.iconPath,
                        width: 35,
                        filterQuality: FilterQuality.none,
                      )
                    : Center(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white12,
                            fontSize: 9,
                          ),
                        ),
                      ),
              ),
              // --- INDICADOR DE NÍVEL (+1, +2...) ---
              if (item != null && item.level > 0)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.amber, width: 0.5),
                    ),
                    child: Text(
                      "+${item.level}",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouse() {
    if (widget.hero.warehouse.isEmpty) {
      return const Center(
        child: Text(
          "Armazém vazio...",
          style: TextStyle(color: Colors.white24),
        ),
      );
    }
    return ListView.builder(
      itemCount: widget.hero.warehouse.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        final item = widget.hero.warehouse[index];

        // Verifica se o item é algo equipável
        bool canEquip =
            item.type != ItemType.material && item.type != ItemType.potion;

        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Image.asset(
              item.iconPath,
              width: 32,
              filterQuality: FilterQuality.none,
            ),
            title: Text(
              item.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Valor: ${item.price}g | ${item.type.name.toUpperCase()}",
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            trailing: canEquip
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[800],
                    ),
                    onPressed: () {
                      setState(() {
                        widget.hero.equipItem(item);
                      });
                      widget.onUpdate();
                    },
                    child: const Text(
                      "Equipar",
                      style: TextStyle(color: Colors.black, fontSize: 11),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
