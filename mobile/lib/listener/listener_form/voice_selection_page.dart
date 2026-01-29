 // lib/screens/voice_selection_page.dart
import 'package:flutter/material.dart';
import 'payment.dart';
import '../../services/storage_service.dart';

class VoiceSelectionPage extends StatefulWidget {
  final String? selectedLanguage;
  const VoiceSelectionPage({super.key, this.selectedLanguage});

  @override
  State<VoiceSelectionPage> createState() => _VoiceSelectionPageState();
}

class _VoiceSelectionPageState extends State<VoiceSelectionPage> {
  bool _hasRecorded = false;
  
  // Consistent color palette
  final Color primaryColor = const Color(0xFFFF4081);
  final Color backgroundColor = const Color(0xFFFCE4EC);
  final Color textPrimary = const Color(0xFF880E4F);

  final String verificationTextHi = """
Namaste! Dosti bahut khaas hoti hai. 
Acchhe dost hamesha saath dete hain. 
Dost khushi badhate hain aur dukh kam karte hain. 
Unke bina sab adhoora hai. Dhanyavaad!
""";

  void _simulateRecording() {
    setState(() {
      _hasRecorded = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Voice verified successfully! 🎉'),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    if (!_hasRecorded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete voice verification first'),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    final storageService = StorageService();
    
    try {
      // Save voice verification status to localStorage silently
      await storageService.saveListenerVoiceVerified(true);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PaymentPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _skip() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Voice Verification',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.03),

                // Title with icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.record_voice_over_rounded,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
                
                const SizedBox(height: 20),

                // Title
                Text(
                  'Audio Verification',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Instruction
                Text(
                  'Please record an audio of you saying the lines below for verification.',
                  style: TextStyle(
                    fontSize: 15,
                    color: textPrimary.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.04),

                // Verification Text Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        color: primaryColor,
                        size: 28,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Namaste! Dosti bahut khaas hoti hai. '
                        'Acchhe dost hamesha saath dete hain. '
                        'Dost khushi badhate hain aur dukh kam karte hain. '
                        'Unke bina sab adhoora hai. Dhanyavaad!',
                        style: TextStyle(
                          fontSize: 16,
                          color: textPrimary,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                // Microphone Button
                GestureDetector(
                  onTap: _simulateRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _hasRecorded ? Colors.green : primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: (_hasRecorded ? Colors.green : primaryColor).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _hasRecorded ? Icons.check_rounded : Icons.mic_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Hold to talk text
                Text(
                  _hasRecorded ? 'Verification Complete ✓' : 'Tap to Record',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _hasRecorded ? Colors.green.shade600 : textPrimary,
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                // Bottom Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _skip,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: primaryColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


