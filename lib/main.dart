import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Adicione este import
import 'screens/login_screen.dart';

// DICA: Em um projeto real, coloque essas chaves em um arquivo .env ou similar
const String supabaseUrl = 'https://qyqkieuhkckmigpliecp.supabase.co';
const String supabaseKey = 'sb_publishable_Ey0UOQ2Lvr6AnzZmc-qKrg_TMiP6pfp';

void main() async {
  // WidgetsFlutterBinding deve vir primeiro
  WidgetsFlutterBinding.ensureInitialized();

  // 1. INICIALIZA O SUPABASE
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  // Esconde as barras do sistema (modo imersivo)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const AshaRpgApp());
}

class AshaRpgApp extends StatelessWidget {
  const AshaRpgApp({super.key});

  // Getter utilitário para acessar o cliente do Supabase em qualquer lugar do app
  static SupabaseClient get supabase => Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.amber,
      ),
      // MUDANÇA FUTURA: Aqui verificaremos se o usuário já está logado
      // Se sim -> WorldMap, Se não -> LoginScreen
      home: const LoginScreen(),
    );
  }
}
