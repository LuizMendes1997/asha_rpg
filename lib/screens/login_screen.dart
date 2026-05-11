import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart'; // Ajuste para seu caminho do HeroModel
import 'character_creation_screen.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('saved_email') ?? '';
      _passwordController.text = prefs.getString('saved_password') ?? '';
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', _emailController.text.trim());
    await prefs.setString('saved_password', _passwordController.text.trim());
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      if (_isRegistering) {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Conta criada! Alterne para Login.")),
          );
          setState(() => _isRegistering = false);
        }
      } else {
        final response = await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response.user != null) {
          await _saveCredentials();

          // VERIFICA SE JÁ EXISTE PERSONAGEM
          final profile = await supabase
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();

          if (mounted) {
            if (profile == null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CharacterCreationScreen(),
                ),
              );
            } else {
              // Carrega o Herói existente do banco
              final hero = HeroModel.fromMap(profile['id'], profile);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainShell(hero: hero)),
              );
            }
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "ASHA RPG",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 40),
                _buildField(_emailController, "E-mail", Icons.email),
                const SizedBox(height: 15),
                _buildField(
                  _passwordController,
                  "Senha",
                  Icons.lock,
                  obscure: true,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.amber)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _handleAuth,
                        child: Text(
                          _isRegistering ? "CRIAR CONTA" : "ENTRAR NO JOGO",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                TextButton(
                  onPressed: () =>
                      setState(() => _isRegistering = !_isRegistering),
                  child: Text(
                    _isRegistering
                        ? "Já tem conta? Login"
                        : "Novo? Criar conta agora",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.amber),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
