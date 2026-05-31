class Clan {
  final String id;
  final String name;
  final String emblemaPath;
  final String leaderId;
  final String? viceLeaderId;
  final int membrosCount;
  final String?
  leaderName; // NOVO: Para exibir o nome do líder na UI facilmente

  Clan({
    required this.id,
    required this.name,
    required this.emblemaPath,
    required this.leaderId,
    this.viceLeaderId,
    required this.membrosCount,
    this.leaderName,
  });

  // Cálculo de bônus de ATK (2 de ATK por membro)
  int get bonusAtk => membrosCount * 2;

  factory Clan.fromMap(Map<String, dynamic> map) {
    // Quando fazemos um Join no Supabase, os dados da outra tabela vêm como um Map aninhado.
    // Ex: map['profiles'] vai conter os dados do líder se fizermos a query correta.
    final profileData = map['profiles'];

    return Clan(
      id: map['id'],
      name: map['name'],
      emblemaPath: map['emblema_path'],
      leaderId: map['leader_id'],
      viceLeaderId: map['vice_leader_id'],
      membrosCount:
          map['membros_count'] ??
          1, // Se não tiver a coluna, assume 1 (o líder)
      leaderName: profileData != null
          ? profileData['username']
          : 'Desconhecido',
    );
  }
}
