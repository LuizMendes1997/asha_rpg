import 'dart:async'; // OBRIGATÓRIO PARA USAR O TIMER
import 'package:asha_rpg/models/game_state.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;
  const ChatScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _chatStream;

  // --- VARIÁVEIS DA TRAVA (COOLDOWN) ---
  bool _isCooldown = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _chatStream = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .limit(50);
  }

  // IMPORTANTE: Limpar o timer da memória se o jogador sair da tela
  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  // --- FUNÇÃO QUE ATIVA A CONTAGEM REGRESSIVA ---
  void _startCooldown() {
    setState(() {
      _isCooldown = true;
      _cooldownSeconds = 20; // Tempo em segundos
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_cooldownSeconds > 1) {
          _cooldownSeconds--;
        } else {
          // Terminou o tempo, libera o chat
          _isCooldown = false;
          _cooldownSeconds = 0;
          _cooldownTimer?.cancel();
        }
      });
    });
  }

  Future<void> _sendMessage() async {
    // Se estiver na trava, bloqueia o envio (segurança extra)
    if (_isCooldown) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      // 1. Ativa a trava local imediatamente ao clicar (evita cliques duplos rápidos)
      _startCooldown();

      // 2. Envia para o banco
      await _supabase.from('messages').insert({
        'sender_name': widget.hero.name,
        'content': text,
      });
    } catch (e) {
      // Se der erro no envio, cancela a trava para ele tentar de novo
      _cooldownTimer?.cancel();
      setState(() {
        _isCooldown = false;
        _cooldownSeconds = 0;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao enviar mensagem: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Global da Vila")),
      body: Column(
        children: [
          // Área das mensagens (igual ao anterior)
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Nenhuma mensagem por enquanto..."),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_name'] == widget.hero.name;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blueGrey[700]
                              : Colors.blueGrey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['sender_name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isMe
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['content'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Campo de texto e Botão modificados com a trava
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    // Desativa o campo enquanto estiver na trava (opcional, mas visualmente bom)
                    enabled: !_isCooldown,
                    decoration: InputDecoration(
                      // Muda o texto caso esteja bloqueado
                      hintText: _isCooldown
                          ? "Aguarde $_cooldownSeconds s para falar..."
                          : "Digite sua mensagem...",
                      border: const OutlineInputBorder(),
                      fillColor: _isCooldown ? Colors.black26 : null,
                      filled: _isCooldown,
                    ),
                  ),
                ),
                IconButton(
                  // Se passar 'null' no onPressed, o Flutter desativa e deixa o botão cinza automaticamente
                  icon: Icon(
                    Icons.send,
                    color: _isCooldown ? Colors.grey : Colors.blue,
                  ),
                  onPressed: _isCooldown ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
