import React from 'react';
import { motion } from 'framer-motion';
import { useNavigate, Link } from 'react-router-dom';
import { 
  Phone, Shield, Users, Lock, ArrowRight, CheckCircle2, 
  UserCheck, MessageCircle, Sparkles, Clock, Shuffle, Headphones, Heart
} from 'lucide-react';
import PublicNavbar from '../components/PublicNavbar';

const LandingPage = () => {
  const navigate = useNavigate();

  // Animation variants
  const fadeInUp = {
    hidden: { opacity: 0, y: 60 },
    visible: { opacity: 1, y: 0 }
  };

  const staggerContainer = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2
      }
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <PublicNavbar />

      {/* Hero Section */}
      <section id="home" className="relative pt-32 pb-20 px-4 overflow-hidden">
        {/* Animated Background */}
        <div className="absolute inset-0 bg-gradient-to-br from-pink-50 via-rose-50 to-pink-100 dark:from-pink-950 dark:via-rose-950 dark:to-pink-950">
          <motion.div
            animate={{
              scale: [1, 1.2, 1],
              rotate: [0, 90, 0],
            }}
            transition={{
              duration: 20,
              repeat: Infinity,
              repeatType: 'reverse'
            }}
            className="absolute top-20 left-20 w-72 h-72 bg-pink-200/30 dark:bg-pink-700/30 rounded-full blur-3xl"
          />
          <motion.div
            animate={{
              scale: [1, 1.3, 1],
              rotate: [0, -90, 0],
            }}
            transition={{
              duration: 25,
              repeat: Infinity,
              repeatType: 'reverse'
            }}
            className="absolute bottom-20 right-20 w-96 h-96 bg-rose-200/30 dark:bg-rose-700/30 rounded-full blur-3xl"
          />
        </div>

        {/* Hero Content */}
        <div className="relative max-w-7xl mx-auto">
          <motion.div
            initial="hidden"
            animate="visible"
            variants={staggerContainer}
            className="text-center max-w-4xl mx-auto"
          >
            <motion.div
              variants={fadeInUp}
              className="inline-flex items-center space-x-2 bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm px-4 py-2 rounded-full mb-6 shadow-md"
            >
              <Sparkles className="w-4 h-4 text-pink-600" />
              <span className="text-sm font-semibold text-gray-700 dark:text-gray-300">
                Talk to Someone Who Understands
              </span>
            </motion.div>

            <motion.h1
              variants={fadeInUp}
              className="text-5xl sm:text-6xl lg:text-7xl font-bold mb-6"
            >
              <span className="bg-gradient-to-r from-pink-500 via-rose-500 to-pink-600 bg-clip-text text-transparent">
                Callto
              </span>
              <br />
              <span className="text-gray-900 dark:text-white">
                Connect & Talk
              </span>
            </motion.h1>

            <motion.p
              variants={fadeInUp}
              className="text-xl text-gray-600 dark:text-gray-300 mb-10 max-w-2xl mx-auto"
            >
              Connect with expert listeners who can help you with life challenges, 
              career advice, relationships, and more. Your conversation, your choice.
            </motion.p>

            <motion.div
              variants={fadeInUp}
              className="flex flex-col sm:flex-row items-center justify-center gap-4"
            >
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="bg-gradient-to-r from-pink-500 to-rose-500 text-white px-8 py-4 rounded-xl font-semibold text-lg shadow-lg hover:shadow-xl transition-all flex items-center space-x-2 group"
              >
                <span>Start Talking Now</span>
                <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
              </motion.button>
              
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => document.getElementById('features')?.scrollIntoView({ behavior: 'smooth' })}
                className="bg-white dark:bg-gray-800 text-gray-900 dark:text-white px-8 py-4 rounded-xl font-semibold text-lg shadow-lg hover:shadow-xl transition-all border-2 border-gray-200 dark:border-gray-700"
              >
                Learn More
              </motion.button>
            </motion.div>

            {/* Stats */}
            <motion.div
              variants={fadeInUp}
              className="grid grid-cols-3 gap-8 mt-16 max-w-2xl mx-auto"
            >
              {[
                { value: '50K+', label: 'Happy Users' },
                { value: '100K+', label: 'Calls Made' },
                { value: '98%', label: 'Satisfaction Rate' }
              ].map((stat, index) => (
                <div key={index} className="text-center">
                  <div className="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-pink-500 to-rose-500 bg-clip-text text-transparent">
                    {stat.value}
                  </div>
                  <div className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                    {stat.label}
                  </div>
                </div>
              ))}
            </motion.div>
          </motion.div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 px-4 bg-white dark:bg-gray-800">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={staggerContainer}
            className="text-center mb-16"
          >
            <motion.h2
              variants={fadeInUp}
              className="text-4xl sm:text-5xl font-bold text-gray-900 dark:text-white mb-4"
            >
              Why Choose Callto?
            </motion.h2>
            <motion.p
              variants={fadeInUp}
              className="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto"
            >
              Experience meaningful conversations with verified experts
            </motion.p>
          </motion.div>

          <motion.div
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={staggerContainer}
            className="grid md:grid-cols-2 lg:grid-cols-4 gap-8"
          >
            {[
              {
                icon: Headphones,
                title: 'Expert Listeners',
                description: 'Talk to verified experts in life coaching, career advice, relationships & more',
                color: 'from-pink-500 to-rose-500'
              },
              {
                icon: Phone,
                title: 'Voice & Chat',
                description: 'Connect through voice calls or text chat - your choice, your comfort',
                color: 'from-pink-400 to-pink-600'
              },
              {
                icon: Lock,
                title: 'Private & Secure',
                description: 'Your conversations are completely private and confidential',
                color: 'from-rose-400 to-pink-500'
              },
              {
                icon: Shuffle,
                title: 'Random Connect',
                description: 'Try our random call feature to connect with available listeners instantly',
                color: 'from-pink-500 to-red-400'
              }
            ].map((feature, index) => (
              <motion.div
                key={index}
                variants={fadeInUp}
                whileHover={{ y: -10 }}
                className="bg-gray-50 dark:bg-gray-900 p-8 rounded-2xl shadow-lg hover:shadow-xl transition-all group"
              >
                <div className={`bg-gradient-to-r ${feature.color} w-16 h-16 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform`}>
                  <feature.icon className="w-8 h-8 text-white" />
                </div>
                <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-3">
                  {feature.title}
                </h3>
                <p className="text-gray-600 dark:text-gray-400">
                  {feature.description}
                </p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* How It Works Section */}
      <section id="how-it-works" className="py-20 px-4 bg-gray-50 dark:bg-gray-900">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={staggerContainer}
            className="text-center mb-20"
          >
            <motion.div 
              variants={fadeInUp}
              className="inline-block mb-4"
            >
              <span className="text-sm font-semibold text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-900/30 px-4 py-2 rounded-full uppercase tracking-wider">
                Simple & Effective
              </span>
            </motion.div>
            <motion.h2
              variants={fadeInUp}
              className="text-5xl sm:text-6xl font-extrabold text-gray-900 dark:text-white mb-6 leading-tight"
            >
              How <span className="bg-gradient-to-r from-pink-500 to-indigo-600 bg-clip-text text-transparent">Callto</span> Works
            </motion.h2>
            <motion.p
              variants={fadeInUp}
              className="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto leading-relaxed"
            >
              Get connected with verified expert listeners in just <span className="font-semibold text-gray-900 dark:text-white">three simple steps</span>
            </motion.p>
          </motion.div>

          <motion.div
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={staggerContainer}
            className="grid md:grid-cols-3 gap-12 lg:gap-16 relative"
          >
            {/* Connecting Line with Arrow (Desktop) */}
            <div className="hidden md:block absolute top-32 left-[16.666%] right-[16.666%] h-0.5 bg-gradient-to-r from-pink-400 via-purple-400 to-indigo-400 transform -translate-y-1/2">
              <div className="absolute right-0 top-1/2 transform translate-x-1 -translate-y-1/2 w-0 h-0 border-l-8 border-l-indigo-400 border-t-4 border-t-transparent border-b-4 border-b-transparent" />
            </div>

            {[
              {
                step: 1,
                icon: UserCheck,
                title: 'Create Your Account',
                description: 'Sign up with Google or Facebook and complete your profile with your interests and preferences',
                details: ['Quick 2-minute setup', 'Secure authentication', 'Personalized profile']
              },
              {
                step: 2,
                icon: Headphones,
                title: 'Choose Your Listener',
                description: 'Browse expert listeners by topics like Confidence, Marriage, Relationships, or try our random call feature',
                details: ['100+ verified listeners', 'Filter by expertise', 'View ratings & reviews']
              },
              {
                step: 3,
                icon: Phone,
                title: 'Connect & Talk',
                description: 'Start a voice call or text chat with your chosen listener. Pay per minute for personalized support',
                details: ['Voice or text chat', 'Flexible pricing', 'Complete privacy']
              }
            ].map((step, index) => (
              <motion.div
                key={index}
                variants={fadeInUp}
                className="relative group"
              >
                <div className="bg-white dark:bg-gray-800 p-10 rounded-3xl shadow-xl hover:shadow-2xl transition-all duration-300 relative z-10 border border-gray-100 dark:border-gray-700 hover:border-indigo-200 dark:hover:border-indigo-700 h-full">
                  {/* Step Number Badge */}
                  <div className="absolute -top-8 left-1/2 transform -translate-x-1/2">
                    <div className="relative">
                      <div className="bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-600 w-16 h-16 rounded-full flex items-center justify-center text-white font-bold text-2xl shadow-2xl group-hover:scale-110 transition-transform duration-300">
                        {step.step}
                      </div>
                      <div className="absolute inset-0 bg-gradient-to-br from-indigo-400 to-pink-400 rounded-full blur-md opacity-50 group-hover:opacity-75 transition-opacity" />
                    </div>
                  </div>

                  <div className="mt-12 text-center">
                    {/* Icon Container */}
                    <div className="inline-flex items-center justify-center w-24 h-24 bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50 dark:from-indigo-900/40 dark:via-purple-900/40 dark:to-pink-900/40 rounded-3xl mb-6 group-hover:scale-105 transition-transform duration-300 shadow-inner">
                      <step.icon className="w-12 h-12 text-indigo-600 dark:text-indigo-400 group-hover:text-purple-600 dark:group-hover:text-purple-400 transition-colors duration-300" strokeWidth={2} />
                    </div>
                    
                    {/* Title */}
                    <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-4 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors duration-300">
                      {step.title}
                    </h3>
                    
                    {/* Description */}
                    <p className="text-gray-600 dark:text-gray-400 leading-relaxed mb-6 text-base">
                      {step.description}
                    </p>

                    {/* Details List */}
                    <div className="space-y-3 pt-4 border-t border-gray-100 dark:border-gray-700">
                      {step.details.map((detail, idx) => (
                        <div key={idx} className="flex items-center justify-center text-sm text-gray-700 dark:text-gray-300">
                          <svg className="w-5 h-5 text-green-500 mr-2 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
                          </svg>
                          <span className="font-medium">{detail}</span>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Decorative Corner Element */}
                  <div className="absolute top-4 right-4 w-8 h-8 border-t-2 border-r-2 border-indigo-200 dark:border-indigo-700 rounded-tr-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                  <div className="absolute bottom-4 left-4 w-8 h-8 border-b-2 border-l-2 border-pink-200 dark:border-pink-700 rounded-bl-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                </div>
              </motion.div>
            ))}
          </motion.div>

          {/* Additional Trust Section */}
          <motion.div
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={fadeInUp}
            className="mt-20 text-center"
          >
            <div className="inline-flex items-center justify-center space-x-8 bg-gradient-to-r from-indigo-50 to-purple-50 dark:from-gray-800 dark:to-gray-700 px-8 py-6 rounded-2xl shadow-lg">
              <div className="text-center">
                <div className="text-3xl font-bold text-indigo-600 dark:text-indigo-400">2 min</div>
                <div className="text-sm text-gray-600 dark:text-gray-400 mt-1">Average Setup</div>
              </div>
              <div className="w-px h-12 bg-gray-300 dark:bg-gray-600" />
              <div className="text-center">
                <div className="text-3xl font-bold text-purple-600 dark:text-purple-400">100%</div>
                <div className="text-sm text-gray-600 dark:text-gray-400 mt-1">Confidential</div>
              </div>
              <div className="w-px h-12 bg-gray-300 dark:bg-gray-600" />
              <div className="text-center">
                <div className="text-3xl font-bold text-pink-600 dark:text-pink-400">24/7</div>
                <div className="text-sm text-gray-600 dark:text-gray-400 mt-1">Available</div>
              </div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* About Section */}
      <section id="about" className="py-20 px-4 bg-white dark:bg-gray-800">
        <div className="max-w-4xl mx-auto">
          <motion.div
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={staggerContainer}
            className="text-center mb-16"
          >
            <motion.h2
              variants={fadeInUp}
              className="text-4xl sm:text-5xl font-bold text-gray-900 dark:text-white mb-4"
            >
              About Callto
            </motion.h2>
            <motion.p
              variants={fadeInUp}
              className="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto"
            >
              Connecting people with expert listeners for meaningful conversations
            </motion.p>
          </motion.div>

          <motion.div
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={staggerContainer}
            className="grid md:grid-cols-2 gap-12 items-center"
          >
            <motion.div variants={fadeInUp}>
              <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">
                Our Mission
              </h3>
              <p className="text-gray-600 dark:text-gray-400 mb-6 leading-relaxed">
                Callto is a revolutionary platform that connects individuals with expert listeners who provide personalized support through voice calls and text chats. Whether you're seeking advice on relationships, career guidance, personal development, or just need someone to listen, our verified experts are here to help.
              </p>
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                We believe that everyone deserves access to meaningful conversations and professional guidance. Our platform makes it easy to find the right listener for your needs, with transparent pricing and a focus on quality connections.
              </p>
            </motion.div>

            <motion.div variants={fadeInUp} className="space-y-6">
              <div className="bg-gradient-to-r from-pink-50 to-rose-50 dark:from-pink-900/20 dark:to-rose-900/20 p-6 rounded-2xl">
                <div className="flex items-center space-x-4">
                  <div className="bg-gradient-to-r from-pink-500 to-rose-500 w-12 h-12 rounded-xl flex items-center justify-center">
                    <Users className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h4 className="font-bold text-gray-900 dark:text-white">Expert Community</h4>
                    <p className="text-gray-600 dark:text-gray-400">Verified listeners across multiple specialties</p>
                  </div>
                </div>
              </div>

              <div className="bg-gradient-to-r from-pink-50 to-rose-50 dark:from-pink-900/20 dark:to-rose-900/20 p-6 rounded-2xl">
                <div className="flex items-center space-x-4">
                  <div className="bg-gradient-to-r from-pink-500 to-rose-500 w-12 h-12 rounded-xl flex items-center justify-center">
                    <Shield className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h4 className="font-bold text-gray-900 dark:text-white">Safe & Private</h4>
                    <p className="text-gray-600 dark:text-gray-400">Your conversations are completely confidential</p>
                  </div>
                </div>
              </div>

              <div className="bg-gradient-to-r from-pink-50 to-rose-50 dark:from-pink-900/20 dark:to-rose-900/20 p-6 rounded-2xl">
                <div className="flex items-center space-x-4">
                  <div className="bg-gradient-to-r from-pink-500 to-rose-500 w-12 h-12 rounded-xl flex items-center justify-center">
                    <Heart className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h4 className="font-bold text-gray-900 dark:text-white">Meaningful Connections</h4>
                    <p className="text-gray-600 dark:text-gray-400">Building real relationships through authentic conversations</p>
                  </div>
                </div>
              </div>
            </motion.div>
          </motion.div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-4 bg-gradient-to-r from-pink-500 to-rose-500">
        <div className="max-w-4xl mx-auto text-center">
          <motion.div
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={staggerContainer}
          >
            <motion.h2
              variants={fadeInUp}
              className="text-4xl sm:text-5xl font-bold text-white mb-6"
            >
              Ready to Connect with Expert Listeners?
            </motion.h2>
            <motion.p
              variants={fadeInUp}
              className="text-xl text-pink-100 mb-10"
            >
              Join thousands of people who have already found meaningful conversations on Callto
            </motion.p>
            <motion.div
              variants={fadeInUp}
              className="flex flex-col sm:flex-row items-center justify-center gap-4"
            >
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="bg-white text-pink-600 px-8 py-4 rounded-xl font-semibold text-lg shadow-lg hover:shadow-xl transition-all flex items-center space-x-2"
              >
                <span>Start Your Journey</span>
                <ArrowRight className="w-5 h-5" />
              </motion.button>
            </motion.div>

            {/* Trust Badges */}
            <motion.div
              variants={fadeInUp}
              className="mt-16 flex flex-wrap items-center justify-center gap-8 text-white/80"
            >
              {[
                'SSL Secured',
                'GDPR Compliant',
                'Verified Listeners',
                '24/7 Support'
              ].map((badge, index) => (
                <div key={index} className="flex items-center space-x-2">
                  <CheckCircle2 className="w-5 h-5" />
                  <span className="text-sm font-medium">{badge}</span>
                </div>
              ))}
            </motion.div>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-400 py-8 px-4">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col items-center space-y-4">
            {/* Logo */}
            <div className="flex items-center space-x-2">
              <div className="bg-gradient-to-r from-pink-500 to-rose-500 p-2 rounded-lg">
                <Phone className="w-5 h-5 text-white" />
              </div>
              <span className="text-xl font-bold text-white">Callto</span>
            </div>
            
            {/* Links */}
            <div className="flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-sm">
              <Link to="/privacy-policy" className="hover:text-white transition-colors">
                Privacy Policy
              </Link>
              <span className="text-gray-600">•</span>
              <Link to="/terms-of-service" className="hover:text-white transition-colors">
                Terms of Service
              </Link>
              <span className="text-gray-600">•</span>
              <Link to="/cookie-policy" className="hover:text-white transition-colors">
                Cookie Policy
              </Link>
            </div>
            
            {/* Copyright */}
            <p className="text-sm text-gray-500">
              © 2026 Callto. All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;
