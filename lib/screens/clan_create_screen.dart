import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClanCreateScreen extends StatefulWidget {
  const ClanCreateScreen({super.key});

  @override
  State<ClanCreateScreen> createState() => _ClanCreateScreenState();
}

class _ClanCreateScreenState extends State<ClanCreateScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingClans = true;
  List<Map<String, dynamic>> _clasDisponiveis = [];

  final List<String> emblemas = [
    'assets/e1.png',
    'assets/e2.png',
    'assets/e3.png',
  ];
  String selectedEmblema = 'assets/e1.png';

  @override
  void initState() {
    super.initState();
    _carregarClas();
  }

  // --- BUSCA OS CLÃS E CONTA OS MEMBROS ---
  Future<void> _carregarClas() async {
    final supabase = Supabase.instance.client;
    try {
      // O uso de 'profiles!clan_id(id)' força o JOIN via chave estrangeira
      final response = await supabase
          .from('clans')
          .select('id, name, emblema_path, profiles!clan_id(id)');

      if (mounted) {
        setState(() {
          _clasDisponiveis = List<Map<String, dynamic>>.from(response);
          _isLoadingClans = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar clãs: $e");
      if (mounted) {
        setState(() => _isLoadingClans = false);
      }
    }
  }

  // --- LÓGICA DE ENTRAR NO CLÃ ---
  Future<void> _entrarNoCla(String clanId, int numeroDeMembros) async {
    if (numeroDeMembros >= 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Este clã já está lotado!")));
      return;
    }

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    try {
      await supabase
          .from('profiles')
          .update({'clan_id': clanId})
          .eq('id', userId);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao entrar: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LÓGICA DE CRIAR CLÃ ---
  Future<void> _criarCla() async {
    final nomeCla = _nameController.text.trim();
    if (nomeCla.isEmpty) return;

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    try {
      // 1. Removemos o .single() e pegamos a resposta como uma lista
      final response = await supabase
          .from('clans')
          .insert({
            'name': nomeCla,
            'emblema_path': selectedEmblema,
            'leader_id': userId,
          })
          .select('id');

      // 2. Acessamos o primeiro item da lista: response.first
      // Isso garante que você pegue o ID corretamente
      final clanId = response.first['id'];

      // 3. Agora usamos o clanId extraído
      await supabase
          .from('profiles')
          .update({'clan_id': clanId})
          .eq('id', userId);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao fundar clã: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("SISTEMA DE CLÃS"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Campo de Nome e Grid de Emblemas...
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Nome do Clã",
                filled: true,
                fillColor: Color(0xFF262626),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _criarCla,
              child: const Text("FUNDAR CLÃ"),
            ),
            const Divider(color: Colors.white24),

            Expanded(
              child: _isLoadingClans
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                  : _clasDisponiveis.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhum clã fundado.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : RefreshIndicator(
                      color: Colors.amber,
                      onRefresh: _carregarClas,
                      child: ListView.builder(
                        itemCount: _clasDisponiveis.length,
                        itemBuilder: (context, index) {
                          final clan = _clasDisponiveis[index];
                          // Garante que o ID seja tratado como String
                          final String clanId = clan['id'].toString();
                          final List<dynamic> profiles = clan['profiles'] ?? [];
                          final int memberCount = profiles.length;
                          final bool isFull = memberCount >= 10;

                          return Card(
                            color: const Color(0xFF1A1A1A),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(
                                clan['name'].toString().toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Membros: $memberCount/10",
                                style: TextStyle(
                                  color: isFull
                                      ? Colors.redAccent
                                      : Colors.greenAccent,
                                ),
                              ),
                              trailing: ElevatedButton(
                                onPressed: isFull
                                    ? null
                                    : () => _entrarNoCla(clanId, memberCount),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFull
                                      ? Colors.grey
                                      : Colors.amber,
                                ),
                                child: Text(
                                  isFull ? "LOTADO" : "ENTRAR",
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
