import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NameInputDialog extends StatefulWidget {
  final String phoneNumber;
  final Function(String name) onNameEntered;

  NameInputDialog({
    required this.phoneNumber,
    required this.onNameEntered,
  });

  @override
  _NameInputDialogState createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<NameInputDialog> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  void _submitName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter your name');
      return;
    }

    if (name.length < 2) {
      _showError('Name must be at least 2 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Small delay for better UX
    Future.delayed(Duration(milliseconds: 300), () {
      widget.onNameEntered(name);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Color(0xFF1E293B),
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.person_add,
                size: 30,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to Callahan!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE2E8F0),
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'re signing in for the first time with:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: 4),
            Text(
              widget.phoneNumber,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE2E8F0),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'What should we call you?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE2E8F0),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFFE2E8F0),
              ),
              decoration: InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Color(0xFF334155),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF475569)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF475569)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
                labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                hintStyle: TextStyle(color: Color(0xFF64748B)),
              ),
              onSubmitted: (_) => _submitName(),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF334155),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF475569)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will be displayed in your profile and team management.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitName,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Continue',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}