import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerSelectionDialog extends StatelessWidget {
  final List<Player> players;
  final String statType;
  final Function(Player) onPlayerSelected;

  PlayerSelectionDialog({
    required this.players,
    required this.statType,
    required this.onPlayerSelected,
  });

  String _getStatDisplayName(String stat) {
    switch (stat) {
      case 'goals':
        return 'Goal';
      case 'assists':
        return 'Assist';
      case 'blocks':
        return 'Block';
      case 'turnovers':
        return 'Turnover';
      case 'catches':
        return 'Catch';
      case 'drops':
        return 'Drop';
      case 'pulls':
        return 'Pull';
      case 'callahans':
        return 'Callahan';
      default:
        return stat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Record ${_getStatDisplayName(statType)}'),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select the player who recorded this ${_getStatDisplayName(statType).toLowerCase()}:'),
            SizedBox(height: 16),
            
            // Unknown Player Option
            Card(
              color: Color(0xFF334155),
              child: ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: Color(0xFF94A3B8),
                ),
                title: Text(
                  'Unknown Player',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Player not on roster',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
                onTap: () {
                  // Create a special unknown player object
                  final unknownPlayer = Player(
                    id: 'unknown_${DateTime.now().millisecondsSinceEpoch}',
                    name: 'Unknown Player',
                    position: 'Unknown',
                    jerseyNumber: 0,
                  );
                  onPlayerSelected(unknownPlayer);
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(height: 12),
            
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return Card(
                    child: ListTile(
                      title: Text(player.name),
                      subtitle: Text('Position: ${player.position} • #${player.jerseyNumber}'),
                      onTap: () {
                        onPlayerSelected(player);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}