import 'package:flutter/material.dart';
import 'dart:math';
import '../models/game_state.dart';
import '../data/monster_data.dart';
import 'Battle_Screen.dart';

class WorldMap extends StatelessWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const WorldMap({super.key, required this.hero, required this.onUpdate});

  void _explorar(BuildContext context, String regiao) {
    final random = Random();
    double sorteio = random.nextDouble();

    List<Monster> inimigos = [];
    String mensagem = "";
    String imagemFundo = "assets/backgrounds/default.webp";

    // --- LÓGICA DE REGIÕES E ENCONTROS ---
    if (regiao == "Saida da Vila") {
      imagemFundo = "assets/images/entrada_vila.webp";

      if (sorteio < 0.05) {
        inimigos = [MonsterData.aguiaReal];
        mensagem = "A sombra de uma lenda paira sobre você: Águia Real!";
      } else if (sorteio < 0.15) {
        inimigos = [MonsterData.abelha, MonsterData.abelha, MonsterData.abelha];
        mensagem = "Um bando de abelhas cercou você!";
      } else if (sorteio < 0.45) {
        inimigos = [MonsterData.cobra, MonsterData.cobra];
        mensagem = "Uma cobra venenosa bloqueia o caminho!";
      } else if (sorteio < 0.85) {
        inimigos = [MonsterData.rato];
        mensagem = "Um rato, ataque!";
      }
    } else if (regiao == "Floresta Esquecida") {
      imagemFundo = "assets/backgrounds/floresta.webp";

      if (sorteio < 0.07) {
        inimigos = [MonsterData.aranhaGigante];
        mensagem =
            "Teias por todo lado... A Aranha de Elite desce das árvores!";
      } else if (sorteio < 0.20) {
        inimigos = [MonsterData.goblin, MonsterData.slime, MonsterData.goblin];
        mensagem = "Uma emboscada! Goblins e Slimes surgem do mato!";
      } else if (sorteio < 0.50) {
        inimigos = [MonsterData.lobo, MonsterData.lobo];
        mensagem = "Lobos Selvagens cercam você rosnando!";
      } else {
        inimigos = [MonsterData.goblin];
        mensagem = "Um Goblin solitário patrulha a área.";
      }
    } else if (regiao == "Acampamento de Bandidos") {
      imagemFundo = "assets/backgrounds/acampamento.webp";

      if (sorteio < 0.60) {
        // Exemplo usando monstros existentes enquanto você não cria os bandidos
        inimigos = [MonsterData.goblin, MonsterData.goblin];
        mensagem = "Os vigias do acampamento te avistaram!";
      }
    }

    // --- VERIFICAÇÃO DE ENCONTRO ---
    if (inimigos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "A área parece calma demais... você não encontrou nada.",
          ),
          backgroundColor: Colors.blueGrey,
        ),
      );
      return;
    }

    // --- NAVEGAÇÃO PARA A BATALHA ---
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BattleScreen(
          hero: hero,
          enemies: inimigos,
          startMessage: mensagem,
          backgroundImage: imagemFundo,
          onUpdate: onUpdate, // Passando a imagem do cenário!
        ),
      ),
    ).then((_) => onUpdate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("MAPA DO MUNDO", style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.green[900],
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "ESCOLHA SEU DESTINO",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          const SizedBox(height: 10),

          _regionCard(
            context,
            "Saida da Vila",
            "Campos abertos e perigos menores.",
            Icons.holiday_village,
            Colors.white,
            () => _explorar(context, "Saida da Vila"),
          ),

          _regionCard(
            context,
            "Floresta Esquecida",
            "Árvores densas e feras selvagens.",
            Icons.forest,
            Colors.green[700]!,
            () => _explorar(context, "Floresta Esquecida"),
          ),

          _regionCard(
            context,
            "Acampamento de Bandidos",
            "Nível Recomendado: 5 | Risco de Morte",
            Icons.fireplace,
            Colors.orange[900]!,
            () => _explorar(context, "Acampamento de Bandidos"),
          ),

          _regionCard(
            context,
            "Fronteira do Império",
            "Bloqueado: Requer Nível 15",
            Icons.security,
            Colors.blueGrey[800]!,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Os guardas da fronteira não te deixam passar!",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _regionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: color, size: 36),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}
