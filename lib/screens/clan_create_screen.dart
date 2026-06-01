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
      // Fazemos um select que já traz os perfis atrelados a cada clã para contar os membros
      final response = await supabase
          .from('clans')
          .select('id, name, emblema_path, profiles(id)');

      if (mounted) {
        setState(() {
          _clasDisponiveis = List<Map<String, dynamic>>.from(response);
          _isLoadingClans = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar clãs: $e");
      if (mounted) setState(() => _isLoadingClans = false);
    }
  }

  // --- LÓGICA DE ENTRAR NO CLÃ ---
  Future<void> _entrarNoCla(String clanId, int numeroDeMembros) async {
    if (numeroDeMembros >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Este clã já atingiu o limite de 10 membros!",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      );
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
      Navigator.pop(context, true); // Retorna true para o OnlineHub atualizar

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Você entrou no clã com sucesso!",
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erro ao entrar no clã: $e",
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  // --- LÓGICA DE CRIAR CLÃ ---
  Future<void> _criarCla() async {
    final nomeCla = _nameController.text.trim();

    if (nomeCla.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Dê um nome ao seu clã!")));
      return;
    }

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    try {
      final clan = await supabase
          .from('clans')
          .insert({
            'name': nomeCla,
            'emblema_path': selectedEmblema,
            'leader_id': userId,
          })
          .select('id')
          .single();

      await supabase
          .from('profiles')
          .update({'clan_id': clan['id']})
          .eq('id', userId);

      if (!mounted) return;
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Clã fundado com sucesso!",
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erro ao fundar clã: $e",
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      // Usei GestureDetector para fechar o teclado ao clicar fora
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // SEÇÃO 1: FUNDAR CLÃ
              // ==========================================
              const Text(
                "FUNDAR UM NOVO CLÃ",
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Nome do Clã",
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Color(0xFF262626),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Escolha seu emblema:",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 10),
              // GridView reduzido para ocupar apenas o espaço necessário
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      5, // Aumentei para 5 para ficarem menores e ocupar menos espaço na tela
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: emblemas.length,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => setState(() => selectedEmblema = emblemas[i]),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedEmblema == emblemas[i]
                            ? Colors.amber
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Image.asset(emblemas[i], fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _criarCla,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "FUNDAR CLÃ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 10),

              // ==========================================
              // SEÇÃO 2: LISTA DE CLÃS (RECRUTAMENTO)
              // ==========================================
              const Text(
                "CLÃS DISPONÍVEIS",
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoadingClans
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      )
                    : _clasDisponiveis.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhum clã fundado ainda.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _clasDisponiveis.length,
                        itemBuilder: (context, index) {
                          final clan = _clasDisponiveis[index];
                          // Calcula quantos membros estão no clã lendo o tamanho da lista 'profiles' que o join trouxe
                          final List<dynamic> profiles = clan['profiles'] ?? [];
                          final int memberCount = profiles.length;
                          final bool isFull = memberCount >= 10;

                          return Card(
                            color: const Color(0xFF1A1A1A),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              leading: Image.asset(
                                clan['emblema_path'],
                                width: 40,
                                height: 40,
                              ),
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
                                onPressed: (_isLoading || isFull)
                                    ? null
                                    : () =>
                                          _entrarNoCla(clan['id'], memberCount),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFull
                                      ? Colors.grey
                                      : Colors.green,
                                  minimumSize: const Size(80, 35),
                                ),
                                child: Text(
                                  isFull ? "LOTADO" : "ENTRAR",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
