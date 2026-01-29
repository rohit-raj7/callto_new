import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Last Updated: November 7, 2025",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            _sectionTitle("1. Introduction"),
            _sectionText(
              "Welcome to our application. By accessing or using this app, "
              "you agree to be bound by these Terms and Conditions. "
              "If you do not agree, please do not use the app.",
            ),

            _sectionTitle("2. Use of the App"),
            _sectionText(
              "You agree to use the app only for lawful purposes and in a manner "
              "that does not violate any applicable laws or regulations, "
              "or infringe the rights of others.",
            ),

            _sectionTitle("3. Privacy Policy"),
            _sectionText(
              "Your privacy is important to us. Please review our Privacy Policy "
              "to understand how we collect, use, and protect your information.",
            ),

            _sectionTitle("4. User Accounts"),
            _sectionText(
              "You are responsible for maintaining the confidentiality of your "
              "account information and for all activities that occur under your account.",
            ),

            _sectionTitle("5. Intellectual Property"),
            _sectionText(
              "All content, features, and functionality of the app, including text, "
              "graphics, logos, and software, are the property of the company and "
              "are protected by applicable intellectual property laws.",
            ),

            _sectionTitle("6. Limitation of Liability"),
            _sectionText(
              "We shall not be liable for any indirect, incidental, special, "
              "or consequential damages arising from your use of or inability "
              "to use the application.",
            ),

            _sectionTitle("7. Termination"),
            _sectionText(
              "We reserve the right to suspend or terminate your access to the app "
              "at any time without prior notice if you violate these terms.",
            ),

            _sectionTitle("8. Changes to Terms"),
            _sectionText(
              "We may update these Terms and Conditions from time to time. "
              "Continued use of the app after changes constitutes acceptance "
              "of the updated terms.",
            ),

            _sectionTitle("9. Governing Law"),
            _sectionText(
              "These terms shall be governed and interpreted in accordance "
              "with the laws applicable in your jurisdiction.",
            ),

            _sectionTitle("10. Contact Us"),
            _sectionText(
              "If you have any questions about these Terms and Conditions, "
              "please contact us through the support section of the app.",
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "I Agree",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Section Body Text Widget
  Widget _sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
        color: Colors.black54,
      ),
    );
  }
}
