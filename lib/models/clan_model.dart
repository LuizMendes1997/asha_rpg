import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Clan {
  String? id;
  String name;
  int level;
  int exp;
  int nextLevelExp;
  int gold; // Tesouro acumulado pelo clã (doações)
  int maxTowerFloor; // O recorde/progresso do clã na Torre
  String? emblemaPath; // Caminho da imagem/emblema do clã

  Clan({
    this.id,
    required this.name,
    this.level = 1,
    this.exp = 0,
    this.nextLevelExp = 1000,
    this.gold = 0,
    this.maxTowerFloor = 0,
    this.emblemaPath,
  });

  // 🔄 Converte o Clã em um Mapa para salvar na tabela 'clans' do Supabase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
      'exp': exp,
      'next_level_exp': nextLevelExp,
      'gold': gold,
      'max_tower_floor': maxTowerFloor,
      'emblema_path': emblemaPath,
    };
  }

  // 📥 Cria um Clã a partir dos dados retornados do Supabase
  factory Clan.fromMap(Map<String, dynamic> map, {String? clanId}) {
    return Clan(
      id: clanId ?? map['id']?.toString(),
      name: map['name'] ?? 'Clã Sem Nome',
      level: map['level'] ?? 1,
      exp: map['exp'] ?? 0,
      nextLevelExp: map['next_level_exp'] ?? 1000,
      gold: map['gold'] ?? 0,
      maxTowerFloor: map['max_tower_floor'] ?? 0,
      emblemaPath: map['emblema_path'],
    );
  }

  // ⚔️ Sobe o progresso da torre do clã se o novo andar for maior que o recorde atual
  void registrarProgressoTorre(int andarAlcancado) {
    if (andarAlcancado > maxTowerFloor) {
      maxTowerFloor = andarAlcancado;
      debugPrint(
        "🏰 Novo recorde da Torre do Clã [$name]: Andar $maxTowerFloor!",
      );
      saveToSupabase();
    }
  }

  // 💰 Adiciona ouro ao tesouro do clã (pode ser chamado na função doar() do Herói)
  void adicionarFundos(int quantidade) {
    if (quantidade > 0) {
      gold += quantidade;
      // Dá um bônus de XP para o Clã baseado no ouro doado
      ganharExp((quantidade * 0.1).toInt());
      saveToSupabase();
    }
  }

  // 📈 Sistema de Level Up do próprio Clã
  void ganharExp(int quantidade) {
    exp += quantidade;
    while (exp >= nextLevelExp) {
      level++;
      exp -= nextLevelExp;
      nextLevelExp = (nextLevelExp * 1.5)
          .toInt(); // Aumenta a dificuldade do próximo nível
      debugPrint("🎉 O Clã [$name] subiu para o Nível $level!");
    }
    saveToSupabase();
  }

  // 💾 Salva as alterações do Clã diretamente no banco
  Future<void> saveToSupabase() async {
    if (id == null || id!.isEmpty) {
      debugPrint(
        "🚨 ERRO: Não é possível atualizar um clã que não possui um ID válido.",
      );
      return;
    }

    try {
      debugPrint("🔄 Atualizando dados do clã [$name] no Supabase...");

      await Supabase.instance.client
          .from('clans')
          .update(this.toMap())
          .eq('id', id!);

      debugPrint("✅ Clã atualizado com sucesso!");
    } catch (e) {
      debugPrint("❌ Erro ao salvar dados do Clã: $e");
    }
  }
}
