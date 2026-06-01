import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClanDetailsScreen extends StatefulWidget {
  final String clanId;

  const ClanDetailsScreen({super.key, required this.clanId});

  @override
  State<ClanDetailsScreen> createState() => _ClanDetailsScreenState();
}

class _ClanDetailsScreenState extends State<ClanDetailsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isProcessingAction = false;

  Future<Map<String, dynamic>> _fetchClanData() async {
    // 1. Busca os dados do clã
    final clanData = await _supabase
        .from('clans')
        .select()
        .eq('id', widget.clanId)
        .single();

    // 2. Busca todos os membros associados a este clã
    final membersData = await _supabase
        .from('profiles')
        .select('id, username, level, race')
        .eq('clan_id', widget.clanId)
        .order(
          'level',
          ascending: false,
        ); // Ordena por nível (do maior para o menor)

    return {'clan': clanData, 'members': membersData as List<dynamic>};
  }

  // --- LÓGICA DE SAIR OU DESFAZER O CLÃ ---
  Future<void> _sairOuDesfazerCla(bool isLeader, List<dynamic> members) async {
    setState(() => _isProcessingAction = true);
    final userId = _supabase.auth.currentUser!.id;

    try {
      if (isLeader) {
        // Se for o líder, desvincula todo mundo antes de deletar o clã
        final List<String> memberIds = members
            .map((m) => m['id'].toString())
            .toList();
        await _supabase
            .from('profiles')
            .update({'clan_id': null})
            .inFilter('id', memberIds);
        await _supabase.from('clans').delete().eq('id', widget.clanId);
      } else {
        // Se for membro normal, apenas remove o clã do seu próprio perfil
        await _supabase
            .from('profiles')
            .update({'clan_id': null})
            .eq('id', userId);
      }

      if (!mounted) return;
      Navigator.pop(
        context,
        true,
      ); // Retorna true para atualizar o OnlineHubScreen

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
          final int bonusAtk = members.length * 2;
          final bool souOLider = currentUserId == leaderId;

          return Column(
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
                      clan['emblema_path'],
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
                            clan['name'].toString().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Bônus Ativo: +$bonusAtk ATK",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botão dinâmico de Sair/Deletar clã
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

              // --- DIVISOR DO MEIO: TÍTULO DA LISTA ---
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
                        letterSpacing: 1,
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

              // --- LISTA CENTRALIZADA DE JOGADORES ---
              Expanded(
                child: ListView.builder(
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        // Mostra o Nível destacado à esquerda
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
                        // Nome do jogador no meio
                        title: Text(
                          member['username'] ?? 'Guerreiro',
                          style: TextStyle(
                            color: isLeader ? Colors.amber : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // Raça do jogador logo abaixo do nome
                        subtitle: Text(
                          "Classe/Raça: ${member['race'] ?? 'Humano'}",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                        // Tag visual indicando quem manda no pedaço
                        trailing: isLeader
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.amber),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "LÍDER",
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
