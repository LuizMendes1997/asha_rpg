class Quest {
  final String title;
  final String description;
  final String targetMonsterName;
  final int requiredKillCount;
  int currentKillCount;
  final int rewardGold;
  final int rewardExp;
  bool isCompleted;
  bool isTaken;

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

  // ADICIONE ISSO AQUI:
  Quest copy() {
    return Quest(
      title: title,
      description: description,
      targetMonsterName: targetMonsterName,
      requiredKillCount: requiredKillCount,
      rewardGold: rewardGold,
      rewardExp: rewardExp,
      currentKillCount: 0, // Começa do zero
      isCompleted: false, // Nova cópia não está pronta
      isTaken: true, // Já foi aceita
    );
  }
}
