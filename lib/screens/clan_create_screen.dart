import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClanCreateScreen extends StatefulWidget {
  @override
  _ClanCreateScreenState createState() => _ClanCreateScreenState();
}

class _ClanCreateScreenState extends State<ClanCreateScreen> {
  final _nameController = TextEditingController();
  final List<String> emblemas = [
    'assets/e1.png',
    'assets/e2.png',
    'assets/e3.png',
  ];
  String selectedEmblema = 'assets/e1.png';

  Future<void> _criarCla() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    try {
      // Cria o clã
      final clan = await supabase
          .from('clans')
          .insert({
            'name': _nameController.text,
            'emblema_path': selectedEmblema,
            'leader_id': userId,
          })
          .select()
          .single();

      // Vincula o usuário ao clã
      await supabase
          .from('profiles')
          .update({'clan_id': clan['id']})
          .eq('id', userId);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao criar clã: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("CRIAR CLÃ")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Nome do Clã",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: emblemas.length,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => setState(() => selectedEmblema = emblemas[i]),
                  child: Image.asset(emblemas[i]),
                ),
              ),
            ),
            ElevatedButton(onPressed: _criarCla, child: Text("FUNDAR CLÃ")),
          ],
        ),
      ),
    );
  }
}
