import 'dart:math';
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
  
  // SMS verification storage
  Map<String, String> _pendingVerifications = {};
  
  // Store user names by phone number
  Map<String, String> _userNames = {};

  Future<String> sendVerificationCode(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number is required');
    }
    
    // Generate a random 6-digit code
    final random = Random();
    final code = (100000 + random.nextInt(900000)).toString();
    
    // Store the code for verification
    _pendingVerifications[phoneNumber] = code;
    
    // Simulate SMS sending delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // In a real app, you would send the SMS here
    // For demo purposes, we'll return the code so it can be displayed
    print('SMS Code for $phoneNumber: $code'); // This would be sent via SMS
    
    return code; // In production, this would not be returned
  }

  Future<bool> isFirstTimeUser(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final userPhones = prefs.getStringList('user_phones') ?? [];
    return !userPhones.contains(phoneNumber);
  }

  Future<bool> verifyCode(String phoneNumber, String code, {String? userName}) async {
    final storedCode = _pendingVerifications[phoneNumber];
    
    if (storedCode != null && storedCode == code) {
      // Code is correct, determine the user's name
      String name;
      if (userName != null && userName.isNotEmpty) {
        // New user with provided name
        name = userName;
        await _saveUserName(phoneNumber, name);
      } else {
        // Returning user or fallback
        name = await _getUserName(phoneNumber);
      }
      
      currentUser = User(
        id: '1',
        name: name,
        email: '$phoneNumber@phone.local',
      );
      
      // Save login state
      await _saveLoginState(phoneNumber);
      
      // Clear the verification code
      _pendingVerifications.remove(phoneNumber);
      
      return true;
    }
    
    return false;
  }

  Future<void> _saveUserName(String phoneNumber, String name) async {
    final prefs = await SharedPreferences.getInstance();
    _userNames[phoneNumber] = name;
    
    // Save to persistent storage
    final userNames = prefs.getStringList('user_names') ?? [];
    final userPhones = prefs.getStringList('user_phones') ?? [];
    
    if (!userPhones.contains(phoneNumber)) {
      userNames.add(name);
      userPhones.add(phoneNumber);
      await prefs.setStringList('user_names', userNames);
      await prefs.setStringList('user_phones', userPhones);
    }
  }

  Future<String> _getUserName(String phoneNumber) async {
    // Check in-memory first
    if (_userNames.containsKey(phoneNumber)) {
      return _userNames[phoneNumber]!;
    }
    
    // Check persistent storage
    final prefs = await SharedPreferences.getInstance();
    final userNames = prefs.getStringList('user_names') ?? [];
    final userPhones = prefs.getStringList('user_phones') ?? [];
    
    final index = userPhones.indexOf(phoneNumber);
    if (index != -1 && index < userNames.length) {
      final name = userNames[index];
      _userNames[phoneNumber] = name; // Cache it
      return name;
    }
    
    // Fallback for unknown users
    return 'User${phoneNumber.substring(phoneNumber.length - 4)}';
  }

  Future<void> _saveLoginState(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_in_phone', phoneNumber);
    await prefs.setBool('is_logged_in', true);
  }

  Future<bool> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    if (isLoggedIn) {
      final phoneNumber = prefs.getString('logged_in_phone');
      
      if (phoneNumber != null) {
        // Auto-login without verification for returning users
        final name = await _getUserName(phoneNumber);
        
        currentUser = User(
          id: '1',
          name: name,
          email: '$phoneNumber@phone.local',
        );
        
        return true;
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
    await prefs.setBool('is_logged_in', false);
    
    // Clear any pending verifications
    _pendingVerifications.clear();
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