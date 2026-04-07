import 'package:flutter/material.dart';
import '../models/game_state.dart';

class MarketScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;
  const MarketScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  // Lógica de compra e venda (a mesma que você já tinha)

  // No build do MarketScreen, remova o ListTile de COMPRA DE COMIDA e deixe apenas a venda:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Mercado Imperial"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "NEGOCIAR DESPOJOS DE GUERRA",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: widget.hero.warehouse.isEmpty
                ? const Center(
                    child: Text(
                      "Sua bolsa está vazia.",
                      style: TextStyle(color: Colors.white24),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.hero.warehouse.length,
                    itemBuilder: (c, i) {
                      final item = widget.hero.warehouse[i];
                      return ListTile(
                        leading: Image.asset(
                          item.iconPath,
                          width: 32,
                          filterQuality: FilterQuality.none,
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "${item.price * item.quantity}g total",
                          style: const TextStyle(color: Colors.green),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              widget.hero.gold += (item.price * item.quantity);
                              widget.hero.warehouse.removeAt(i);
                            });
                            widget.onUpdate();
                          },
                          child: const Text("VENDER TUDO"),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
