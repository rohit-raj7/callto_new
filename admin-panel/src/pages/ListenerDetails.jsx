import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getListenerById } from '../services/api';
import {
  ArrowLeft, Copy, Check, Mail, Phone, MapPin, Calendar,
  Star, TrendingUp, Clock, DollarSign, Headphones, Award,
  Shield, Building2, CreditCard, User, Briefcase, GraduationCap,
  Languages, Heart, Activity, Eye, EyeOff, MessageSquare
} from 'lucide-react';

const ListenerDetails = () => {
  const { listener_id } = useParams();
  const navigate = useNavigate();
  const [listener, setListener] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [copiedField, setCopiedField] = useState(null);

  useEffect(() => {
    const fetchListener = async () => {
      try {
        const res = await getListenerById(listener_id);
        setListener(res.data.listener);
      } catch (error) {
        setError('Failed to fetch listener details');
        console.error('Error fetching listener:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchListener();
  }, [listener_id]);

  const handleCopyToClipboard = async (value, fieldName) => {
    try {
      await navigator.clipboard.writeText(value);
      setCopiedField(fieldName);
      setTimeout(() => setCopiedField(null), 2000); // Reset after 2 seconds
    } catch (error) {
      console.error('Failed to copy to clipboard:', error);
    }
  };

  const maskValue = (value, visibleChars = 4) => {
    if (!value || value.length <= visibleChars) return value;
    return '*'.repeat(value.length - visibleChars) + value.slice(-visibleChars);
  };

  const InfoItem = ({ icon: Icon, label, value, copyable = false, masked = false, fieldKey = '' }) => {
    const displayValue = masked && value ? maskValue(value) : value;
    const actualValue = value || 'N/A';
    
    return (
      <div className="group">
        <div className="flex items-center gap-2 text-xs text-gray-500 dark:text-gray-400 mb-1">
          {Icon && <Icon className="w-3.5 h-3.5" />}
          <span className="font-medium uppercase tracking-wide">{label}</span>
        </div>
        {copyable && value ? (
          <button
            onClick={() => handleCopyToClipboard(actualValue, fieldKey)}
            className="flex items-center gap-2 w-full text-left px-3 py-2 rounded-lg bg-gray-50 dark:bg-gray-800 hover:bg-indigo-50 dark:hover:bg-indigo-900/20 border border-gray-200 dark:border-gray-700 transition-all group-hover:border-indigo-300 dark:group-hover:border-indigo-700"
            title="Click to copy"
          >
            <span className="flex-1 text-sm font-medium text-gray-900 dark:text-white font-mono truncate">
              {displayValue}
            </span>
            {copiedField === fieldKey ? (
              <Check className="w-4 h-4 text-green-500 flex-shrink-0" />
            ) : (
              <Copy className="w-4 h-4 text-gray-400 group-hover:text-indigo-500 flex-shrink-0" />
            )}
          </button>
        ) : (
          <p className="text-sm font-medium text-gray-900 dark:text-white px-3 py-2">
            {displayValue || 'N/A'}
          </p>
        )}
      </div>
    );
  };

  const StatCard = ({ icon: Icon, label, value, color = 'indigo', trend }) => (
    <div className={`bg-gradient-to-br from-${color}-500 to-${color}-600 rounded-xl p-6 text-white shadow-lg hover:shadow-xl transition-all`}>
      <div className="flex items-center justify-between mb-3">
        <div className="p-3 bg-white/20 rounded-lg">
          <Icon className="w-6 h-6" />
        </div>
        {trend && (
          <div className="flex items-center gap-1 text-xs bg-white/20 px-2 py-1 rounded-full">
            <TrendingUp className="w-3 h-3" />
            {trend}
          </div>
        )}
      </div>
      <div className="text-3xl font-bold mb-1">{value}</div>
      <div className="text-sm opacity-90">{label}</div>
    </div>
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-50 dark:bg-gray-900">
        <div className="text-center">
          <div className="relative w-16 h-16 mx-auto mb-4">
            <div className="absolute inset-0 border-4 border-indigo-200 dark:border-indigo-800 rounded-full"></div>
            <div className="absolute inset-0 border-4 border-indigo-600 rounded-full border-t-transparent animate-spin"></div>
          </div>
          <p className="text-gray-600 dark:text-gray-400 font-medium">Loading listener details...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-50 dark:bg-gray-900">
        <div className="text-center bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8 max-w-md">
          <div className="w-16 h-16 bg-red-100 dark:bg-red-900/30 rounded-full flex items-center justify-center mx-auto mb-4">
            <Activity className="w-8 h-8 text-red-600" />
          </div>
          <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">Failed to Load</h3>
          <p className="text-gray-600 dark:text-gray-400 mb-6">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="px-6 py-2.5 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors font-medium"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  if (!listener) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-50 dark:bg-gray-900">
        <div className="text-center bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8 max-w-md">
          <div className="w-16 h-16 bg-gray-100 dark:bg-gray-700 rounded-full flex items-center justify-center mx-auto mb-4">
            <User className="w-8 h-8 text-gray-400" />
          </div>
          <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">Listener Not Found</h3>
          <p className="text-gray-600 dark:text-gray-400 mb-6">The listener you're looking for doesn't exist or has been removed.</p>
          <button
            onClick={() => navigate('/admin/listeners')}
            className="px-6 py-2.5 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors font-medium"
          >
            Back to Listeners
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 p-6 transition-colors">
      <div className="max-w-7xl mx-auto">
        {/* Header with Back Button */}
        <div className="mb-6">
          <button
            onClick={() => navigate('/admin/listeners')}
            className="flex items-center gap-2 text-gray-600 dark:text-gray-400 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors mb-4 group"
          >
            <ArrowLeft className="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
            <span className="font-medium">Back to Listeners</span>
          </button>
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">Listener Profile</h1>
              <p className="text-gray-600 dark:text-gray-400">Complete information and statistics</p>
            </div>
          </div>
        </div>

        {/* Profile Header Card */}
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-8 mb-6">
          <div className="flex flex-col lg:flex-row gap-8">
            {/* Avatar Section */}
            <div className="flex flex-col items-center lg:items-start">
              <div className="relative">
                <div className="w-32 h-32 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-full flex items-center justify-center text-white text-4xl font-bold shadow-lg">
                  {(listener.professional_name || listener.display_name || '?').charAt(0).toUpperCase()}
                </div>
                {listener.is_online && (
                  <div className="absolute bottom-2 right-2 w-6 h-6 bg-emerald-500 border-4 border-white dark:border-gray-800 rounded-full animate-pulse"></div>
                )}
                {listener.is_verified && (
                  <div className="absolute -top-1 -right-1 w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center shadow-lg">
                    <Shield className="w-5 h-5 text-white" />
                  </div>
                )}
              </div>
              <div className="mt-4 text-center lg:text-left">
                <span className={`inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-medium ${
                  listener.is_online
                    ? 'bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400'
                    : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400'
                }`}>
                  <span className={`w-2 h-2 rounded-full ${listener.is_online ? 'bg-emerald-500' : 'bg-gray-400'}`}></span>
                  {listener.is_online ? 'Online Now' : 'Offline'}
                </span>
              </div>
            </div>

            {/* Basic Info Section */}
            <div className="flex-1">
              <div className="mb-4">
                <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
                  {listener.professional_name || listener.display_name || 'Unknown Listener'}
                </h2>
                <div className="flex flex-wrap items-center gap-3 text-sm text-gray-600 dark:text-gray-400">
                  <span className="flex items-center gap-1.5">
                    <User className="w-4 h-4" />
                    ID: {listener.listener_id?.slice(0, 8)}...
                  </span>
                  {listener.city && (
                    <span className="flex items-center gap-1.5">
                      <MapPin className="w-4 h-4" />
                      {listener.city}, {listener.country}
                    </span>
                  )}
                  <span className="flex items-center gap-1.5">
                    <Calendar className="w-4 h-4" />
                    Joined {new Date(listener.created_at).toLocaleDateString('en-US', { month: 'short', year: 'numeric' })}
                  </span>
                </div>
              </div>

              {/* Rating and Rate */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                <div className="flex items-center gap-3 bg-amber-50 dark:bg-amber-900/20 rounded-lg p-4">
                  <div className="p-2 bg-amber-100 dark:bg-amber-900/30 rounded-lg">
                    <Star className="w-5 h-5 text-amber-600" />
                  </div>
                  <div>
                    <div className="text-2xl font-bold text-gray-900 dark:text-white">
                      {listener.average_rating ? Number(listener.average_rating).toFixed(1) : 'N/A'}
                    </div>
                    <div className="text-xs text-gray-600 dark:text-gray-400">
                      {listener.total_ratings || 0} reviews
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-3 bg-indigo-50 dark:bg-indigo-900/20 rounded-lg p-4">
                  <div className="p-2 bg-indigo-100 dark:bg-indigo-900/30 rounded-lg">
                    <DollarSign className="w-5 h-5 text-indigo-600" />
                  </div>
                  <div>
                    <div className="text-2xl font-bold text-gray-900 dark:text-white">
                      {listener.rate_per_minute || 0}
                    </div>
                    <div className="text-xs text-gray-600 dark:text-gray-400">
                      {listener.currency || 'USD'} per minute
                    </div>
                  </div>
                </div>
              </div>

              {/* Quick Stats */}
              <div className="flex flex-wrap gap-4">
                {listener.is_verified && (
                  <div className="flex items-center gap-2 px-3 py-1.5 bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-400 rounded-lg text-sm font-medium">
                    <Shield className="w-4 h-4" />
                    Verified
                  </div>
                )}
                {listener.is_available && (
                  <div className="flex items-center gap-2 px-3 py-1.5 bg-green-50 dark:bg-green-900/20 text-green-700 dark:text-green-400 rounded-lg text-sm font-medium">
                    <Headphones className="w-4 h-4" />
                    Available
                  </div>
                )}
                {listener.experience_years && (
                  <div className="flex items-center gap-2 px-3 py-1.5 bg-purple-50 dark:bg-purple-900/20 text-purple-700 dark:text-purple-400 rounded-lg text-sm font-medium">
                    <Award className="w-4 h-4" />
                    {listener.experience_years}+ years
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Stats Overview */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
          <StatCard
            icon={Headphones}
            label="Total Calls"
            value={listener.total_calls || 0}
            color="blue"
          />
          <StatCard
            icon={Clock}
            label="Total Minutes"
            value={listener.total_minutes || 0}
            color="indigo"
            trend="+12%"
          />
          <StatCard
            icon={DollarSign}
            label="Total Earnings"
            value={`₹${listener.total_earnings || 0}`}
            color="emerald"
            trend="+8%"
          />
        </div>

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
          {/* Left Column - Contact & Personal Info */}
          <div className="lg:col-span-2 space-y-6">
            {/* Contact Information */}
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                <Mail className="w-5 h-5 text-indigo-600" />
                Contact Information
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <InfoItem
                  icon={Mail}
                  label="Email Address"
                  value={listener.email}
                  copyable
                  fieldKey="email"
                />
                <InfoItem
                  icon={Phone}
                  label="Phone Number"
                  value={listener.phone_number}
                  copyable
                  fieldKey="phone_number"
                />
                <InfoItem
                  icon={Phone}
                  label="Mobile Number"
                  value={listener.mobile_number}
                  copyable
                  fieldKey="mobile_number"
                />
                <InfoItem
                  icon={MapPin}
                  label="Location"
                  value={listener.city && listener.country ? `${listener.city}, ${listener.country}` : null}
                />
              </div>
            </div>

            {/* Professional Information */}
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                <Briefcase className="w-5 h-5 text-indigo-600" />
                Professional Details
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <InfoItem
                  icon={Award}
                  label="Experience"
                  value={listener.experience_years ? `${listener.experience_years} years` : null}
                />
                <InfoItem
                  icon={GraduationCap}
                  label="Education"
                  value={listener.education}
                />
                <InfoItem
                  icon={User}
                  label="Age"
                  value={listener.age?.toString()}
                />
                <InfoItem
                  icon={Clock}
                  label="Last Active"
                  value={listener.last_active_at ? new Date(listener.last_active_at).toLocaleString('en-US', {
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                  }) : null}
                />
              </div>

              {/* Specialties */}
              {listener.specialties && listener.specialties.length > 0 && (
                <div className="mt-6">
                  <label className="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-2 block">
                    Specialties
                  </label>
                  <div className="flex flex-wrap gap-2">
                    {listener.specialties.map((specialty, index) => (
                      <span key={index} className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-indigo-50 dark:bg-indigo-900/20 text-indigo-700 dark:text-indigo-400 rounded-lg text-sm font-medium">
                        <Heart className="w-3.5 h-3.5" />
                        {specialty}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {/* Languages */}
              {listener.languages && listener.languages.length > 0 && (
                <div className="mt-4">
                  <label className="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-2 block">
                    Languages
                  </label>
                  <div className="flex flex-wrap gap-2">
                    {listener.languages.map((language, index) => (
                      <span key={index} className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-400 rounded-lg text-sm font-medium">
                        <Languages className="w-3.5 h-3.5" />
                        {language}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {/* Certifications */}
              {listener.certifications && (
                <div className="mt-4">
                  <label className="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-2 block">
                    Certifications
                  </label>
                  <p className="text-sm text-gray-900 dark:text-white px-3 py-2 bg-gray-50 dark:bg-gray-900 rounded-lg">
                    {listener.certifications}
                  </p>
                </div>
              )}
            </div>

            {/* Bio */}
            {listener.bio && (
              <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                  <MessageSquare className="w-5 h-5 text-indigo-600" />
                  About
                </h3>
                <p className="text-gray-700 dark:text-gray-300 leading-relaxed whitespace-pre-wrap">
                  {listener.bio}
                </p>
              </div>
            )}
          </div>

          {/* Right Column - Activity & Payment */}
          <div className="space-y-6">
            {/* Activity Status */}
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                <Activity className="w-5 h-5 text-indigo-600" />
                Status
              </h3>
              <div className="space-y-3">
                <div className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
                  <span className="text-sm text-gray-600 dark:text-gray-400">Account</span>
                  <span className="text-sm font-medium text-emerald-600 dark:text-emerald-400">Active</span>
                </div>
                <div className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
                  <span className="text-sm text-gray-600 dark:text-gray-400">Availability</span>
                  <span className={`text-sm font-medium ${
                    listener.is_available 
                      ? 'text-emerald-600 dark:text-emerald-400' 
                      : 'text-gray-600 dark:text-gray-400'
                  }`}>
                    {listener.is_available ? 'Available' : 'Unavailable'}
                  </span>
                </div>
                <div className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
                  <span className="text-sm text-gray-600 dark:text-gray-400">Verification</span>
                  <span className={`text-sm font-medium ${
                    listener.is_verified 
                      ? 'text-blue-600 dark:text-blue-400' 
                      : 'text-gray-600 dark:text-gray-400'
                  }`}>
                    {listener.is_verified ? 'Verified' : 'Pending'}
                  </span>
                </div>
              </div>
            </div>

            {/* Payment Information */}
            {listener?.payment_info && (
              <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                  <CreditCard className="w-5 h-5 text-indigo-600" />
                  Payment Details
                </h3>
                <div className="space-y-4">
                  <InfoItem
                    icon={Building2}
                    label="Payment Method"
                    value={listener.payment_info.payment_method?.toUpperCase()}
                  />
                  
                  {listener.payment_info.payment_method === 'upi' && (
                    <>
                      <InfoItem
                        icon={CreditCard}
                        label="UPI ID"
                        value={listener.payment_info.upi_id}
                        copyable
                        fieldKey="upi_id"
                      />
                      <InfoItem
                        icon={Shield}
                        label="Aadhaar"
                        value={listener.payment_info.aadhaar_number}
                        copyable
                        masked
                        fieldKey="aadhaar_number"
                      />
                      <InfoItem
                        icon={Shield}
                        label="PAN Number"
                        value={listener.payment_info.pan_number}
                        copyable
                        masked
                        fieldKey="pan_number"
                      />
                      <InfoItem
                        icon={User}
                        label="Name as per PAN"
                        value={listener.payment_info.name_as_per_pan}
                        copyable
                        fieldKey="name_as_per_pan"
                      />
                    </>
                  )}
                  
                  {listener.payment_info.payment_method === 'bank' && (
                    <>
                      <InfoItem
                        icon={Building2}
                        label="Bank Name"
                        value={listener.payment_info.bank_name}
                        copyable
                        fieldKey="bank_name"
                      />
                      <InfoItem
                        icon={User}
                        label="Account Holder"
                        value={listener.payment_info.account_holder_name}
                        copyable
                        fieldKey="account_holder_name"
                      />
                      <InfoItem
                        icon={CreditCard}
                        label="Account Number"
                        value={listener.payment_info.account_number}
                        copyable
                        masked
                        fieldKey="account_number"
                      />
                      <InfoItem
                        icon={Building2}
                        label="IFSC Code"
                        value={listener.payment_info.ifsc_code}
                        copyable
                        fieldKey="ifsc_code"
                      />
                      <InfoItem
                        icon={Shield}
                        label="PAN/Aadhaar"
                        value={listener.payment_info.pan_aadhaar_bank}
                        copyable
                        masked
                        fieldKey="pan_aadhaar_bank"
                      />
                    </>
                  )}
                  
                  <div className="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
                    <p className="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1.5">
                      <Eye className="w-3.5 h-3.5" />
                      Click on any value to copy. Sensitive data is masked.
                    </p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ListenerDetails;