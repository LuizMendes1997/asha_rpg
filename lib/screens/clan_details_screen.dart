import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asha_rpg/models/game_state.dart'; // Ajuste para o seu path real do HeroModel
import 'clan_tower_screen.dart'; // Tela que criaremos no Passo 3
import 'package:collection/collection.dart';

class ClanDetailsScreen extends StatefulWidget {
  final String clanId;
  final HeroModel hero;
  final VoidCallback onUpdate;

  const ClanDetailsScreen({
    super.key,
    required this.clanId,
    required this.hero,
    required this.onUpdate,
  });

  @override
  State<ClanDetailsScreen> createState() => _ClanDetailsScreenState();
}

class _ClanDetailsScreenState extends State<ClanDetailsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isProcessingAction = false;
  bool _isUpgrading = false;

  Future<Map<String, dynamic>> _fetchClanData() async {
    final clanData = await _supabase
        .from('clans')
        .select()
        .eq('id', widget.clanId)
        .single();

    final membersData = await _supabase
        .from('profiles')
        .select('id, username, level, race, last_clan_tower_attack')
        .eq('clan_id', widget.clanId)
        .order('level', ascending: false);

    return {'clan': clanData, 'members': membersData as List<dynamic>};
  }

  Future<void> _sairOuDesfazerCla(bool isLeader, List<dynamic> members) async {
    setState(() => _isProcessingAction = true);
    final userId = _supabase.auth.currentUser!.id;

    try {
      if (isLeader) {
        final List<String> memberIds = members
            .map((m) => m['id'].toString())
            .toList();
        await _supabase
            .from('profiles')
            .update({'clan_id': null})
            .inFilter('id', memberIds);
        await _supabase.from('clans').delete().eq('id', widget.clanId);
      } else {
        await _supabase
            .from('profiles')
            .update({'clan_id': null})
            .eq('id', userId);
      }

      if (!mounted) return;
      widget.onUpdate();
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLeader ? "Clã desfeito com sucesso." : "Você saiu do clã.",
          ),
          backgroundColor: Colors.amber,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro na operação: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  Future<void> _doarEUpgrade(Map<String, dynamic> clan, int custoGold) async {
    if (widget.hero.gold < custoGold) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Você não tem Ouro suficiente para upar o clã!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isUpgrading = true);

    try {
      widget.hero.gold -= custoGold;
      await widget.hero.saveToSupabase();

      await _supabase
          .from('clans')
          .update({'level': (clan['level'] ?? 1) + 1})
          .eq('id', widget.clanId);

      setState(() {});
      widget.onUpdate();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao subir nível: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isUpgrading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "MURAL DO CLÃ",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchClanData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erro ao carregar o clã: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final data = snapshot.data!;
          final clan = data['clan'];
          final List<dynamic> members = data['members'];
          final String leaderId = clan['leader_id'];
          final int clanLevel = clan['level'] ?? 1;
          final int bonusAtk =
              members.length * 2 +
              (clanLevel * 3); // Nível do clã agora escala o bônus!
          final bool souOLider = currentUserId == leaderId;

          // --- VALIDAÇÃO DA TRAVA DIÁRIA (CORRIGIDO) ---
          final meuPerfil = members.firstWhereOrNull(
            (m) => m['id'] == currentUserId,
          ); // O firstWhereOrNull já aceita retornar null nativamente se não achar!

          final String hoje = DateTime.now().toIso8601String().split('T').first;
          final bool jaAtacouHoje =
              meuPerfil != null && meuPerfil['last_clan_tower_attack'] == hoje;

          // Lógica matemática do Boss
          int andarAtual = clan['tower_floor'] ?? 1;
          int hpMaxDoBoss = (200 * (andarAtual * 1.5)).toInt();
          int hpAtualDoBoss =
              (clan['boss_current_hp'] == null || clan['boss_current_hp'] == -1)
              ? hpMaxDoBoss
              : clan['boss_current_hp'];

          // Custos de Upgrade do clã
          int custoOuroUpgrade = clanLevel * 5000;

          return SingleChildScrollView(
            child: Column(
              children: [
                // --- CABEÇALHO DO CLÃ ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF141414),
                    border: Border(
                      bottom: BorderSide(color: Colors.amber, width: 2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        clan['emblema_path'] ?? 'assets/emblems/default.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${clan['name'].toString().toUpperCase()} [LVL $clanLevel]",
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Bônus Ativo: +$bonusAtk ATK",
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: _isProcessingAction
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.redAccent,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                souOLider ? Icons.delete_forever : Icons.logout,
                                color: Colors.redAccent,
                              ),
                        tooltip: souOLider ? "Desfazer Clã" : "Sair do Clã",
                        onPressed: _isProcessingAction
                            ? null
                            : () => _sairOuDesfazerCla(souOLider, members),
                      ),
                    ],
                  ),
                ),

                // --- ROSTER DE MEMBROS ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "ROSTER DE MEMBROS",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${members.length} / 10",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isLeader = member['id'] == leaderId;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLeader
                              ? Colors.amber.withOpacity(0.6)
                              : Colors.white10,
                          width: isLeader ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isLeader ? Colors.amber : Colors.grey[800],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Lvl ${member['level'] ?? 1}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        title: Text(
                          member['username'] ?? 'Guerreiro',
                          style: TextStyle(
                            color: isLeader ? Colors.amber : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "Classe/Raça: ${member['race'] ?? 'Humano'}",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                        trailing: isLeader
                            ? const Text(
                                "LÍDER",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.white24, height: 30),
                ),

                // --- NOVO PAINEL DA TORRE COMPARTILHADA ---
                Container(
                  margin: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 30,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(20, 20, 20, 1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "🏰 TORRE DO CLÃ",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                "Andar Atual: $andarAtual",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          if (souOLider)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[800],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                              ),
                              onPressed: _isUpgrading
                                  ? null
                                  : () => _doarEUpgrade(clan, custoOuroUpgrade),
                              icon: const Icon(
                                Icons.arrow_upward,
                                size: 16,
                                color: Colors.black,
                              ),
                              label: Text(
                                "UP CLÃ ($custoOuroUpgrade G)",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Barra de Vida Persistente do Boss
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "👹 BOSS DO ANDAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$hpAtualDoBoss / $hpMaxDoBoss HP",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (hpAtualDoBoss / hpMaxDoBoss).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[900],
                          color: Colors.red,
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Botão de Entrada da Raid
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: jaAtacouHoje
                                ? Colors.grey[800]
                                : Colors.red[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: jaAtacouHoje
                              ? null
                              : () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClanTowerScreen(
                                        clanId: widget.clanId,
                                        hero: widget.hero,
                                        currentFloor: andarAtual,
                                        maxBossHP: hpMaxDoBoss,
                                        currentBossHP: hpAtualDoBoss,
                                        onUpdate: widget.onUpdate,
                                      ),
                                    ),
                                  );
                                  if (result == true) setState(() {});
                                },
                          child: Text(
                            jaAtacouHoje
                                ? "DESAFIO DIÁRIO CONCLUÍDO"
                                : "DESAFIAR TORRE EM GRUPO",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Score Total de Dano do Clã: ${clan['total_damage_score'] ?? 0}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
