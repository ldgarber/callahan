import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/game_session.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  User? currentUser;
  List<Team> teams = [];
  GameSession? currentGame;
  List<GameSession> completedGames = [];

  Future<bool> login(String phoneNumber, String password) async {
    // Simulate login with phone number
    if (phoneNumber.isNotEmpty && password.isNotEmpty) {
      // Extract name from phone number (for demo purposes)
      final name = 'User${phoneNumber.substring(phoneNumber.length - 4)}';
      
      currentUser = User(
        id: '1',
        name: name,
        email: '$phoneNumber@phone.local', // Create a pseudo-email for compatibility
      );
      
      // Save login state
      await _saveLoginState(phoneNumber, password);
      return true;
    }
    return false;
  }

  Future<void> _saveLoginState(String phoneNumber, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_in_phone', phoneNumber);
    await prefs.setString('logged_in_password', password);
    await prefs.setBool('is_logged_in', true);
  }

  Future<bool> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    if (isLoggedIn) {
      final phoneNumber = prefs.getString('logged_in_phone');
      final password = prefs.getString('logged_in_password');
      
      if (phoneNumber != null && password != null) {
        return await login(phoneNumber, password);
      }
    }
    return false;
  }

  Future<void> logout() async {
    currentUser = null;
    currentGame = null;
    
    // Clear stored login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_phone');
    await prefs.remove('logged_in_password');
    await prefs.setBool('is_logged_in', false);
  }

  void addTeam(Team team) {
    teams.add(team);
  }

  void addPlayerToTeam(String teamId, Player player) {
    final team = teams.firstWhere((t) => t.id == teamId);
    team.players.add(player);
  }

  void removePlayerFromTeam(String teamId, String playerId) {
    final team = teams.firstWhere((t) => t.id == teamId);
    team.players.removeWhere((player) => player.id == playerId);
  }

  void startGame(String teamId, String opponent) {
    final team = teams.firstWhere((t) => t.id == teamId);
    currentGame = GameSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      team: team,
      opponent: opponent,
      startTime: DateTime.now(),
      isActive: true,
    );
    
    // Reset all player stats
    for (var player in team.players) {
      player.resetStats();
    }
  }

  void endGame({int? finalTeamScore, int? finalOpponentScore}) {
    if (currentGame != null) {
      currentGame!.isActive = false;
      currentGame!.finalTeamScore = finalTeamScore ?? currentGame!.teamScore;
      currentGame!.finalOpponentScore = finalOpponentScore ?? currentGame!.opponentScore;
      currentGame!.endTime = DateTime.now();
      
      // Add to completed games
      completedGames.add(currentGame!);
      currentGame = null;
    }
  }

  List<GameSession> getCompletedGamesForTeam(String teamId) {
    return completedGames.where((game) => game.team.id == teamId).toList()
      ..sort((a, b) => (b.endTime ?? b.startTime).compareTo(a.endTime ?? a.startTime));
  }
}