class Clan {
  final String id;
  final String name;
  final String emblemaPath;
  final String leaderId;
  final String? viceLeaderId;
  final int membrosCount;

  Clan({
    required this.id,
    required this.name,
    required this.emblemaPath,
    required this.leaderId,
    this.viceLeaderId,
    required this.membrosCount,
  });

  // Cálculo de bônus de ATK (2 de ATK por membro)
  int get bonusAtk => membrosCount * 2;

  factory Clan.fromMap(Map<String, dynamic> map) {
    return Clan(
      id: map['id'],
      name: map['name'],
      emblemaPath: map['emblema_path'],
      leaderId: map['leader_id'],
      viceLeaderId: map['vice_leader_id'],
      membrosCount: map['membros_count'] ?? 1,
    );
  }
}
