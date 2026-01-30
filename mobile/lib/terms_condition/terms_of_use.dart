import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Terms & Conditions"),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          /// HERO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.pink, Colors.redAccent],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.gavel, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Terms & Conditions",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please read these terms carefully before using CallTo services",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Last Updated: January 30, 2026",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoBanner(
                      icon: Icons.location_on,
                      title: "Parent Company",
                      content:
                          "Appdost Complete IT Solution Pvt. Ltd., Patna, Bihar, India",
                      color: Colors.blue,
                    ),
                    _infoBanner(
                      icon: Icons.warning_amber,
                      title: "Important Notice",
                      content:
                          "By accessing or using CallTo, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the service.",
                      color: Colors.orange,
                    ),

                    _section(
                      title: "1. Introduction",
                      body:
                          "These Terms and Conditions form a legally binding agreement between the user and CallTo. By using CallTo, you confirm full acceptance of all obligations, responsibilities, and legal terms described herein.",
                    ),

                    _section(
                      title: "2. Registration and Eligibility",
                      body:
                          "Users must provide accurate and verifiable information. Registration may require phone number, email, or Google authentication.",
                      bullets: const [
                        "Only users aged 18+ may register independently",
                        "Minors require parental consent",
                        "Information must remain accurate and updated",
                        "Identity verification may be requested",
                      ],
                    ),

                    _section(
                      title: "3. Nature of the Platform",
                      body:
                          "CallTo is a real-time voice communication platform. It is not a dating, escort, adult, or sexually oriented service.",
                      warning:
                          "All conversations must remain respectful, legal, and non-explicit.",
                    ),

                    _section(
                      title: "4. User Conduct During Calls",
                      bullets: const [
                        "No sexual, abusive, or obscene language",
                        "No recording without consent",
                        "No threats, blackmail, or harassment",
                        "Respectful communication is mandatory",
                      ],
                    ),

                    _section(
                      title: "5. Account Responsibilities",
                      bullets: const [
                        "Keep login credentials confidential",
                        "You are responsible for all activity on your account",
                        "Report compromised accounts immediately",
                      ],
                    ),

                    _dangerSection(
                      title: "6. Prohibited Activities",
                      bullets: const [
                        "Hacking or system manipulation",
                        "Fake profiles or impersonation",
                        "Fraud, spam, or illegal activity",
                        "Violations may result in permanent bans",
                      ],
                    ),

                    _section(
                      title: "7. Privacy & Data Handling",
                      body:
                          "CallTo processes user data in compliance with India’s DPDP Act for safety, analytics, and service improvement.",
                    ),

                    _section(
                      title: "8. Payments & Premium Features",
                      bullets: const [
                        "Payments must be authorized and accurate",
                        "Purchases are non-refundable unless stated",
                        "Subscriptions may auto-renew",
                      ],
                    ),

                    _section(
                      title: "9. Intellectual Property",
                      body:
                          "All CallTo branding, code, and assets are protected under Indian IP laws.",
                    ),

                    _section(
                      title: "10. Third-Party Services",
                      body:
                          "CallTo relies on third-party services. We are not responsible for their availability or policies.",
                    ),

                    _section(
                      title: "11. Service Availability",
                      body:
                          "Services may be modified or discontinued at any time. Violations may lead to termination.",
                    ),

                    _section(
                      title: "12. Modifications to Terms",
                      body:
                          "Terms may be updated periodically. Continued use implies acceptance.",
                    ),

                    _section(
                      title: "13. Limitation of Liability",
                      body:
                          "CallTo is provided as-is and is not responsible for user behavior or technical disruptions.",
                    ),

                    _section(
                      title: "14. Jurisdiction",
                      body:
                          "All disputes are governed by Indian law under Patna, Bihar jurisdiction.",
                    ),

                    _contactSection(),

                    _acceptanceSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// -------- Widgets --------

  Widget _section({
    required String title,
    String? body,
    List<String>? bullets,
    String? warning,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(fontSize: 13)),
          ],
          if (bullets != null)
            ...bullets.map(
              (e) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.pink),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            ),
          if (warning != null)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                warning,
                style: const TextStyle(
                    fontSize: 13, color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dangerSection({required String title, required List<String> bullets}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _section(title: title, bullets: bullets),
    );
  }

  Widget _infoBanner({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(content, style: const TextStyle(fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _contactSection() {
    return _section(
      title: "15. Contact Information",
      bullets: const [
        "Support: support@callto.in",
        "Legal: info@callto.in",
        "Phone: +91 7061588507",
        "Location: Patna, Bihar, India",
      ],
    );
  }

  Widget _acceptanceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.pink, Colors.redAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          Icon(Icons.check_circle, size: 48, color: Colors.white),
          SizedBox(height: 10),
          Text(
            "Acceptance of Terms",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 6),
          Text(
            "By continuing to use CallTo, you confirm acceptance of these Terms.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
