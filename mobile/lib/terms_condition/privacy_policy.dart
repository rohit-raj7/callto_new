import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF111827), const Color(0xFF1F2937)]
                : [const Color(0xFFF9FAFB), const Color(0xFFF3F4F6)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Hero Section
            SliverAppBar(
              expandedHeight: 300,
              floating: false,
              pinned: true,
              backgroundColor: isDarkMode ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [const Color(0xFF111827), const Color(0xFF1F2937)]
                          : [const Color(0xFFF9FAFB), const Color(0xFFF3F4F6)],
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFEC4899), Color(0xFAE24561)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEC4899).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.security,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Privacy Policy',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              'Your privacy and data security are our top priorities',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Last Updated: January 30, 2026 | Under Appdost Technologies Pvt. Ltd.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Content Section
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Company Info
                      _buildInfoCard(
                        context,
                        icon: Icons.location_on,
                        title: 'Parent Company',
                        content: 'Appdost Technologies Pvt. Ltd., Registered in India',
                        backgroundColor: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
                        borderColor: const Color(0xFF3B82F6),
                        iconColor: const Color(0xFF2563EB),
                      ),
                      const SizedBox(height: 16),

                      // Important Notice
                      _buildWarningCard(
                        context,
                        icon: Icons.warning_amber_rounded,
                        title: 'Important Notice',
                        content:
                            'This Privacy Policy explains how Callto collects, uses, and protects your personal information. By accessing or using Callto, you consent to the practices described herein.',
                        backgroundColor: isDarkMode ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                        borderColor: const Color(0xFFFCD34D),
                        iconColor: const Color(0xFDB925),
                      ),
                      const SizedBox(height: 20),

                      // 1. About CallTo
                      _buildSectionCard(
                        context,
                        title: '1. About CallTo and Its Ownership',
                        children: [
                          _buildParagraph(
                            context,
                            'Callto is a communication and social interaction platform designed for real-time calling between consenting adults. It is not an independent company but a service, product, and brand fully owned, managed, and maintained by Appdost Technologies Pvt. Ltd. registered in India.',
                          ),
                          const SizedBox(height: 12),
                          _buildParagraph(
                            context,
                            'All legal responsibilities, data management, support, and compliance operations are controlled by Appdost as the parent company. This Privacy Policy is compliant with the Digital Personal Data Protection Act (DPDP Act 2023), Information Technology Act 2000, and GCC regional data protection standards.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 2. Information We Collect
                      _buildSectionCard(
                        context,
                        title: '2. Information We Collect',
                        children: [
                          _buildSubsection(
                            context,
                            title: 'Personal Information',
                            items: [
                              'Full name, username, email, phone number',
                              'Gender, date of birth (age verification)',
                              'Profile picture and identity documents (when required)',
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSubsection(
                            context,
                            title: 'Usage & Interaction Data',
                            items: [
                              'Call logs (duration, timing, participants)',
                              'In-app navigation, search history, preferences',
                              'No audio/video stored unless required for compliance',
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSubsection(
                            context,
                            title: 'Device & Technical Information',
                            items: [
                              'Device model, OS, IP address, location (approximate)',
                              'Device identifiers, network provider, connection quality',
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSubsection(
                            context,
                            title: 'Payment & Transaction Data',
                            content:
                                'Payment details processed securely through authorized third-party gateways following PCI-DSS standards.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 3. Purpose of Data Collection
                      _buildSectionCard(
                        context,
                        title: '3. Purpose of Data Collection',
                        children: [
                          _buildParagraph(
                            context,
                            'Data is collected only for lawful, legitimate purposes:',
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildListItem(context, 'Account creation and verification'),
                                    _buildListItem(context, 'Real-time calling functionality'),
                                    _buildListItem(context, 'User matching based on preferences'),
                                    _buildListItem(context, 'Customer support provision'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildListItem(context, 'Fraud detection and prevention'),
                                    _buildListItem(context, 'User safety monitoring'),
                                    _buildListItem(context, 'App performance improvement'),
                                    _buildListItem(context, 'Legal compliance'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 4. Data Sharing & Disclosure
                      _buildSectionCard(
                        context,
                        title: '4. Data Sharing & Disclosure',
                        children: [
                          _buildParagraph(
                            context,
                            'We do not sell user data to third parties. Data is shared only in these circumstances:',
                            isBold: true,
                          ),
                          const SizedBox(height: 12),
                          _buildChecklistItem(
                            context,
                            'Parent Company:',
                            'Appdost Technologies for operations and compliance',
                          ),
                          _buildChecklistItem(
                            context,
                            'Service Providers:',
                            'Hosting, payment gateways, fraud-detection systems',
                          ),
                          _buildChecklistItem(
                            context,
                            'Legal Requirements:',
                            'Court orders or regulatory compliance',
                          ),
                          _buildChecklistItem(
                            context,
                            'User-Initiated:',
                            'Basic profile info to users you connect with',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 5. Data Security
                      _buildSectionCard(
                        context,
                        title: '5. Data Security & Protection',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildSecurityBox(
                                  context,
                                  title: 'Technical Security',
                                  items: [
                                    'End-to-end encryption',
                                    'SSL/TLS data encryption',
                                    'Secure cloud storage',
                                    'Regular security audits',
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSecurityBox(
                                  context,
                                  title: 'Administrative Security',
                                  items: [
                                    'Access controls',
                                    'Employee background checks',
                                    'Data minimization',
                                    'Incident response procedures',
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 6. Your Rights & Choices
                      _buildSectionCard(
                        context,
                        title: '6. Your Rights & Choices',
                        children: [
                          _buildParagraph(
                            context,
                            'Under Indian data protection laws, you have the following rights:',
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildListItem(context, 'Access your personal data'),
                                    _buildListItem(context, 'Correct inaccurate information'),
                                    _buildListItem(context, 'Delete your account and data'),
                                    _buildListItem(context, 'Withdraw consent for processing'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildListItem(context, 'Data portability'),
                                    _buildListItem(context, 'Object to processing'),
                                    _buildListItem(context, 'Lodge complaints with authorities'),
                                    _buildListItem(context, 'Opt-out of marketing'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 7. Age Limit & Child Safety
                      _buildHighlightCard(
                        context,
                        title: '7. Age Limit & Child Safety',
                        content:
                            'CallTo is strictly for adults aged 18 years or above.\n\nWe do not knowingly collect or process data from minors. If a minor is detected, we will suspend the account and delete associated data immediately.',
                        backgroundColor: isDarkMode ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
                        borderColor: const Color(0xFFDC2626),
                        textColor: isDarkMode ? const Color(0xFFFECACA) : const Color(0xFF7F1D1D),
                      ),
                      const SizedBox(height: 20),

                      // 8. International Data Transfer
                      _buildSectionCard(
                        context,
                        title: '8. International Data Transfer',
                        children: [
                          _buildParagraph(
                            context,
                            'As Callto operates in India and GCC regions, data may be stored or processed on servers in India or globally distributed cloud infrastructure. All transfers are protected through encrypted channels and standardized data-protection agreements.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 9. Data Retention Policy
                      _buildSectionCard(
                        context,
                        title: '9. Data Retention Policy',
                        children: [
                          _buildParagraph(
                            context,
                            'Callto retains user data only for as long as necessary for providing services, legal obligations, and safety audits. When no longer needed, data is securely deleted or anonymized. Users may request deletion at any time through support channels.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 10. Real-Time Calling Safety
                      _buildHighlightCard(
                        context,
                        title: '10. Real-Time Calling Safety & User Responsibility',
                        content:
                            'CallTo facilitates real-time voice calling between consenting adults. To maintain safety:\n\n• Users must interact respectfully and lawfully\n• Harassment, explicit content, or harmful behavior is prohibited\n• Accounts may be restricted for misuse\n• Users are responsible for their interactions\n• CallTo does not endorse offline meetups',
                        backgroundColor: isDarkMode ? const Color(0xFF082F49) : const Color(0xFFEFF6FF),
                        borderColor: const Color(0xFF3B82F6),
                        textColor: isDarkMode ? const Color(0xFFBAE6FD) : const Color(0xFF1E40AF),
                      ),
                      const SizedBox(height: 20),

                      // 11. Changes to Privacy Policy
                      _buildSectionCard(
                        context,
                        title: '11. Changes to Privacy Policy',
                        children: [
                          _buildParagraph(
                            context,
                            'Callto may update this Privacy Policy periodically. Significant changes will be notified through in-app messages, email, or the platform. Continued use of Callto indicates acceptance of updated policies.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 12. Contact Information
                      _buildSectionCard(
                        context,
                        title: '12. Contact Information',
                        children: [
                          _buildParagraph(
                            context,
                            'For questions, concerns, or privacy requests, contact:',
                          ),
                          const SizedBox(height: 16),
                          _buildContactItem(
                            context,
                            icon: Icons.email,
                            label: 'Email Support',
                            value: 'support@callto.in',
                          ),
                          const SizedBox(height: 12),
                          _buildContactItem(
                            context,
                            icon: Icons.email,
                            label: 'General Inquiries',
                            value: 'info@callto.in',
                          ),
                          const SizedBox(height: 12),
                          _buildContactItem(
                            context,
                            icon: Icons.phone,
                            label: 'Phone',
                            value: '+91 7061588507',
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF0C4A6E).withOpacity(0.3)
                                  : const Color(0xFFEFF6FF),
                              border: Border.all(
                                color: isDarkMode
                                    ? const Color(0xFF0C4A6E)
                                    : const Color(0xFFBFDBFE),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Grievance Redressal: For IT Act 2000 complaints, contact Grievance Officer at support@callto.in',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDarkMode ? const Color(0xFF7DD3FC) : const Color(0xFF1E40AF),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Acknowledgment
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFEC4899), Color(0xFAE24561)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEC4899).withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.security,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your Privacy Matters',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "We're committed to protecting your privacy and being transparent about our data practices. Your trust is important to us.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Privacy Policy Version 3.0 - India',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Effective Date: January 1, 2025',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: iconColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
  }) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDarkMode ? Colors.amber[100] : Colors.amber[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: isDarkMode ? Colors.amber[200] : Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildParagraph(
    BuildContext context,
    String text, {
    bool isBold = false,
  }) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 13,
        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        height: 1.6,
      ),
    );
  }

  Widget _buildSubsection(
    BuildContext context, {
    required String title,
    String? content,
    List<String>? items,
  }) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (content != null)
          Text(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              height: 1.5,
            ),
          ),
        if (items != null) ...[
          Column(
            children: items.map((item) => _buildListItem(context, item)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildListItem(BuildContext context, String text) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFEC4899),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
    BuildContext context,
    String label,
    String content,
  ) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: Colors.green[500],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                  TextSpan(
                    text: ' $content',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBox(
    BuildContext context, {
    required String title,
    required List<String> items,
  }) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                '• $item',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(
    BuildContext context, {
    required String title,
    required String content,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: textColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF111827) : Colors.white,
        border: Border.all(
          color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFFBE185D),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}