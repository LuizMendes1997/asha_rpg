import 'package:flutter/material.dart';
import '../models/game_state.dart';

class LojaDoFeiticeiro extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const LojaDoFeiticeiro({
    super.key,
    required this.hero,
    required this.onUpdate,
  });

  @override
  State<LojaDoFeiticeiro> createState() => _LojaDoFeiticeiroState();
}

class _LojaDoFeiticeiroState extends State<LojaDoFeiticeiro> {
  Item? _slot1;
  Item? _slot2;

  void _selecionarItem(Item item) {
    setState(() {
      if (_slot1 == null) {
        _slot1 = item;
      } else if (_slot2 == null && item != _slot1) {
        // Validação estrita: Nome, Raridade e Elemento devem ser iguais
        if (item.name == _slot1!.name &&
            item.raridade == _slot1!.raridade &&
            item.elemento == _slot1!.elemento) {
          _slot2 = item;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Apenas itens idênticos podem ser fundidos!"),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _executarFusao() {
    if (_slot1 != null && _slot2 != null) {
      widget.hero.fundirItens(_slot1!, _slot2!);
      setState(() {
        _slot1 = null;
        _slot2 = null;
      });
      widget.onUpdate();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fusão realizada com sucesso!"),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("TORRE MÁGICA", style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.purple[900],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Slots de Fusão
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSlot(_slot1, () => setState(() => _slot1 = null)),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.add, color: Colors.purple, size: 30),
              ),
              _buildSlot(_slot2, () => setState(() => _slot2 = null)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[800],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: (_slot1 != null && _slot2 != null)
                ? _executarFusao
                : null,
            child: const Text(
              "FUSIONAR",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const Divider(color: Colors.white24, height: 40),
          // Lista de itens disponíveis
          Expanded(
            child: ListView.builder(
              itemCount: widget.hero.warehouse.length,
              itemBuilder: (context, index) {
                final item = widget.hero.warehouse[index];
                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.asset(item.iconPath, fit: BoxFit.cover),
                  ),
                  title: Text(
                    "${item.name} (${item.raridade.name})",
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Elemento: ${item.elemento}",
                    style: TextStyle(color: Colors.purple[200]),
                  ),
                  onTap: () => _selecionarItem(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(Item? item, VoidCallback onRemove) {
    return GestureDetector(
      onTap: item != null ? onRemove : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white10,
          border: Border.all(color: Colors.purple, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: item == null
            ? const Icon(Icons.add, color: Colors.white24, size: 40)
            : Image.asset(item.iconPath, fit: BoxFit.cover),
      ),
    );
  }
}
