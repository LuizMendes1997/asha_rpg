class Quest {
  final String title;
  final String description;
  final String targetMonsterName; // Qual bicho precisa matar
  final int requiredKillCount; // Quantos precisa matar
  int currentKillCount; // Quantos já matou
  final int rewardGold;
  final int rewardExp;
  bool isCompleted;
  bool isTaken; // Se o jogador já aceitou a missão

  Quest({
    required this.title,
    required this.description,
    required this.targetMonsterName,
    required this.requiredKillCount,
    required this.rewardGold,
    required this.rewardExp,
    this.currentKillCount = 0,
    this.isCompleted = false,
    this.isTaken = false,
  });
}
