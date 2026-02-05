import React, { useState } from 'react';
import { Bell, Calendar, Clock, Send, Smartphone, Users, Headphones, Sparkles } from 'lucide-react';
/* eslint-disable no-unused-vars */
import { motion, AnimatePresence } from 'framer-motion';

const NotificationPanel = ({
  title,
  targetLabel,
  scheduleEnabled,
  onScheduleToggle,
  repeatValue,
  onRepeatChange,
  Icon,
  accentColor = "pink"
}) => {
  const lowerTarget = targetLabel.toLowerCase();
  
  const colorMap = {
    pink: {
      bg: "bg-pink-50 dark:bg-pink-900/10",
      border: "border-pink-100 dark:border-pink-900/20",
      text: "text-pink-600 dark:text-pink-400",
      button: "bg-pink-600 hover:bg-pink-700 shadow-pink-200 dark:shadow-none",
      iconBg: "bg-pink-100 dark:bg-pink-900/30",
      focus: "focus:ring-pink-500"
    },
    purple: {
      bg: "bg-purple-50 dark:bg-purple-900/10",
      border: "border-purple-100 dark:border-purple-900/20",
      text: "text-purple-600 dark:text-purple-400",
      button: "bg-purple-600 hover:bg-purple-700 shadow-purple-200 dark:shadow-none",
      iconBg: "bg-purple-100 dark:bg-purple-900/30",
      focus: "focus:ring-purple-500"
    }
  };

  const colors = colorMap[accentColor];

  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="space-y-6"
    >
      <div className="bg-white dark:bg-gray-800 rounded-2xl border border-gray-100 dark:border-gray-700 shadow-xl shadow-gray-200/50 dark:shadow-none p-8 transition-all hover:shadow-2xl hover:shadow-gray-300/50 dark:hover:shadow-none">
        <div className="flex items-start justify-between gap-4">
          <div className="flex gap-4">
            <div className={`w-14 h-14 rounded-2xl ${colors.iconBg} flex items-center justify-center shadow-inner`}>
              <Icon className={`w-7 h-7 ${colors.text}`} strokeWidth={2.5} />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white tracking-tight">{title}</h2>
              <p className="text-sm font-medium text-gray-500 dark:text-gray-400 mt-1 flex items-center gap-1">
                <Smartphone className="w-3.5 h-3.5" />
                Mobile app push notifications
              </p>
            </div>
          </div>
          <div className="flex items-center gap-1 text-[10px] font-bold uppercase tracking-widest text-gray-400 bg-gray-50 dark:bg-gray-900/50 px-2 py-1 rounded-md border border-gray-100 dark:border-gray-800">
            <Sparkles className="w-3 h-3" />
            Active
          </div>
        </div>

        <div className="mt-8 space-y-6">
          <div className="group">
            <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 ml-1 group-focus-within:text-pink-500 transition-colors">
              Notification Title
            </label>
            <input
              type="text"
              placeholder={`e.g. Welcome to CallTo!`}
              className={`w-full px-5 py-3.5 border border-gray-200 dark:border-gray-700 rounded-xl bg-gray-50/50 dark:bg-gray-900 text-gray-900 dark:text-white ${colors.focus} focus:ring-2 focus:border-transparent transition-all placeholder:text-gray-400`}
            />
          </div>

          <div className="group">
            <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 ml-1 group-focus-within:text-pink-500 transition-colors">
              Message Content
            </label>
            <textarea
              rows={4}
              placeholder={`Write a friendly message for your ${lowerTarget}s...`}
              className={`w-full px-5 py-3.5 border border-gray-200 dark:border-gray-700 rounded-xl bg-gray-50/50 dark:bg-gray-900 text-gray-900 dark:text-white ${colors.focus} focus:ring-2 focus:border-transparent transition-all placeholder:text-gray-400 resize-none`}
            />
          </div>

          <div className={`flex items-center justify-between gap-4 p-5 rounded-2xl ${colors.bg} border ${colors.border} transition-colors`}>
            <div className="flex gap-3 items-center">
              <div className={`p-2 rounded-lg bg-white dark:bg-gray-800 shadow-sm ${colors.text}`}>
                <Calendar className="w-5 h-5" />
              </div>
              <div>
                <p className="text-sm font-bold text-gray-800 dark:text-gray-200">Schedule Delivery</p>
                <p className="text-xs font-medium text-gray-500 dark:text-gray-400 mt-0.5">
                  Send later or set recurring alerts
                </p>
              </div>
            </div>
            <label className="inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                className="sr-only peer"
                checked={scheduleEnabled}
                onChange={(event) => onScheduleToggle(event.target.checked)}
              />
              <div className={`w-14 h-7 bg-gray-300 peer-focus:outline-none rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-7 after:content-[''] after:absolute after:top-[4px] after:left-[4px] after:bg-white after:rounded-full after:h-[20px] after:w-[20px] after:transition-all peer-checked:bg-gradient-to-r from-pink-500 to-rose-500 relative shadow-inner`} />
            </label>
          </div>

          <AnimatePresence>
            {scheduleEnabled && (
              <motion.div 
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                className="overflow-hidden"
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-5 pt-2">
                  <div className="group">
                    <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 ml-1">
                      Target Date
                    </label>
                    <div className="relative">
                      <Calendar className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 group-focus-within:text-pink-500 transition-colors" />
                      <input
                        type="date"
                        className={`w-full pl-12 pr-5 py-3.5 border border-gray-200 dark:border-gray-700 rounded-xl bg-gray-50/50 dark:bg-gray-900 text-gray-900 dark:text-white ${colors.focus} focus:ring-2 focus:border-transparent transition-all`}
                      />
                    </div>
                  </div>

                  <div className="group">
                    <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 ml-1">
                      Delivery Time
                    </label>
                    <div className="relative">
                      <Clock className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 group-focus-within:text-pink-500 transition-colors" />
                      <input
                        type="time"
                        className={`w-full pl-12 pr-5 py-3.5 border border-gray-200 dark:border-gray-700 rounded-xl bg-gray-50/50 dark:bg-gray-900 text-gray-900 dark:text-white ${colors.focus} focus:ring-2 focus:border-transparent transition-all`}
                      />
                    </div>
                  </div>

                  <div className="sm:col-span-2">
                    <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-3 ml-1">
                      Repeat Settings
                    </label>
                    <div className="flex flex-wrap gap-3">
                      {['daily', 'weekly'].map((option) => (
                        <label
                          key={option}
                          className={`flex items-center gap-3 px-6 py-3 rounded-xl border-2 text-sm font-bold cursor-pointer transition-all duration-300 ${
                            repeatValue === option
                              ? 'bg-pink-50 border-pink-500 text-pink-700 dark:bg-pink-900/30 dark:border-pink-400 dark:text-pink-200 shadow-lg shadow-pink-100 dark:shadow-none scale-[1.02]'
                              : 'border-gray-100 text-gray-500 dark:border-gray-700 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800 hover:border-gray-200'
                          }`}
                        >
                          <input
                            type="radio"
                            name={`${lowerTarget}-repeat`}
                            value={option}
                            checked={repeatValue === option}
                            onChange={(event) => onRepeatChange(event.target.value)}
                            className="hidden"
                          />
                          <div className={`w-4 h-4 rounded-full border-2 flex items-center justify-center ${repeatValue === option ? 'border-pink-500' : 'border-gray-300'}`}>
                            {repeatValue === option && <div className="w-2 h-2 rounded-full bg-pink-500" />}
                          </div>
                          {option.charAt(0).toUpperCase() + option.slice(1)}
                        </label>
                      ))}
                    </div>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          <div className="pt-4">
            <motion.button 
              whileHover={{ scale: 1.01 }}
              whileTap={{ scale: 0.98 }}
              className={`w-full flex items-center justify-center gap-2 py-4 rounded-2xl ${colors.button} text-white font-bold text-lg transition-all shadow-xl shadow-pink-200/50 dark:shadow-none hover:shadow-2xl`}
            >
              <Send className="w-5 h-5" />
              Push to {targetLabel}s
            </motion.button>
          </div>
        </div>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-2xl border border-gray-100 dark:border-gray-700 shadow-xl shadow-gray-200/50 dark:shadow-none p-8 overflow-hidden relative">
        <div className="absolute top-0 right-0 p-4 opacity-5">
           <Bell className="w-32 h-32 rotate-12" />
        </div>
        <div className="flex items-center justify-between relative z-10">
          <div>
            <h3 className="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2">
              <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
              Live Feed
            </h3>
            <p className="text-xs font-medium text-gray-500 dark:text-gray-400 mt-0.5">
              Recent activity for {lowerTarget} notifications
            </p>
          </div>
          <div className="flex items-center gap-1 text-[9px] font-black uppercase tracking-tighter text-blue-500 bg-blue-50 dark:bg-blue-900/20 px-2 py-1 rounded border border-blue-100 dark:border-blue-800">
            Preview Mode
          </div>
        </div>

        <div className="mt-6 space-y-4 relative z-10">
          <div className="flex items-center gap-4 p-4 rounded-xl border border-dashed border-gray-200 dark:border-gray-700 bg-gray-50/50 dark:bg-gray-900/40">
            <div className="w-10 h-10 rounded-full bg-white dark:bg-gray-800 flex items-center justify-center shadow-sm border border-gray-100 dark:border-gray-700">
              <Bell className="w-5 h-5 text-gray-300" />
            </div>
            <div>
              <p className="text-sm font-bold text-gray-700 dark:text-gray-200">Listening for updates...</p>
              <p className="text-xs font-medium text-gray-500 dark:text-gray-400">
                Real-time delivery status will appear here.
              </p>
            </div>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {['Scheduled for 2,400+ users', 'Delivered to active listeners'].map((text, idx) => (
              <div
                key={text}
                className={`p-4 rounded-xl ${idx === 0 ? 'bg-amber-50 text-amber-700 border border-amber-100' : 'bg-emerald-50 text-emerald-700 border border-emerald-100'} dark:bg-gray-700/50 dark:text-gray-300 dark:border-gray-700 text-[11px] font-bold flex items-center gap-2`}
              >
                <div className={`w-1.5 h-1.5 rounded-full ${idx === 0 ? 'bg-amber-500' : 'bg-emerald-500'}`} />
                {text}
              </div>
            ))}
          </div>
        </div>
      </div>
    </motion.div>
  );
};

const SendNotification = () => {
  const [userScheduleEnabled, setUserScheduleEnabled] = useState(false);
  const [listenerScheduleEnabled, setListenerScheduleEnabled] = useState(false);
  const [userRepeat, setUserRepeat] = useState('daily');
  const [listenerRepeat, setListenerRepeat] = useState('daily');

  return (
    <div className="min-h-screen bg-[#FDF2F8] dark:bg-gray-950 p-4 lg:p-8">
      <div className="max-w-7xl mx-auto">
        <div className="relative mb-12 overflow-hidden rounded-3xl bg-gradient-to-r from-pink-500 via-rose-500 to-purple-600 p-8 lg:p-12 shadow-2xl shadow-pink-200 dark:shadow-none">
          <div className="absolute top-0 right-0 -mt-10 -mr-10 opacity-10">
            <Bell className="w-64 h-64 text-white rotate-12" />
          </div>
          <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
            <div>
              <motion.div 
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/20 backdrop-blur-md text-white text-xs font-bold uppercase tracking-widest mb-4"
              >
                <Sparkles className="w-3.5 h-3.5" />
                Notification Center
              </motion.div>
              <motion.h1 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-4xl lg:text-5xl font-black text-white tracking-tight"
              >
                Reach Your Community
              </motion.h1>
              <motion.p 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
                className="text-pink-100 text-lg font-medium mt-3 max-w-xl"
              >
                Send instant push notifications and keep your users and listeners engaged with the latest updates.
              </motion.p>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12">
          <NotificationPanel
            title="User Community"
            targetLabel="User"
            Icon={Users}
            scheduleEnabled={userScheduleEnabled}
            onScheduleToggle={setUserScheduleEnabled}
            repeatValue={userRepeat}
            onRepeatChange={setUserRepeat}
            accentColor="pink"
          />
          <NotificationPanel
            title="Expert Listeners"
            targetLabel="Listener"
            Icon={Headphones}
            scheduleEnabled={listenerScheduleEnabled}
            onScheduleToggle={setListenerScheduleEnabled}
            repeatValue={listenerRepeat}
            onRepeatChange={setListenerRepeat}
            accentColor="purple"
          />
        </div>
      </div>
    </div>
  );
};

export default SendNotification;
