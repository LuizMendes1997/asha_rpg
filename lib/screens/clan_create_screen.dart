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

  final List<String> emblemas = [
    'assets/e1.png',
    'assets/e2.png',
    'assets/e3.png',
  ];
  String selectedEmblema = 'assets/e1.png';

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
      // 1. Cria o registro do clã na tabela 'clans'
      final clan = await supabase
          .from('clans')
          .insert({
            'name': nomeCla,
            'emblema_path': selectedEmblema,
            'leader_id': userId,
            // 'membros_count': 1 // Descomente apenas se você criou essa coluna na tabela clans
          })
          .select('id') // Pede para o banco devolver apenas o ID criado
          .single();

      // 2. Atualiza o perfil do usuário com o ID do novo clã
      await supabase
          .from('profiles')
          .update({'clan_id': clan['id']})
          .eq('id', userId);

      if (!mounted) return;
      Navigator.pop(
        context,
        true,
      ); // Retorna 'true' para a tela anterior saber que deu certo

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
        title: const Text("FUNDAR CLÃ"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
            const SizedBox(height: 20),
            const Text(
              "Escolha seu emblema:",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: emblemas.length,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => setState(() => selectedEmblema = emblemas[i]),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedEmblema == emblemas[i]
                            ? Colors.amber
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Image.asset(emblemas[i], fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _criarCla,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "FUNDAR CLÃ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
