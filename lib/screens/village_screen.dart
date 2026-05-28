import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'guild_screen.dart';
import 'LinhagemScreen.dart';
import 'chat_screen.dart';
import 'ArenaBattleScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VillageScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;

  const VillageScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<VillageScreen> createState() => _VillageScreenState();
}

class _VillageScreenState extends State<VillageScreen> {
  int get precoEstalagem => (widget.hero.maxHp / 2).toInt();
  void _descansar() {
    if (widget.hero.gold >= precoEstalagem) {
      if (widget.hero.hp >= widget.hero.totalMaxHp) {
        _mostrarMensagem("Você já está totalmente descansado!");
        return;
      }

      setState(() {
        widget.hero.gold -= precoEstalagem;
        widget.hero.hp = widget.hero.totalMaxHp;
      });

      widget.onUpdate();
      widget.hero.saveToSupabase();
      _mostrarMensagem("Você dormiu profundamente... HP Restaurado!");
    } else {
      _mostrarMensagem(
        "Ouro insuficiente! Você precisa de $precoEstalagem de ouro.",
      );
    }
  }

  void _mostrarMensagem(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  Widget _regionCard(
    BuildContext context,
    String title,
    String subtitle,
    String imagePath,
    VoidCallback onTap,
  ) {
    return Card(
      color: Colors.grey[900]?.withOpacity(0.85),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 40,
          height: 40,
          filterQuality: FilterQuality.none,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
        onTap: onTap,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white24,
          size: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removido o AppBar para usar o Card customizado dentro do body
      body: Stack(
        children: [
          // --- 1. IMAGEM DE FUNDO ---
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/vila_fundo.webp"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay escuro para destacar o conteúdo
          Container(color: Colors.black.withOpacity(0.3)),

          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // --- CABEÇALHO: NOME DA VILA EM CARD ---
              Card(
                elevation: 10,
                color: Colors.indigo[900]?.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Colors.amber, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/vila.webp', // Ícone da Vila
                        height: 32,
                        filterQuality: FilterQuality.none,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "Village",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // --- STATUS NOBRE CENTRALIZADO ---
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Text(
                    "👑 ${widget.hero.tituloNobre}".toUpperCase(),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- CARD DA ESTALAGEM ---
              Card(
                color: Colors.grey[900]?.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/casa.webp',
                    width: 40,
                    height: 40,
                    filterQuality: FilterQuality.none,
                  ),
                  title: const Text(
                    "Estalagem do Descanso",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Recupere todo o seu HP\nCusto: $precoEstalagem Ouro",
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _descansar,
                    child: const Text(
                      "DESCANSAR",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // --- DEMAIS REGIÕES ---
              _regionCard(
                context,
                "Templo da Ancestralidade",
                "Evolua seu sangue e desperte novos poderes",
                "assets/icons/linhagem.webp", // Certifique-se de ter esse ícone ou use um temporário
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LinhagemScreen(
                        hero: widget.hero,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  );
                },
              ),
              _regionCard(
                context,
                "Guilda",
                "Recompensas e missões de aventureiros",
                "assets/icons/guilda.webp", // Sugestão: troque para assets/icons/guilda.webp se tiver
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuildScreen(
                        hero: widget.hero,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  );
                },
              ),
              _regionCard(
                context,
                "Chat",
                "Fale bem e chama geral pra porrada",
                "assets/icons/guilda.webp", // Sugestão: troque para assets/icons/guilda.webp se tiver
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        hero: widget.hero,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  );
                },
              ),
              _regionCard(context, "PVP", "Vai geral pra porrada", "assets/icons/guilda.webp", () async {
                // 1. Mostra o loading na tela para o jogador saber que está buscando partida
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.redAccent,
                      ),
                    ),
                  ),
                );

                try {
                  // 2. Busca uma lista de oponentes no Supabase (que não sejam você) sem travar por nível
                  // Terminando direto no select(), ele retorna uma List correta sem dar erro 406
                  final response = await Supabase.instance.client
                      .from('profiles')
                      .select()
                      .neq('id', widget.hero.id ?? '')
                      .limit(20);

                  // Fecha o dialog de carregamento assim que o banco responde
                  if (context.mounted) Navigator.pop(context);

                  ArenaOpponent oponenteReal;

                  // 3. Convertemos a resposta para uma Lista e validamos se ela não veio vazia
                  final listaBruta = response as List<dynamic>;

                  if (listaBruta.isNotEmpty) {
                    // Converte os dados brutos para uma lista de Maps aceita pelo Dart e embaralha
                    final listaOponentes = List<Map<String, dynamic>>.from(
                      listaBruta,
                    );
                    listaOponentes.shuffle(); // Sorteio aleatório na memória
                    final data = listaOponentes.first;

                    // Mapeamento blindado contra Null Safety e tipos genéricos do banco
                    oponenteReal = ArenaOpponent(
                      id: data['id'].toString(),
                      username:
                          (data['username'] ??
                                  data['name'] ??
                                  "Guerreiro Secreto")
                              .toString(),
                      level:
                          data['level'] as int? ??
                          1, // Agora puxa qualquer level do banco!
                      str: data['str'] as int? ?? 10,
                      def: data['def'] as int? ?? 10,
                      maxHp: data['max_hp'] as int? ?? 100,
                      elementalStats: (data['elemental_stats'] ?? "0:0")
                          .toString(),
                      raca: (data['race'] != null
                          ? data['race'].toString()
                          : "Humano"),
                    );
                  } else {
                    // 4. FALLBACK: Se o banco estiver 100% vazio de outros players reais, entra o Bot de treino
                    oponenteReal = ArenaOpponent(
                      id: "bot_${DateTime.now().millisecondsSinceEpoch}",
                      username: "Guerreiro Sombrio (Bot)",
                      level: widget.hero.level,
                      str: 25,
                      def: 15,
                      maxHp: 180,
                      elementalStats: "0:15",
                      raca: "Orc",
                    );
                  }

                  // 5. Convertemos o seu widget.hero atual para o modelo ArenaHeroModel tirando todos os nulos
                  final playerArena = ArenaHeroModel(
                    id: widget.hero.id ?? '',
                    name: widget.hero.name,
                    level: widget.hero.level,
                    totalStr: widget.hero.totalStr,
                    def: widget
                        .hero
                        .totalDef, // Usando o getter totalDef do seu HeroModel
                    maxHp: widget
                        .hero
                        .totalMaxHp, // Usando o getter totalMaxHp do seu HeroModel
                    currentHp: widget.hero.hp,
                    elementalStats:
                        widget.hero.elementalStats ??
                        '', // Garante String não nula
                    raca: widget
                        .hero
                        .nomeTituloLinhagem, // Passa a raça/título formatado
                    gold: widget.hero.gold,
                  );

                  // 6. Vai direto para a Arena de combate com os dois personagens prontos
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArenaBattleScreen(
                        player: playerArena,
                        opponent: oponenteReal,
                      ),
                    ),
                  ).then((_) {
                    // Quando sair da arena e voltar para o mapa, atualiza os dados da UI local
                    if (widget.onUpdate != null) widget.onUpdate!();
                  });
                } catch (e) {
                  // Se der qualquer erro na requisição do Supabase, fecha o loading com segurança
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);

                    // Mostra o erro em um SnackBar simples na parte de baixo
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erro ao conectar na Arena: $e")),
                    );
                  }
                }
              }),
            ],
          ),
        ],
      ),
    );
  }
}
