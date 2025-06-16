import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/player.dart';
import '../widgets/end_game_dialog.dart';
import '../widgets/player_selection_dialog.dart';

class LiveGameScreen extends StatefulWidget {
  @override
  _LiveGameScreenState createState() => _LiveGameScreenState();
}

class _LiveGameScreenState extends State<LiveGameScreen> {
  final _dataService = DataService();

  void _updatePlayerStat(Player player, String stat, int change) {
    setState(() {
      // If this is an unknown player, add them to the unknown players list
      if (player.id.startsWith('unknown_')) {
        final existingUnknown = _dataService.currentGame!.unknownPlayers
            .where((p) => p.id == player.id)
            .firstOrNull;
        
        if (existingUnknown == null) {
          _dataService.currentGame!.unknownPlayers.add(player);
        }
      }
      
      switch (stat) {
        case 'goals':
          player.goals = (player.goals + change).clamp(0, 999);
          if (change > 0) {
            // Goal scored, update game score
            _dataService.currentGame!.teamScore++;
            _dataService.currentGame!.currentPoint++;
            _dataService.currentGame!.isTeamOnOffense = false; // Opponent pulls
          }
          break;
        case 'assists':
          player.assists = (player.assists + change).clamp(0, 999);
          break;
        case 'blocks':
          player.blocks = (player.blocks + change).clamp(0, 999);
          break;
        case 'catches':
          player.catches = (player.catches + change).clamp(0, 999);
          break;
        case 'drops':
          player.drops = (player.drops + change).clamp(0, 999);
          break;
        case 'pulls':
          player.pulls = (player.pulls + change).clamp(0, 999);
          break;
      }
    });
  }

  void _scoreForOpponent() {
    setState(() {
      _dataService.currentGame!.opponentScore++;
      _dataService.currentGame!.currentPoint++;
      _dataService.currentGame!.isTeamOnOffense = true; // Team pulls next
    });
  }

  void _toggleOffense() {
    setState(() {
      _dataService.currentGame!.isTeamOnOffense = !_dataService.currentGame!.isTeamOnOffense;
    });
  }

  void _recordStat(String statType) {
    showDialog(
      context: context,
      builder: (context) => PlayerSelectionDialog(
        players: _dataService.currentGame!.team.players,
        statType: statType,
        onPlayerSelected: (player) {
          _updatePlayerStat(player, statType, 1);
        },
      ),
    );
  }

  void _endGame() {
    showDialog(
      context: context,
      builder: (context) => EndGameDialog(
        currentTeamScore: _dataService.currentGame!.teamScore,
        currentOpponentScore: _dataService.currentGame!.opponentScore,
        teamName: _dataService.currentGame!.team.name,
        opponentName: _dataService.currentGame!.opponent,
        onGameEnded: (finalTeamScore, finalOpponentScore) {
          _dataService.endGame(
            finalTeamScore: finalTeamScore,
            finalOpponentScore: finalOpponentScore,
          );
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = _dataService.currentGame!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${game.team.name} vs ${game.opponent}'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _endGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text(
                'End Game',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Game Status Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(
                bottom: BorderSide(color: Color(0xFF334155), width: 1),
              ),
            ),
            child: Column(
              children: [
                Text('${game.team.name} ${game.teamScore} - ${game.opponentScore} ${game.opponent}', 
                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0))),
                SizedBox(height: 4),
                Text('Point ${game.currentPoint}', style: TextStyle(color: Color(0xFF94A3B8))),
                Text(game.isTeamOnOffense ? '${game.team.name} on Offense' : '${game.team.name} on Defense',
                     style: TextStyle(fontWeight: FontWeight.bold, color: game.isTeamOnOffense ? Color(0xFF3B82F6) : Color(0xFFEF4444))),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _scoreForOpponent,
                      child: Text('Opponent Scores'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _toggleOffense,
                      child: Text(game.isTeamOnOffense ? 'Turn Over' : 'Get Disc'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Stat Recording Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF334155),
              border: Border(
                bottom: BorderSide(color: Color(0xFF475569), width: 1),
              ),
            ),
            child: Column(
              children: [
                Text('Record Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0))),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatButton('Goal', 'goals', Color(0xFF10B981)),
                    _buildStatButton('Assist', 'assists', Color(0xFF3B82F6)),
                    _buildStatButton('Block', 'blocks', Color(0xFFF59E0B)),
                    _buildStatButton('Catch', 'catches', Color(0xFF14B8A6)),
                    _buildStatButton('Drop', 'drops', Color(0xFFEC4899)),
                    _buildStatButton('Pull', 'pulls', Color(0xFF8B5CF6)),
                  ],
                ),
              ],
            ),
          ),
          
          // Player Stats Display Section
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Player Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: game.team.players.length + game.unknownPlayers.length,
                      itemBuilder: (context, index) {
                        Player player;
                        bool isUnknown = false;
                        
                        if (index < game.team.players.length) {
                          player = game.team.players[index];
                        } else {
                          player = game.unknownPlayers[index - game.team.players.length];
                          isUnknown = true;
                        }
                        
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          color: isUnknown ? Color(0xFF334155) : null,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (isUnknown) 
                                          Icon(Icons.help_outline, size: 16, color: Color(0xFF94A3B8)),
                                        if (isUnknown) SizedBox(width: 4),
                                        Text(
                                          player.name,
                                          style: TextStyle(
                                            fontSize: 16, 
                                            fontWeight: FontWeight.bold,
                                            color: isUnknown ? Color(0xFFE2E8F0) : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!isUnknown) Text('#${player.jerseyNumber}'),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  isUnknown ? 'Not on roster' : 'Position: ${player.position}', 
                                  style: TextStyle(color: isUnknown ? Color(0xFF94A3B8) : Colors.grey[600]),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 12,
                                  children: [
                                    _buildStatChip('G', player.goals, Color(0xFF10B981)),
                                    _buildStatChip('A', player.assists, Color(0xFF3B82F6)),
                                    _buildStatChip('B', player.blocks, Color(0xFFF59E0B)),
                                    _buildStatChip('C', player.catches, Color(0xFF14B8A6)),
                                    _buildStatChip('D', player.drops, Color(0xFFEC4899)),
                                    _buildStatChip('P', player.pulls, Color(0xFF8B5CF6)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton(String label, String statType, Color color) {
    return ElevatedButton(
      onPressed: () => _recordStat(statType),
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildStatChip(String label, int value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color.withOpacity(0.8)),
      ),
    );
  }
}