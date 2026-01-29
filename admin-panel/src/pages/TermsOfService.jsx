import React from 'react';
import { motion } from 'framer-motion';
import { Scale, FileText, Shield, AlertCircle, CheckCircle, Users, AlertTriangle, Mail } from 'lucide-react';
import PublicNavbar from '../components/PublicNavbar';

const TermsOfService = () => {
  const fadeInUp = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0 }
  };

  const staggerContainer = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const sections = [
    { id: 'updates', title: 'Updates and Modifications' },
    { id: 'consent', title: 'User Consent and Acceptance' },
    { id: 'description', title: 'Service Description' },
    { id: 'registration', title: 'Registration and Eligibility' },
    { id: 'services', title: 'Platform Services' },
    { id: 'content', title: 'Content Guidelines' },
    { id: 'privacy', title: 'Privacy and Data Protection' },
    { id: 'payments', title: 'Payments and Refunds' },
    { id: 'obligations', title: 'User Obligations' },
    { id: 'disclaimer', title: 'Disclaimers and Limitations' },
    { id: 'termination', title: 'Termination and Suspension' },
    { id: 'law', title: 'Governing Law and Jurisdiction' },
  ];

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
              <Scale className="w-10 h-10 text-white" strokeWidth={2.5} />
            </div>
            <h1 className="text-5xl font-extrabold text-gray-900 dark:text-white mb-4">
              Terms &amp; Conditions
            </h1>
            <p className="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
              Please read these terms carefully before using Callto services
            </p>
            <p className="text-sm text-gray-500 dark:text-gray-400 mt-4">
              Last Updated: January 25, 2026
            </p>
          </motion.div>
        </div>
      </section>

      {/* Content Section */}
      <section className="py-16 px-4">
        <div className="max-w-4xl mx-auto">
          <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl p-8 md:p-12 border border-gray-200 dark:border-gray-700">
            
            {/* Important Notice */}
            <div className="bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/20 dark:to-orange-900/20 border-l-4 border-amber-500 p-6 rounded-lg mb-8">
              <div className="flex items-start gap-3">
                <AlertCircle className="w-6 h-6 text-amber-600 dark:text-amber-400 flex-shrink-0 mt-1" />
                <div>
                  <h3 className="font-bold text-amber-900 dark:text-amber-100 mb-2">Important Notice</h3>
                  <p className="text-sm text-amber-800 dark:text-amber-200">
                    By accessing or using Callto, you agree to be bound by these Terms and Conditions. 
                    If you do not agree to these terms, please do not use our services.
                  </p>
                </div>
              </div>
            </div>

            {/* Terms Content */}
            <div className="space-y-8">
              {/* 1. Introduction */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  1. Introduction
                </h2>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                  Welcome to Callto! These Terms of Service ("Terms") govern your use of our platform that connects users with expert listeners for voice calls and text chats. By accessing or using Callto, you agree to be bound by these Terms. If you do not agree to these Terms, please do not use our services.
                </p>
              </motion.section>

              {/* 2. Use of Services */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  2. Use of Services
                </h2>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
                  You agree to use Callto only for lawful purposes and in accordance with these Terms:
                </p>
                <ul className="space-y-2 text-gray-600 dark:text-gray-400">
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Connect with verified expert listeners for meaningful conversations</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Respect the privacy and confidentiality of all conversations</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Provide accurate information in your profile and during interactions</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Not engage in harassment, abuse, or inappropriate behavior</span>
                  </li>
                </ul>
              </motion.section>

              {/* 3. User Accounts */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  3. User Accounts
                </h2>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
                  You are responsible for maintaining the confidentiality of your account credentials:
                </p>
                <ul className="space-y-2 text-gray-600 dark:text-gray-400">
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Keep your password secure and do not share it with others</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Notify us immediately if you suspect unauthorized access</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>You are responsible for all activities under your account</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Provide accurate and current information during registration</span>
                  </li>
                </ul>
              </motion.section>

              {/* 4. Payments and Wallet */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  4. Payments and Wallet
                </h2>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
                  Payment terms for using Callto services:
                </p>
                <ul className="space-y-2 text-gray-600 dark:text-gray-400">
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>You pay per minute for voice calls and text chat sessions</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Rates are set by individual listeners and clearly displayed</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Add funds to your wallet using secure payment methods</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>All payments are final and non-refundable except in exceptional cases</span>
                  </li>
                </ul>
              </motion.section>

              {/* 5. Voice Calling Services */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  5. Voice Calling Services
                </h2>

                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">Call Quality & Connection</h3>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
                  Callto provides real-time voice calling services through internet connectivity. Quality depends on your network conditions:
                </p>
                <ul className="space-y-2 text-gray-600 dark:text-gray-400 mb-6">
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Minimum 2 Mbps internet speed recommended for voice calls</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>We are not responsible for call quality issues due to poor network</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Charges apply once connection is established, regardless of quality</span>
                  </li>
                </ul>

                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">Call Recording & Monitoring</h3>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
                  For quality assurance, training, and safety purposes, all calls may be recorded and monitored. By using our calling services, you consent to such recording. Recordings are stored securely and handled in accordance with our Privacy Policy and applicable Indian data protection laws.
                </p>

                <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4">
                  <h4 className="font-semibold text-red-900 dark:text-red-100 mb-2">Emergency Services Notice</h4>
                  <p className="text-sm text-red-800 dark:text-red-200">
                    Callto is NOT a substitute for emergency services. Our platform is for non-emergency support only. In case of medical, mental health, or safety emergencies, immediately contact local emergency services (Dial 112 in India) or appropriate crisis helplines.
                  </p>
                </div>
              </motion.section>

              {/* 6. Call Charges & Billing */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  6. Call Charges & Billing
                </h2>

                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">Per-Minute Billing</h3>
                <ul className="space-y-2 text-gray-600 dark:text-gray-400 mb-6">
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Charges are calculated per minute and deducted from your wallet</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Billing starts once the call is connected to the listener</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Partial minutes are rounded up to the nearest minute</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>You can view real-time charges during active calls</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Calls automatically disconnect when wallet balance is insufficient</span>
                  </li>
                </ul>

                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">Refund Policy for Calls</h3>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-3">Refunds are only provided in the following cases:</p>
                <ul className="space-y-2 text-gray-600 dark:text-gray-400">
                  <li className="flex items-start space-x-2">
                    <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                    <span>Technical failure preventing call connection (server issues)</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                    <span>Listener not responding after connection for more than 2 minutes</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                    <span>Duplicate charges due to payment gateway errors</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="text-red-500 font-bold">✗</span>
                    <span>No refunds for poor call quality due to user's network</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="text-red-500 font-bold">✗</span>
                    <span>No refunds for dissatisfaction with advice or conversation content</span>
                  </li>
                </ul>
              </motion.section>

              {/* 7. Data Privacy & Call Recording */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  7. Data Privacy & Call Recording
                </h2>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
                  Your privacy and data security are our top priorities. This section explains how we handle your data during online calling services:
                </p>

                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">Data We Collect During Calls</h3>
                <ul className="space-y-2 text-gray-600 dark:text-gray-400 mb-6">
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Call duration, timestamp, and participants</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Audio recordings (when enabled for quality assurance)</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Call quality metrics (connection speed, audio quality)</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Device and network information</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Ratings and feedback provided post-call</span>
                  </li>
                </ul>

                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">How We Use Recorded Calls</h3>
                <ul className="space-y-2 text-gray-600 dark:text-gray-400 mb-6">
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Quality assurance and service improvement</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Training listeners and maintaining service standards</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Dispute resolution and complaint investigation</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Compliance with legal obligations and law enforcement requests</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2 flex-shrink-0"></span>
                    <span>Safety and abuse prevention</span>
                  </li>
                </ul>

                <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
                  <p className="text-sm text-blue-900 dark:text-blue-100">
                    <strong>Your Rights:</strong> You have the right to request access to your call recordings, request deletion (subject to legal retention requirements), and withdraw consent. However, withdrawing consent may limit your ability to use certain features of our service.
                  </p>
                </div>
              </motion.section>

              {/* 8. Network & Technical Requirements */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  8. Network & Technical Requirements
                </h2>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-6">
                  To use Callto's online calling services effectively, you must meet the following requirements:
                </p>

                <div className="grid md:grid-cols-2 gap-6">
                  <div className="bg-gray-50 dark:bg-gray-700/50 rounded-lg p-4">
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-3">Device Requirements</h3>
                    <ul className="space-y-2 text-sm text-gray-600 dark:text-gray-400">
                      <li className="flex items-start space-x-2">
                        <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                        <span>Smartphone with Android 7.0+ or iOS 12+</span>
                      </li>
                      <li className="flex items-start space-x-2">
                        <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                        <span>Working microphone and speakers/headphones</span>
                      </li>
                      <li className="flex items-start space-x-2">
                        <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                        <span>Latest version of Callto app</span>
                      </li>
                    </ul>
                  </div>

                  <div className="bg-gray-50 dark:bg-gray-700/50 rounded-lg p-4">
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-3">Network Requirements</h3>
                    <ul className="space-y-2 text-sm text-gray-600 dark:text-gray-400">
                      <li className="flex items-start space-x-2">
                        <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                        <span>Stable 4G/5G mobile data or WiFi</span>
                      </li>
                      <li className="flex items-start space-x-2">
                        <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                        <span>2+ Mbps stable internet connection</span>
                      </li>
                      <li className="flex items-start space-x-2">
                        <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                        <span>Low latency connection (under 150ms)</span>
                      </li>
                      <li className="flex items-start space-x-2">
                        <span className="w-1.5 h-1.5 bg-pink-500 rounded-full mt-1.5"></span>
                        <span>Stable connection throughout the call</span>
                      </li>
                    </ul>
                  </div>
                </div>

                <div className="bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 rounded-lg p-4 mt-6">
                  <p className="text-sm text-amber-900 dark:text-amber-100">
                    <strong>Important:</strong> Callto is not responsible for call disruptions, quality issues, or charges incurred due to inadequate network conditions, device issues, or service provider limitations on your end. Standard data charges from your telecom provider may apply.
                  </p>
                </div>
              </motion.section>

              {/* 9. Prohibited Conduct During Calls */}
              <motion.section
                variants={fadeInUp}
                className="bg-red-50 dark:bg-red-900/20 rounded-xl p-6 shadow-sm border border-red-200 dark:border-red-800"
              >
                <h2 className="text-2xl font-bold text-red-900 dark:text-red-100 mb-4">
                  9. Prohibited Conduct During Calls
                </h2>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
                  The following behaviors are strictly prohibited and may result in immediate account termination:
                </p>
                <div className="grid md:grid-cols-2 gap-4">
                  <ul className="space-y-3 text-gray-600 dark:text-gray-400">
                    <li className="flex items-start space-x-2">
                      <span className="text-red-500 font-bold">✗</span>
                      <span>Harassment, abuse, or threatening behavior toward listeners</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="text-red-500 font-bold">✗</span>
                      <span>Sharing sexually explicit or inappropriate content</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="text-red-500 font-bold">✗</span>
                      <span>Recording calls without explicit permission</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="text-red-500 font-bold">✗</span>
                      <span>Soliciting personal contact information</span>
                    </li>
                  </ul>
                  <ul className="space-y-3 text-gray-600 dark:text-gray-400">
                    <li className="flex items-start space-x-2">
                      <span className="text-red-500 font-bold">✗</span>
                      <span>Attempting to bypass payment systems</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="text-red-500 font-bold">✗</span>
                      <span>Impersonating others or providing false identity</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="text-red-500 font-bold">✗</span>
                      <span>Using the platform for illegal activities</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="text-red-500 font-bold">✗</span>
                      <span>Promoting hate speech, violence, or discrimination</span>
                    </li>
                  </ul>
                </div>
                <div className="bg-white dark:bg-gray-800 rounded-lg p-4 mt-4">
                  <p className="text-sm text-gray-700 dark:text-gray-300">
                    <strong>Consequences:</strong> Violations may result in immediate call disconnection, account suspension, wallet forfeiture, and reporting to law enforcement if criminal activity is suspected. No refunds will be issued for terminated accounts.
                  </p>
                </div>
              </motion.section>

              {/* 10. Listener Verification & Responsibilities */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  10. Listener Verification & Responsibilities
                </h2>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
                  Callto takes listener quality seriously. All listeners undergo a verification process:
                </p>
                <ul className="space-y-3 text-gray-600 dark:text-gray-400">
                  <li className="flex items-start space-x-2">
                    <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                    <span>Identity verification and background checks</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                    <span>Training on platform guidelines and ethics</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                    <span>Regular quality monitoring and feedback reviews</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                    <span>Compliance with professional conduct standards</span>
                  </li>
                </ul>
                <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4 mt-4">
                  <p className="text-sm text-blue-900 dark:text-blue-100">
                    <strong>Disclaimer:</strong> While we verify listeners, Callto is not responsible for the quality, accuracy, or outcome of advice provided. Listeners are independent contractors, not employees. Always use your judgment and seek professional help when needed.
                  </p>
                </div>
              </motion.section>

              {/* 11. Intellectual Property Rights */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  11. Intellectual Property Rights
                </h2>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-4">
                  All content, features, and functionality of Callto, including but not limited to:
                </p>
                <ul className="space-y-2 text-gray-600 dark:text-gray-400">
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                    <span>Software, code, and algorithms</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                    <span>Logos, trademarks, and branding</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                    <span>User interface, design, and graphics</span>
                  </li>
                  <li className="flex items-start space-x-2">
                    <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                    <span>Call routing and matching technology</span>
                  </li>
                </ul>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mt-4">
                  are owned by Callto and protected by Indian and international intellectual property laws. Unauthorized use, reproduction, or distribution is strictly prohibited.
                </p>
              </motion.section>

              {/* 12. Account Termination & Suspension */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  12. Account Termination & Suspension
                </h2>
                <div className="space-y-4 text-gray-600 dark:text-gray-400">
                  <p className="leading-relaxed font-semibold text-lg">Termination by Callto:</p>
                  <p className="leading-relaxed mb-4">
                    We reserve the right to suspend or terminate your account immediately, without prior notice, for:
                  </p>
                  <ul className="space-y-2 mb-6">
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-red-500 rounded-full mt-2"></span>
                      <span>Violation of these Terms of Service or applicable laws</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-red-500 rounded-full mt-2"></span>
                      <span>Fraudulent activity or payment disputes</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-red-500 rounded-full mt-2"></span>
                      <span>Multiple reports of harassment or abusive behavior</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-red-500 rounded-full mt-2"></span>
                      <span>Security breaches or unauthorized access attempts</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-red-500 rounded-full mt-2"></span>
                      <span>Inactivity for more than 12 consecutive months</span>
                    </li>
                  </ul>
                  <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4 mb-6">
                    <p className="text-sm text-yellow-900 dark:text-yellow-100">
                      <strong>Wallet Balance:</strong> Upon account termination for violations, any remaining wallet balance may be forfeited. For voluntary account closure, you may request a refund of your wallet balance within 30 days, subject to verification and a processing fee of 2%.
                    </p>
                  </div>
                  <p className="leading-relaxed font-semibold text-lg">Termination by User:</p>
                  <p className="leading-relaxed mb-4">
                    You may delete your account at any time through Settings → Account → Delete Account. Upon deletion:
                  </p>
                  <ul className="space-y-2">
                    <li className="flex items-start space-x-2">
                      <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                      <span>Your profile and personal information will be permanently removed</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                      <span>Call recordings will be deleted after 90 days (as per legal retention requirements)</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                      <span>Transaction history will be archived for accounting purposes (7 years as per Indian law)</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                      <span>You will receive a confirmation email with account deletion details</span>
                    </li>
                  </ul>
                </div>
              </motion.section>

              {/* 13. Limitation of Liability & Indemnification */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  13. Limitation of Liability & Indemnification
                </h2>
                <div className="space-y-4 text-gray-600 dark:text-gray-400">
                  <p className="leading-relaxed font-semibold">Limitation of Liability:</p>
                  <p className="leading-relaxed mb-4">
                    TO THE MAXIMUM EXTENT PERMITTED BY INDIAN LAW, CALLTO SHALL NOT BE LIABLE FOR:
                  </p>
                  <ul className="space-y-2 mb-6">
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Any indirect, incidental, special, consequential, or punitive damages</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Loss of profits, revenue, data, or business opportunities</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Content, quality, or actions of listeners during calls</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Technical failures, network issues, or service interruptions</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Unauthorized access or data breaches despite security measures</span>
                    </li>
                  </ul>
                  <p className="leading-relaxed mb-6">
                    Our total liability shall not exceed the amount you paid to Callto in the 12 months preceding the claim, or ₹5,000, whichever is less.
                  </p>
                  <p className="leading-relaxed font-semibold">Indemnification:</p>
                  <p className="leading-relaxed mb-4">
                    You agree to indemnify, defend, and hold harmless Callto and its officers, directors, employees, and agents from any claims, liabilities, damages, losses, and expenses arising from:
                  </p>
                  <ul className="space-y-2">
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Your violation of these Terms or applicable laws</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Your misuse of the platform or services</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Your interactions with listeners or other users</span>
                    </li>
                  </ul>
                </div>
              </motion.section>

              {/* 14. Contact & Support */}
              <motion.section
                variants={fadeInUp}
                className="bg-gradient-to-br from-pink-50 to-rose-50 dark:from-pink-900/20 dark:to-rose-900/20 rounded-xl p-6 shadow-sm border border-pink-200 dark:border-pink-800"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  14. Contact & Support
                </h2>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-6">
                  For questions, concerns, or issues regarding these Terms of Service or Callto services:
                </p>
                <div className="grid md:grid-cols-2 gap-4">
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-3">Legal Inquiries</h3>
                    <p className="text-sm text-gray-700 dark:text-gray-300">
                      <strong>Email:</strong> legal@callto.com<br />
                      <strong>Response Time:</strong> 3-5 business days<br />
                      <strong>Address:</strong> [Company Address], India
                    </p>
                  </div>
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-3">Customer Support</h3>
                    <p className="text-sm text-gray-700 dark:text-gray-300">
                      <strong>Email:</strong> support@callto.com<br />
                      <strong>In-App Chat:</strong> 24/7 availability<br />
                      <strong>Phone:</strong> [Support Number]
                    </p>
                  </div>
                </div>
                <div className="bg-blue-50 dark:bg-blue-900/30 border border-blue-200 dark:border-blue-800 rounded-lg p-4 mt-4">
                  <p className="text-sm text-blue-900 dark:text-blue-100">
                    <strong>Grievance Officer:</strong> As per Information Technology Act 2000 and Rules, contact details available at support@callto.com for grievance redressal.
                  </p>
                </div>
              </motion.section>

              {/* 15. Governing Law & Dispute Resolution */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  15. Governing Law & Dispute Resolution
                </h2>
                <div className="space-y-4 text-gray-600 dark:text-gray-400">
                  <p className="leading-relaxed font-semibold">Applicable Law:</p>
                  <p className="leading-relaxed mb-4">
                    These Terms of Service shall be governed by and construed in accordance with the laws of India, including but not limited to:
                  </p>
                  <ul className="space-y-2 mb-6">
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Indian Contract Act, 1872</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Information Technology Act, 2000 and Rules thereunder</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Consumer Protection Act, 2019</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <span className="w-2 h-2 bg-pink-500 rounded-full mt-2"></span>
                      <span>Payment and Settlement Systems Act, 2007</span>
                    </li>
                  </ul>
                  <p className="leading-relaxed font-semibold">Dispute Resolution:</p>
                  <div className="bg-gray-50 dark:bg-gray-700/50 rounded-lg p-4 space-y-3 mb-6">
                    <div>
                      <p className="font-semibold text-gray-900 dark:text-white">Step 1: Direct Resolution</p>
                      <p className="text-sm">Contact our support team at support@callto.com. We aim to resolve disputes within 15 business days.</p>
                    </div>
                    <div>
                      <p className="font-semibold text-gray-900 dark:text-white">Step 2: Mediation</p>
                      <p className="text-sm">If unresolved, disputes shall be submitted to mediation under the Commercial Courts Act, 2015.</p>
                    </div>
                    <div>
                      <p className="font-semibold text-gray-900 dark:text-white">Step 3: Arbitration</p>
                      <p className="text-sm">Unresolved disputes shall be referred to arbitration in accordance with the Arbitration and Conciliation Act, 1996. Arbitration shall be conducted in [City Name], India, in English language.</p>
                    </div>
                  </div>
                  <p className="leading-relaxed font-semibold">Jurisdiction:</p>
                  <p className="leading-relaxed">
                    Subject to arbitration, the courts at [City Name], India shall have exclusive jurisdiction over any disputes arising from or relating to these Terms of Service.
                  </p>
                </div>
              </motion.section>

              {/* 16. Changes to Terms of Service */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  16. Changes to Terms of Service
                </h2>
                <div className="space-y-4 text-gray-600 dark:text-gray-400">
                  <p className="leading-relaxed">
                    Callto reserves the right to modify these Terms of Service at any time. When we make material changes, we will:
                  </p>
                  <ul className="space-y-2 mb-6">
                    <li className="flex items-start space-x-2">
                      <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                      <span>Notify you via email and in-app notification</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                      <span>Update the "Last Updated" date at the top of this page</span>
                    </li>
                    <li className="flex items-start space-x-2">
                      <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                      <span>Provide 30 days notice before changes take effect</span>
                    </li>
                  </ul>
                  <div className="bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 rounded-lg p-4">
                    <p className="text-sm text-amber-900 dark:text-amber-100">
                      <strong>Important:</strong> Continued use of Callto services after changes take effect constitutes acceptance of the revised Terms. If you disagree with changes, you must stop using the services and may close your account.
                    </p>
                  </div>
                </div>
              </motion.section>

              {/* 17. Severability & Entire Agreement */}
              <motion.section
                variants={fadeInUp}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  17. Severability & Entire Agreement
                </h2>
                <div className="space-y-4 text-gray-600 dark:text-gray-400">
                  <div>
                    <p className="leading-relaxed font-semibold">Severability:</p>
                    <p className="leading-relaxed">
                      If any provision of these Terms is found to be unenforceable or invalid under Indian law, such provision shall be modified to reflect the parties' intention or eliminated to the minimum extent necessary so that the remaining Terms remain in full force and effect.
                    </p>
                  </div>
                  <div>
                    <p className="leading-relaxed font-semibold">Entire Agreement:</p>
                    <p className="leading-relaxed">
                      These Terms of Service, together with our Privacy Policy and any other legal notices published on Callto, constitute the entire agreement between you and Callto regarding your use of the services.
                    </p>
                  </div>
                  <div>
                    <p className="leading-relaxed font-semibold">No Waiver:</p>
                    <p className="leading-relaxed">
                      Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights. Any waiver must be in writing and signed by authorized representatives of Callto.
                    </p>
                  </div>
                </div>
              </motion.section>

              {/* Thank You for Reading */}
              <motion.section
                variants={fadeInUp}
                className="bg-gradient-to-r from-pink-500 to-rose-500 rounded-xl p-8 shadow-lg text-white text-center"
              >
                <CheckCircle className="w-16 h-16 mx-auto mb-4" />
                <h2 className="text-2xl font-bold mb-3">
                  Thank You for Reading
                </h2>
                <p className="text-pink-100 leading-relaxed max-w-2xl mx-auto">
                  By using Callto, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service. We're committed to providing a safe, secure, and supportive platform for meaningful conversations.
                </p>
                <div className="mt-6 text-sm text-pink-100">
                  <p>These Terms are effective as of January 1, 2025</p>
                  <p className="mt-2">Version 2.0 - India</p>
                </div>
              </motion.section>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default TermsOfService;
