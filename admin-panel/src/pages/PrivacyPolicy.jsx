import React from 'react';
import { motion } from 'framer-motion';
import { Shield, Lock, Eye, Database, Mail, AlertTriangle, CheckCircle, Users } from 'lucide-react';
import PublicNavbar from '../components/PublicNavbar';

const PrivacyPolicy = () => {
  const fadeInUp = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0 }
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <PublicNavbar />

      {/* Hero Section */}
      <section className="relative pt-32 pb-12 px-4">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center"
          >
            <div className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-pink-500 to-rose-600 rounded-2xl mb-6 shadow-xl">
              <Shield className="w-10 h-10 text-white" strokeWidth={2.5} />
            </div>
            <h1 className="text-4xl font-extrabold text-gray-900 dark:text-white mb-4">
              Privacy Policy
            </h1>
            <p className="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
              Your privacy and data security are our top priorities
            </p>
            <p className="text-sm text-gray-500 dark:text-gray-400 mt-4">
              Last Updated: January 27, 2026
            </p>
          </motion.div>
        </div>
      </section>

      {/* Content Section */}
      <section className="py-12 px-4">
        <div className="max-w-4xl mx-auto">
          <div className="space-y-6">
            {/* Important Notice */}
            <motion.div
              variants={fadeInUp}
              className="bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/20 dark:to-orange-900/20 border-l-4 border-amber-500 p-4 rounded-lg"
            >
              <div className="flex items-start gap-3">
                <AlertTriangle className="w-5 h-5 text-amber-600 dark:text-amber-400 flex-shrink-0 mt-1" />
                <div>
                  <h3 className="font-semibold text-amber-900 dark:text-amber-100 mb-1">Important Notice</h3>
                  <p className="text-sm text-amber-800 dark:text-amber-200">
                    This Privacy Policy explains how Callto collects, uses, and protects your personal information when you use our online calling platform.
                  </p>
                </div>
              </div>
            </motion.div>

            {/* 1. Introduction */}
            <motion.section
              variants={fadeInUp}
              className="bg-white dark:bg-gray-800 rounded-xl p-5 shadow-sm border border-gray-200 dark:border-gray-700"
            >
              <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3">
                1. Introduction
              </h2>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed text-sm">
                Welcome to Callto! Your privacy is extremely important to us. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our platform for connecting with expert listeners through voice calls and text chats. By using Callto, you agree to the collection and use of information in accordance with this policy.
              </p>
            </motion.section>

            {/* 2. Information We Collect */}
            <motion.section
              variants={fadeInUp}
              className="bg-white dark:bg-gray-800 rounded-xl p-5 shadow-sm border border-gray-200 dark:border-gray-700"
            >
              <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3">
                2. Information We Collect
              </h2>

              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">Personal Information</h3>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed text-sm mb-4">
                When you create an account, we collect your name, email address, phone number, date of birth, gender, and profile information including your interests, preferences, and communication needs for matching with listeners.
              </p>

              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">Call & Communication Data</h3>
              <ul className="space-y-2 text-gray-600 dark:text-gray-400 text-sm mb-4">
                <li className="flex items-start space-x-2">
                  <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                  <span>Call duration, timestamps, and participant information</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                  <span>Audio recordings (when enabled for quality assurance)</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                  <span>Chat messages and conversation transcripts</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                  <span>Call quality metrics and connection data</span>
                </li>
              </ul>

              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">Technical Information</h3>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed text-sm">
                We collect information about your device and usage including IP address, browser type, operating system, device identifiers, app version, and network information for security, optimization, and troubleshooting purposes.
              </p>
            </motion.section>

            {/* 3. How We Use Your Information */}
            <motion.section
              variants={fadeInUp}
              className="bg-white dark:bg-gray-800 rounded-xl p-5 shadow-sm border border-gray-200 dark:border-gray-700"
            >
              <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3">
                3. How We Use Your Information
              </h2>
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-2">Service Delivery</h4>
                  <ul className="space-y-1 text-gray-600 dark:text-gray-400 text-sm">
                    <li>• Provide voice calling and text chat services</li>
                    <li>• Match you with appropriate listeners</li>
                    <li>• Process payments and manage wallet</li>
                    <li>• Send service notifications</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-2">Platform Improvement</h4>
                  <ul className="space-y-1 text-gray-600 dark:text-gray-400 text-sm">
                    <li>• Analyze usage patterns and preferences</li>
                    <li>• Improve call quality and features</li>
                    <li>• Develop new services</li>
                    <li>• Conduct research and analytics</li>
                  </ul>
                </div>
              </div>
            </motion.section>

            {/* 4. Information Sharing */}
            <motion.section
              variants={fadeInUp}
              className="bg-white dark:bg-gray-800 rounded-xl p-5 shadow-sm border border-gray-200 dark:border-gray-700"
            >
              <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3">
                4. Information Sharing & Disclosure
              </h2>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed text-sm mb-3">
                We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:
              </p>
              <ul className="space-y-2 text-gray-600 dark:text-gray-400 text-sm">
                <li className="flex items-start space-x-2">
                  <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0 mt-0.5" />
                  <span><strong>With Listeners:</strong> Basic profile information necessary for conversations</span>
                </li>
                <li className="flex items-start space-x-2">
                  <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0 mt-0.5" />
                  <span><strong>Service Providers:</strong> Payment processors and cloud hosting partners</span>
                </li>
                <li className="flex items-start space-x-2">
                  <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0 mt-0.5" />
                  <span><strong>Legal Requirements:</strong> When required by law or to protect rights</span>
                </li>
                <li className="flex items-start space-x-2">
                  <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0 mt-0.5" />
                  <span><strong>Business Transfers:</strong> In case of merger, acquisition, or sale</span>
                </li>
              </ul>
            </motion.section>

            {/* 5. Data Security */}
            <motion.section
              variants={fadeInUp}
              className="bg-white dark:bg-gray-800 rounded-xl p-5 shadow-sm border border-gray-200 dark:border-gray-700"
            >
              <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3">
                5. Data Security & Protection
              </h2>
              <div className="grid md:grid-cols-2 gap-4">
                <div className="bg-gray-50 dark:bg-gray-700/50 rounded-lg p-3">
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-2">Technical Security</h4>
                  <ul className="space-y-1 text-gray-600 dark:text-gray-400 text-sm">
                    <li>• End-to-end encryption for calls</li>
                    <li>• SSL/TLS encryption for data</li>
                    <li>• Secure cloud storage (AWS/GCP)</li>
                    <li>• Regular security audits</li>
                  </ul>
                </div>
                <div className="bg-gray-50 dark:bg-gray-700/50 rounded-lg p-3">
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-2">Administrative Security</h4>
                  <ul className="space-y-1 text-gray-600 dark:text-gray-400 text-sm">
                    <li>• Access controls and permissions</li>
                    <li>• Employee background checks</li>
                    <li>• Data minimization practices</li>
                    <li>• Incident response procedures</li>
                  </ul>
                </div>
              </div>
            </motion.section>

            {/* 6. Your Rights & Choices */}
            <motion.section
              variants={fadeInUp}
              className="bg-white dark:bg-gray-800 rounded-xl p-5 shadow-sm border border-gray-200 dark:border-gray-700"
            >
              <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3">
                6. Your Rights & Choices
              </h2>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed text-sm mb-3">
                Under Indian data protection laws and our commitment to privacy, you have the following rights:
              </p>
              <div className="grid md:grid-cols-2 gap-3">
                <ul className="space-y-2 text-gray-600 dark:text-gray-400 text-sm">
                  <li className="flex items-start space-x-2">
                    <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                    <span>Access your personal data</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                    <span>Correct inaccurate information</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                    <span>Delete your account and data</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                    <span>Withdraw consent for processing</span>
                  </li>
                </ul>
                <ul className="space-y-2 text-gray-600 dark:text-gray-400 text-sm">
                  <li className="flex items-start space-x-2">
                    <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                    <span>Data portability</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                    <span>Object to processing</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                    <span>Lodge complaints with authorities</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                    <span>Opt-out of marketing communications</span>
                  </li>
                </ul>
              </div>
            </motion.section>

            {/* 7. Call Recording & Monitoring */}
            <motion.section
              variants={fadeInUp}
              className="bg-blue-50 dark:bg-blue-900/20 rounded-xl p-5 shadow-sm border border-blue-200 dark:border-blue-800"
            >
              <h2 className="text-xl font-bold text-blue-900 dark:text-blue-100 mb-3">
                7. Call Recording & Monitoring
              </h2>
              <div className="space-y-3 text-blue-800 dark:text-blue-200 text-sm">
                <p>
                  <strong>Quality Assurance:</strong> Some calls may be recorded and monitored to maintain service quality, train listeners, and resolve disputes.
                </p>
                <p>
                  <strong>Your Consent:</strong> By using Callto's calling services, you consent to such recording. You can withdraw consent by discontinuing use.
                </p>
                <p>
                  <strong>Data Retention:</strong> Recordings are securely stored for 90 days (legal requirement) and then permanently deleted unless needed for legal proceedings.
                </p>
                <p>
                  <strong>Access Rights:</strong> You can request access to your call recordings through our support channels.
                </p>
              </div>
            </motion.section>

            {/* 8. International Data Transfers */}
            <motion.section
              variants={fadeInUp}
              className="bg-white dark:bg-gray-800 rounded-xl p-5 shadow-sm border border-gray-200 dark:border-gray-700"
            >
              <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3">
                8. International Data Transfers
              </h2>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed text-sm">
                Callto operates globally and your data may be transferred to and processed in countries other than India. We ensure appropriate safeguards are in place, including:
              </p>
              <ul className="space-y-2 text-gray-600 dark:text-gray-400 text-sm mt-3">
                <li className="flex items-start space-x-2">
                  <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                  <span>Standard contractual clauses approved by Indian authorities</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                  <span>Adequacy decisions for certified countries</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                  <span>Binding corporate rules for intra-group transfers</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                  <span>Your explicit consent where required</span>
                </li>
              </ul>
            </motion.section>

            {/* 9. Children's Privacy */}
            <motion.section
              variants={fadeInUp}
              className="bg-white dark:bg-gray-800 rounded-xl p-5 shadow-sm border border-gray-200 dark:border-gray-700"
            >
              <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3">
                9. Children's Privacy
              </h2>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed text-sm">
                Callto is not intended for children under 18 years of age. We do not knowingly collect personal information from children under 18. If we become aware that we have collected personal information from a child under 18, we will take steps to delete such information promptly.
              </p>
            </motion.section>

            {/* 10. Changes to Privacy Policy */}
            <motion.section
              variants={fadeInUp}
              className="bg-white dark:bg-gray-800 rounded-xl p-5 shadow-sm border border-gray-200 dark:border-gray-700"
            >
              <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3">
                10. Changes to Privacy Policy
              </h2>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed text-sm">
                We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new Privacy Policy on this page and updating the "Last Updated" date. Your continued use of Callto after such changes constitutes acceptance of the updated Privacy Policy.
              </p>
            </motion.section>

            {/* 11. Contact Information */}
            <motion.section
              variants={fadeInUp}
              className="bg-gradient-to-br from-pink-50 to-rose-50 dark:from-pink-900/20 dark:to-rose-900/20 rounded-xl p-5 shadow-sm border border-pink-200 dark:border-pink-800"
            >
              <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-3">
                11. Contact Information
              </h2>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed text-sm mb-4">
                If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices:
              </p>
              <div className="grid md:grid-cols-2 gap-4">
                <div className="bg-white dark:bg-gray-800 rounded-lg p-3 border border-gray-200 dark:border-gray-700">
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-2">Privacy Team</h4>
                  <p className="text-sm text-gray-700 dark:text-gray-300">
                    <strong>Email:</strong> privacy@callto.com<br />
                    <strong>Response Time:</strong> 2-3 business days
                  </p>
                </div>
                <div className="bg-white dark:bg-gray-800 rounded-lg p-3 border border-gray-200 dark:border-gray-700">
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-2">Data Protection Officer</h4>
                  <p className="text-sm text-gray-700 dark:text-gray-300">
                    <strong>Email:</strong> dpo@callto.com<br />
                    <strong>Address:</strong> [Company Address], India
                  </p>
                </div>
              </div>
              <div className="bg-blue-50 dark:bg-blue-900/30 border border-blue-200 dark:border-blue-800 rounded-lg p-3 mt-4">
                <p className="text-sm text-blue-900 dark:text-blue-100">
                  <strong>Grievance Redressal:</strong> For complaints under IT Act 2000, contact our Grievance Officer at grievance@callto.com
                </p>
              </div>
            </motion.section>

            {/* Acknowledgment */}
            <motion.section
              variants={fadeInUp}
              className="bg-gradient-to-r from-pink-500 to-rose-500 rounded-xl p-5 shadow-lg text-white text-center"
            >
              <Shield className="w-12 h-12 mx-auto mb-3" />
              <h3 className="text-lg font-bold mb-2">
                Your Privacy Matters
              </h3>
              <p className="text-pink-100 leading-relaxed text-sm max-w-2xl mx-auto">
                We're committed to protecting your privacy and being transparent about our data practices. Your trust is important to us.
              </p>
              <div className="mt-4 text-xs text-pink-100">
                <p>Privacy Policy Version 2.1 - India</p>
              </div>
            </motion.section>
          </div>
        </div>
      </section>
    </div>
  );
};

export default PrivacyPolicy;