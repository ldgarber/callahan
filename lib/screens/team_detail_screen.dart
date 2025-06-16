import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_service.dart';
import '../models/team.dart';
import '../models/game_session.dart';
import '../widgets/add_player_dialog.dart';

class TeamDetailScreen extends StatefulWidget {
  final Team team;

  TeamDetailScreen({required this.team});

  @override
  _TeamDetailScreenState createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    showDialog(
      context: context,
      builder: (context) => AddPlayerDialog(
        onPlayerAdded: (player) {
          _dataService.addPlayerToTeam(widget.team.id, player);
          setState(() {});
        },
      ),
    );
  }

  void _removePlayer(String playerId, String playerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Player'),
        content: Text('Are you sure you want to remove $playerName from the team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _dataService.removePlayerFromTeam(widget.team.id, playerId);
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Remove'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.name),
        actions: [
          if (_tabController.index == 0)
            IconButton(onPressed: _addPlayer, icon: Icon(Icons.add)),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Players'),
            Tab(text: 'Games'),
          ],
          onTap: (index) => setState(() {}), // Rebuild to show/hide add button
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlayersTab(),
          _buildGamesTab(),
        ],
      ),
    );
  }

  Widget _buildPlayersTab() {
    return widget.team.players.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Color(0xFF64748B),
                ),
                SizedBox(height: 16),
                Text(
                  'No players added yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add players',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: widget.team.players.length,
            itemBuilder: (context, index) {
              final player = widget.team.players[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            '#${player.jerseyNumber}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Position: ${player.position}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                        onPressed: () => _removePlayer(player.id, player.name),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildGamesTab() {
    final completedGames = _dataService.getCompletedGamesForTeam(widget.team.id);
    
    return completedGames.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_basketball_outlined,
                  size: 80,
                  color: Color(0xFF64748B),
                ),
                SizedBox(height: 16),
                Text(
                  'No completed games yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start a game to see results here',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: completedGames.length,
            itemBuilder: (context, index) {
              final game = completedGames[index];
              return _buildGameCard(game);
            },
          );
  }

  Widget _buildGameCard(GameSession game) {
    final teamScore = game.finalTeamScore ?? game.teamScore;
    final opponentScore = game.finalOpponentScore ?? game.opponentScore;
    final isWin = teamScore > opponentScore;
    final isDraw = teamScore == opponentScore;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDraw 
                        ? Color(0xFFF59E0B) 
                        : (isWin ? Color(0xFF10B981) : Color(0xFFEF4444)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDraw ? 'DRAW' : (isWin ? 'WIN' : 'LOSS'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  _formatGameDate(game.endTime ?? game.startTime),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.team.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Home',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF334155),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$teamScore - $opponentScore',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        game.opponent,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Away',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatGameDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}