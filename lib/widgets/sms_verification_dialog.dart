import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_service.dart';
import 'name_input_dialog.dart';

class SmsVerificationDialog extends StatefulWidget {
  final String phoneNumber;
  final String verificationCode; // For demo purposes
  final VoidCallback onVerificationSuccess;

  SmsVerificationDialog({
    required this.phoneNumber,
    required this.verificationCode,
    required this.onVerificationSuccess,
  });

  @override
  _SmsVerificationDialogState createState() => _SmsVerificationDialogState();
}

class _SmsVerificationDialogState extends State<SmsVerificationDialog> {
  final _codeController = TextEditingController();
  final _dataService = DataService();
  bool _isVerifying = false;

  void _verifyCode() async {
    if (_codeController.text.length != 6) {
      _showError('Please enter a 6-digit code');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // Check if this is a first-time user
      final isFirstTime = await _dataService.isFirstTimeUser(widget.phoneNumber);
      
      if (isFirstTime) {
        // First-time user - show name input dialog
        Navigator.pop(context); // Close verification dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => NameInputDialog(
            phoneNumber: widget.phoneNumber,
            onNameEntered: (name) async {
              // Verify with the user's name
              final success = await _dataService.verifyCode(
                widget.phoneNumber,
                _codeController.text,
                userName: name,
              );
              
              Navigator.pop(context); // Close name dialog
              if (success) {
                widget.onVerificationSuccess();
              } else {
                _showError('Verification failed');
              }
            },
          ),
        );
      } else {
        // Returning user - verify directly
        final success = await _dataService.verifyCode(
          widget.phoneNumber,
          _codeController.text,
        );

        if (success) {
          Navigator.pop(context);
          widget.onVerificationSuccess();
        } else {
          _showError('Invalid verification code');
        }
      }
    } catch (e) {
      _showError('Verification failed');
    }

    setState(() {
      _isVerifying = false;
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

  void _resendCode() async {
    try {
      await _dataService.sendVerificationCode(widget.phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New verification code sent'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      _showError('Failed to resend code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Color(0xFF1E293B),
      title: Text(
        'Verify Phone Number',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Color(0xFFE2E8F0),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We sent a 6-digit code to:',
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
          
          // Demo code display (remove in production)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF334155),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF475569)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo code: ${widget.verificationCode}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: Color(0xFFE2E8F0),
            ),
            decoration: InputDecoration(
              labelText: 'Verification Code',
              hintText: '000000',
              counterText: '',
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
            ),
            onSubmitted: (_) => _verifyCode(),
          ),
          SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Didn\'t receive the code? ',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              TextButton(
                onPressed: _resendCode,
                child: Text(
                  'Resend',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verifyCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3B82F6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isVerifying
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Verify',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }
}