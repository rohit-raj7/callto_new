import 'package:flutter/material.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Refund Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _heroSection(),
            const SizedBox(height: 20),
            _companyInfo(),
            const SizedBox(height: 16),
            _importantNotice(),
            const SizedBox(height: 16),

            _dangerSection(
              title: "1. No Refund After Processing Begins",
              content:
                  "Once an order or service request is assigned to a consultant, no refund will be issued under any circumstances. Users must place orders carefully.",
            ),

            _dangerSection(
              title: "2. No Refund After Service Execution",
              content:
                  "No refunds are provided after live calls, chats, or real-time interactions are completed.",
              bullets: const [
                "Live audio or video calls",
                "Chat consultations",
                "Real-time conversations",
                "Any digital service delivered",
              ],
            ),

            _normalSection(
              title: "3. Technical Delays & Glitches",
              content:
                  "Technical delays, processing time, or temporary glitches are not valid grounds for refunds.",
              bullets: const [
                "Report delays",
                "Internet or device issues",
                "Environmental limitations",
              ],
            ),

            _normalSection(
              title: "4. Network Issues & Weak Signals",
              content:
                  "Refunds may be considered only in severe technical failure cases.",
              bullets: const [
                "Call could not connect",
                "Audio completely inaudible",
                "Consultant unreachable",
              ],
              positive: true,
            ),

            _normalSection(
              title: "5. Accuracy of Consultation",
              content:
                  "CallTo does not guarantee accuracy of advice. Refunds will not be granted for dissatisfaction or expectations.",
              negativeBox: true,
            ),

            _normalSection(
              title: "6. Correction of User Information",
              content:
                  "Users are responsible for verifying information. Incorrect data does not qualify for refunds.",
            ),

            _normalSection(
              title: "7. Refund Deductions",
              content:
                  "Approved refunds are processed after deducting gateway fees, taxes, and processing charges.",
            ),

            _normalSection(
              title: "8. Payment Gateway Issues",
              content:
                  "If payment is debited but service not delivered, contact support immediately.",
            ),

            _normalSection(
              title: "9. Order Cancellations by CallTo",
              content:
                  "If CallTo cancels a paid order, the full amount will be refunded.",
            ),

            _normalSection(
              title: "10. Quality Audit & Review",
              content:
                  "Refund requests may be audited using call logs or chat history. Review may take up to 72 hours.",
            ),

            _dangerSection(
              title: "11. Wallet-Based Refunds",
              content:
                  "All refunds are credited only to CallTo Wallet and cannot be transferred to bank or UPI.",
            ),

            _dangerSection(
              title: "12. Real-Time Calling Special Conditions",
              content:
                  "No refunds once a call connects or interaction begins.",
            ),

            _normalSection(
              title: "13. Refund Eligibility",
              content:
                  "Only severe technical failures are eligible for refunds. Style, tone, or emotional dissatisfaction is not.",
            ),

            _finalDecision(),
            const SizedBox(height: 16),
            _contactSection(),
            const SizedBox(height: 24),
            _footer(),
          ],
        ),
      ),
    );
  }

  // ========================= UI SECTIONS =========================

  Widget _heroSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.pink, Colors.redAccent],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.currency_rupee, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 12),
        const Text(
          "Refund Policy",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          "Understanding our refund terms and conditions",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "Last Updated: January 30, 2026",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _companyInfo() {
    return _infoCard(
      icon: Icons.location_on,
      title: "Parent Company",
      content:
          "Appdost Complete IT Solution Pvt. Ltd.\nPatna, Bihar, India",
      color: Colors.blue,
    );
  }

  Widget _importantNotice() {
    return _infoCard(
      icon: Icons.warning_amber,
      title: "Important Notice",
      content:
          "This Refund Policy explains when CallTo may issue refunds. By using CallTo, you agree to these terms.",
      color: Colors.orange,
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
      ),
    );
  }

  Widget _normalSection({
    required String title,
    required String content,
    List<String>? bullets,
    bool positive = false,
    bool negativeBox = false,
  }) {
    return _sectionCard(
      title: title,
      content: content,
      bullets: bullets,
      color: positive ? Colors.green : Colors.grey,
      negativeBox: negativeBox,
    );
  }

  Widget _dangerSection({
    required String title,
    required String content,
    List<String>? bullets,
  }) {
    return _sectionCard(
      title: title,
      content: content,
      bullets: bullets,
      color: Colors.red,
      danger: true,
    );
  }

  Widget _sectionCard({
    required String title,
    required String content,
    Color color = Colors.grey,
    bool danger = false,
    bool negativeBox = false,
    List<String>? bullets,
  }) {
    return Card(
      color: danger ? Colors.red.shade50 : null,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content),
            if (bullets != null) ...[
              const SizedBox(height: 8),
              ...bullets.map(
                (e) => Row(
                  children: [
                    Icon(
                      danger ? Icons.close : Icons.check_circle,
                      size: 16,
                      color: danger ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(e)),
                  ],
                ),
              ),
            ],
            if (negativeBox)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Disclaimer: Services are for entertainment and communication only.",
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _finalDecision() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [Colors.pink, Colors.redAccent]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Final Decision & Process",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "All refund decisions taken by CallTo are final and non-negotiable.",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _contactSection() {
    return Card(
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.email),
            title: Text("support@callto.in"),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("info@callto.in"),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text("+91 7061588507"),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Column(
      children: const [
        Icon(Icons.currency_rupee, size: 40, color: Colors.pink),
        SizedBox(height: 8),
        Text(
          "Policy Version 2.0 - India & GCC\nEffective Date: January 1, 2025",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
