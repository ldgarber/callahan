import 'team.dart';
import 'player.dart';

class GameSession {
  final String id;
  final Team team;
  final String opponent;
  final DateTime startTime;
  bool isActive;
  int teamScore;
  int opponentScore;
  int currentPoint; // Point being played
  bool isTeamOnOffense;
  int? finalTeamScore; // Final score set when game ends
  int? finalOpponentScore; // Final opponent score set when game ends
  DateTime? endTime; // When the game ended
  List<Player> unknownPlayers; // Track stats for unknown players

  GameSession({
    required this.id,
    required this.team,
    required this.opponent,
    required this.startTime,
    this.isActive = false,
    this.teamScore = 0,
    this.opponentScore = 0,
    this.currentPoint = 1,
    this.isTeamOnOffense = true,
    this.finalTeamScore,
    this.finalOpponentScore,
    this.endTime,
    List<Player>? unknownPlayers,
  }) : unknownPlayers = unknownPlayers ?? [];
}