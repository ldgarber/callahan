import 'package:flutter/material.dart';
import '../models/player.dart';

class AddPlayerDialog extends StatefulWidget {
  final Function(Player) onPlayerAdded;

  AddPlayerDialog({required this.onPlayerAdded});

  @override
  _AddPlayerDialogState createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  String _selectedPosition = 'Handler';
  final _positions = ['Handler', 'Cutter', 'Hybrid'];

  void _addPlayer() {
    if (_nameController.text.isNotEmpty && _numberController.text.isNotEmpty) {
      final jerseyNumber = int.tryParse(_numberController.text);
      if (jerseyNumber != null && jerseyNumber > 0) {
        final player = Player(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          position: _selectedPosition,
          jerseyNumber: jerseyNumber,
        );
        widget.onPlayerAdded(player);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid jersey number')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Player'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Player Name'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _numberController,
            decoration: InputDecoration(labelText: 'Jersey Number'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedPosition,
            items: _positions.map((position) {
              return DropdownMenuItem(value: position, child: Text(position));
            }).toList(),
            onChanged: (value) => setState(() => _selectedPosition = value!),
            decoration: InputDecoration(labelText: 'Position'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(onPressed: _addPlayer, child: Text('Add')),
      ],
    );
  }
}
