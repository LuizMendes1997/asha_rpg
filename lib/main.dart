import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/game_state.dart';
import 'screens/character_creation_screen.dart'; // Importe a nova tela
import 'screens/main_shell.dart';
import 'data/item_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const AshaRpgApp());
}

class AshaRpgApp extends StatelessWidget {
  const AshaRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.amber,
      ),
      // MUDANÇA: O jogo agora começa na tela de criação
      home: const CharacterCreationScreen(),
    );
  }
}
