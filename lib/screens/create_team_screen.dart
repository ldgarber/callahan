import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/team.dart';

class CreateTeamScreen extends StatefulWidget {
  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _teamNameController = TextEditingController();
  final _dataService = DataService();

  void _createTeam() {
    if (_teamNameController.text.isNotEmpty) {
      final team = Team(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _teamNameController.text,
        players: [],
        coachId: _dataService.currentUser!.id,
      );
      _dataService.addTeam(team);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Team')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(
                labelText: 'Team Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createTeam,
              child: Text('Create Team'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}