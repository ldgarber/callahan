import 'package:flutter/material.dart';

class EndGameDialog extends StatefulWidget {
  final int currentTeamScore;
  final int currentOpponentScore;
  final String teamName;
  final String opponentName;
  final Function(int, int) onGameEnded;

  EndGameDialog({
    required this.currentTeamScore,
    required this.currentOpponentScore,
    required this.teamName,
    required this.opponentName,
    required this.onGameEnded,
  });

  @override
  _EndGameDialogState createState() => _EndGameDialogState();
}

class _EndGameDialogState extends State<EndGameDialog> {
  late TextEditingController _teamScoreController;
  late TextEditingController _opponentScoreController;

  @override
  void initState() {
    super.initState();
    _teamScoreController = TextEditingController(text: widget.currentTeamScore.toString());
    _opponentScoreController = TextEditingController(text: widget.currentOpponentScore.toString());
  }

  @override
  void dispose() {
    _teamScoreController.dispose();
    _opponentScoreController.dispose();
    super.dispose();
  }

  void _endGame() {
    final teamScore = int.tryParse(_teamScoreController.text);
    final opponentScore = int.tryParse(_opponentScoreController.text);

    if (teamScore != null && opponentScore != null && teamScore >= 0 && opponentScore >= 0) {
      widget.onGameEnded(teamScore, opponentScore);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid scores')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('End Game'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Set the final scores for the game:', style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(widget.teamName, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _teamScoreController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Final Score',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Text('vs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Text(widget.opponentName, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _opponentScoreController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Final Score',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Current tracking scores: ${widget.teamName} ${widget.currentTeamScore} - ${widget.currentOpponentScore} ${widget.opponentName}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _endGame,
          child: Text('End Game'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
        ),
      ],
    );
  }
}