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
        body: TabBarView(children: [_buildWarehouseTab(), _buildEquippedTab()]),
      ),
    );
  }

  // --- ABA: ARMAZÉM (Fundo inventario.webp) ---
  Widget _buildWarehouseTab() {
    return Stack(
      children: [
        _buildBackgroundImage("assets/images/inventario.webp", 0.35),
        _buildWarehouseList(),
      ],
    );
  }

  // --- ABA: EQUIPADOS (Fundo inventario2.webp) ---
  Widget _buildEquippedTab() {
    return Stack(
      children: [
        _buildBackgroundImage("assets/images/inventario2.webp", 0.35),
        _buildEquippedContent(),
      ],
    );
  }

  // Widget Utilitário para o Fundo
  Widget _buildBackgroundImage(String path, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildWarehouseList() {
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

        // 1. REGRA DE EQUIPAMENTO: Apenas itens que NÃO são materiais ou poções
        bool canEquip =
            item.type != ItemType.material && item.type != ItemType.potion;

        // 2. REGRA DE QUANTIDADE (TRAVA):
        // Só exibe o multiplicador "xN" se o item for stackable E a quantidade for maior que 1
        bool showQuantity = item.isStackable && item.quantity > 1;

        return Card(
          color: Colors.grey[900]?.withOpacity(0.7), // Fundo semi-transparente
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: canEquip ? Colors.amber.withOpacity(0.2) : Colors.white10,
              width: 1,
            ),
          ),
          child: ListTile(
            leading: SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                item.iconPath,
                filterQuality: FilterQuality.none, // Mantém o Pixel Art nítido
                fit: BoxFit.contain,
              ),
            ),
            title: Row(
              children: [
                Text(
                  item.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showQuantity)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "x${item.quantity}",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              "Status: ${item.mainStat['label']} +${item.mainStat['value']} | Valor: ${item.price}g",
              style: TextStyle(
                color: item.mainStat['color'] ?? Colors.white70,
                fontSize: 11,
              ),
            ),
            trailing: canEquip
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[800],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() => widget.hero.equipItem(item));
                      widget.onUpdate();
                    },
                    child: const Text(
                      "Equipar",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildEquippedContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Painel de Status
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[900]?.withOpacity(0.8),
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

          // Grid de Equipamentos
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              _visualSlot(
                "ANEL 2",
                widget.hero.equippedRing2,
                ItemType.ring,
                isAnel2:
                    true, // Adicione uma lógica para identificar que é o slot 2
              ),
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

  Widget _visualSlot(
    String label,
    Item? item,
    ItemType type, {
    bool isAnel2 = false,
  }) {
    return GestureDetector(
      onTap: item != null
          ? () {
              setState(() => widget.hero.unequipItem(type));
              widget.onUpdate();
            }
          : null,
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[900]?.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: item != null
                    ? Colors.amber.withOpacity(0.8)
                    : Colors.white12,
                width: 2,
              ),
            ),
            child: item != null
                ? Center(
                    child: Image.asset(
                      item.iconPath,
                      width: 35,
                      filterQuality: FilterQuality.none,
                    ),
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
          if (item != null && item.level > 0)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
}
