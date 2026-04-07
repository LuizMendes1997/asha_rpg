import 'package:flutter/material.dart';
import 'dart:async'; // Necessário para o Timer
import '../models/game_state.dart';

class FinanceScreen extends StatefulWidget {
  final HeroModel hero;
  final VoidCallback onUpdate;
  const FinanceScreen({super.key, required this.hero, required this.onUpdate});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  // Configuração do Timer de Arrecadação
  Timer? _timer;
  int _segundosRestantes = 30; // Ciclo de 30 segundos
  final int _duracaoCiclo = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Limpa o timer ao sair da tela
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_segundosRestantes > 0) {
            _segundosRestantes--;
          } else {
            // FIM DO CICLO: Gera o ouro no HeroModel
            widget.hero.processarFinancas();
            widget.onUpdate(); // Atualiza o resto do app
            _segundosRestantes = _duracaoCiclo; // Reinicia
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPessoas =
        widget.hero.populacaoCidadaos + widget.hero.populacaoMendigos;

    // Calcula a previsão baseada no multiplicador do seu HeroModel
    int previsaoRenda = (totalPessoas * widget.hero.producaoPorHabitante)
        .toInt();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("FINANÇAS DA VILA"),
        backgroundColor: Colors.green[900],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD DE OURO ACUMULADO
            _infoCard(
              "Ouro para Coletar",
              "${widget.hero.ouroAcumuladoVila} g",
              Icons.monetization_on,
              Colors.amber,
            ),
            const SizedBox(height: 10),

            // CARD DE PREVISÃO DE RENDA
            _infoCard(
              "Renda por Ciclo",
              "+$previsaoRenda g",
              Icons.trending_up,
              Colors.green,
            ),

            const SizedBox(height: 20),

            // TIMER VISUAL
            Center(
              child: Column(
                children: [
                  Text(
                    "Próximo imposto em: ${_segundosRestantes}s",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _segundosRestantes / _duracaoCiclo,
                      backgroundColor: Colors.grey[900],
                      color: Colors.greenAccent,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "ESTATÍSTICAS DA POPULAÇÃO",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Divider(color: Colors.white24),

            _statusRow("Cidadãos ativos:", "${widget.hero.populacaoCidadaos}"),
            _statusRow("Moradores de rua:", "${widget.hero.populacaoMendigos}"),
            _statusRow("Total de habitantes:", "$totalPessoas"),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "DICA: O ouro é gerado automaticamente a cada ciclo de 30 segundos enquanto você administra a vila.",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const Spacer(),

            // BOTÃO DE COLETAR IMPOSTOS
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                disabledBackgroundColor: Colors.grey[800],
                minimumSize: const Size(double.infinity, 65),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.hero.ouroAcumuladoVila > 0
                  ? () {
                      setState(() {
                        widget.hero.gold += widget.hero.ouroAcumuladoVila;
                        widget.hero.ouroAcumuladoVila = 0;
                      });
                      widget.onUpdate();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ouro transferido para o seu tesouro!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  : null,
              child: Text(
                widget.hero.ouroAcumuladoVila > 0
                    ? "COLETAR IMPOSTOS"
                    : "AGUARDANDO ARRECADAÇÃO",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon, Color color) {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
