class Player {
  final String id;
  final String name;
  final String position;
  final int jerseyNumber;
  int goals;
  int assists;
  int blocks;
  int catches;
  int drops;
  int pulls;

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.jerseyNumber,
    this.goals = 0,
    this.assists = 0,
    this.blocks = 0,
    this.catches = 0,
    this.drops = 0,
    this.pulls = 0,
  });

  void resetStats() {
    goals = 0;
    assists = 0;
    blocks = 0;
    catches = 0;
    drops = 0;
    pulls = 0;
  }
}