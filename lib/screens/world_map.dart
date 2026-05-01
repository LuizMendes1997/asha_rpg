import 'package:flutter/material.dart';
import 'dart:math';
import '../models/game_state.dart';
import '../data/monster_data.dart';
import 'Battle_Screen.dart';
import 'DemonCastleScreen.dart';
import 'magic_tower_screen.dart';

class WorldMap extends StatelessWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const WorldMap({super.key, required this.hero, required this.onUpdate});

  void _explorar(BuildContext context, String regiao) {
    final random = Random();
    double sorteio = random.nextDouble();

    List<Monster> inimigos = [];
    String mensagem = "";
    String imagemFundo = "assets/images/mapamundo.webp";

    if (regiao == "Saida da Vila") {
      imagemFundo = "assets/images/entrada_vila.webp";
      if (sorteio < 0.05) {
        inimigos = [MonsterData.aguiaReal];
        mensagem = "A sombra de uma lenda paira sobre você: Águia Real!";
      } else if (sorteio < 0.20) {
        inimigos = [MonsterData.cobra, MonsterData.cobra];
        mensagem = "Uma cobra venenosa bloqueia o caminho!";
      } else if (sorteio < 0.55) {
        inimigos = [MonsterData.abelha, MonsterData.abelha, MonsterData.abelha];
        mensagem = "Um bando de abelhas cercou você!";
      } else {
        inimigos = [MonsterData.rato];
        mensagem = "Um rato, ataque!";
      }
    } else if (regiao == "Floresta Esquecida") {
      imagemFundo = "assets/images/floresta.webp";
      if (sorteio < 0.05) {
        inimigos = [MonsterData.rainhaAranha];
        mensagem =
            "Teias por todo lado... A Aranha de Elite desce das árvores!";
      } else if (sorteio < 0.20) {
        inimigos = [MonsterData.lobo, MonsterData.lobo];
        mensagem = "Lobos Selvagens cercam você rosnando!";
      } else if (sorteio < 0.55) {
        inimigos = [MonsterData.goblin, MonsterData.slime, MonsterData.goblin];
        mensagem = "Uma emboscada! Goblins e Slimes surgem do mato!";
      } else {
        inimigos = [MonsterData.slime];
        mensagem = "Um slime na área.";
      }
    } else if (regiao == "Acampamento de Bandidos") {
      imagemFundo = "assets/images/acampamento.webp";
      if (sorteio < 0.05) {
        inimigos = [MonsterData.liderBandido];
        mensagem = "O mais forte chegou, corraaaaa!";
      } else if (sorteio < 0.20) {
        inimigos = [MonsterData.viceLider];
        mensagem = "O vice Lider te encara";
      } else if (sorteio < 0.55) {
        inimigos = [MonsterData.acougueiro];
        mensagem = "Um açougueiro quer te matar!";
      } else {
        inimigos = [MonsterData.assasino];
        mensagem = "Uma assasino!";
      }
    } else if (regiao == "Lagoa Encantada") {
      imagemFundo = "assets/images/lagoa.webp";
      if (sorteio < 0.05) {
        inimigos = [MonsterData.leviata];
        mensagem = "O mais forte chegou, corraaaaa!";
      } else if (sorteio < 0.20) {
        inimigos = [MonsterData.tritao];
        mensagem = "O tritao te encara";
      } else if (sorteio < 0.55) {
        inimigos = [MonsterData.driade];
        mensagem = "Uma driade corrompida quer te matar!";
      } else {
        inimigos = [MonsterData.verme, MonsterData.verme];
        mensagem = "Vermes!";
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BattleScreen(
          hero: hero,
          enemies: inimigos,
          startMessage: mensagem,
          backgroundImage: imagemFundo,
          onUpdate: onUpdate,
        ),
      ),
    ).then((_) => onUpdate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "MAPA DO MUNDO",
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black54,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/mapamundo.webp"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "ESCOLHA SEU DESTINO",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
            ),
            const SizedBox(height: 10),

            _regionCard(
              context,
              "Saida da Vila",
              "Campos abertos e perigos menores.",
              "assets/icons/mapamundo/vila.webp",
              Colors.white,
              () => _explorar(context, "Saida da Vila"),
            ),

            _regionCard(
              context,
              "Floresta Esquecida",
              "Árvores densas e feras selvagens.",
              "assets/icons/mapamundo/floresta.webp",
              Colors.greenAccent,
              () => _explorar(context, "Floresta Esquecida"),
            ),

            _regionCard(
              context,
              "Acampamento de Bandidos",
              "Nível Recomendado: 5 | Risco de Morte",
              "assets/icons/mapamundo/acampamento.webp",
              Colors.orangeAccent,
              () => _explorar(context, "Acampamento de Bandidos"),
            ),

            _regionCard(
              context,
              "Lagoa Encantada",
              "Bloqueado: Requer Nível 15",
              "assets/icons/mapamundo/lagoa.webp",
              Colors.lightBlueAccent,
              () => _explorar(context, "Lagoa Encantada"),
            ),
            _regionCard(
              context,
              "Torre Mágica",
              "Suba andares infinitos por ouro.",
              "assets/icons/mapamundo/torre.webp", // Crie esta imagem
              Colors.cyanAccent,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MagicTowerScreen(hero: hero, onUpdate: onUpdate),
                  ),
                );
              },
            ),
            // CARD DO CASTELO
            Stack(
              clipBehavior: Clip.none,
              children: [
                _regionCard(
                  context,
                  "Castelo do Rei Demônio",
                  hero.level >= 1
                      ? "Desafio Diário: 7 Batalhas"
                      : "Bloqueado: Requer Nível 5",
                  "assets/icons/mapamundo/castelo_icone.webp", // Caminho atualizado
                  hero.level >= 1 ? Colors.redAccent : Colors.grey,
                  () {
                    if (hero.level >= 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DemonCastleScreen(
                            hero: hero,
                            onUpdate: onUpdate, // USA O ONUPDATE DO CONSTRUTOR
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Nível insuficiente!"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  isEvent: true,
                ),
                Positioned(
                  top: -10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Text(
                      "EVENTO",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _regionCard(
    BuildContext context,
    String title,
    String subtitle,
    String imagePath,
    Color borderColor,
    VoidCallback onTap, {
    bool isEvent = false,
  }) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: borderColor.withOpacity(0.5), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.castle, color: Colors.red, size: 50),
          ),
        ),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.amber),
        onTap: onTap,
      ),
    );
  }
}
