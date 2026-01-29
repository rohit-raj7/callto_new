import express from 'express';
const router = express.Router();
import pkg from 'agora-access-token';
const { RtcTokenBuilder, RtcRole } = pkg;
import Call from '../models/Call.js';
import Rating from '../models/Rating.js';
import Listener from '../models/Listener.js';
import { authenticate } from '../middleware/auth.js';
import config from '../config/config.js';

// POST /api/calls
// Initiate a new call
router.post('/', authenticate, async (req, res) => {
  try {
    const { listener_id, call_type } = req.body;

    if (!listener_id) {
      return res.status(400).json({ error: 'listener_id is required' });
    }

    // Get listener details for rate
    const listener = await Listener.findById(listener_id);
    
    if (!listener) {
      return res.status(404).json({ error: 'Listener not found' });
    }

    if (!listener.is_available || !listener.is_online) {
      return res.status(400).json({ error: 'Listener is not available' });
    }

    // Create call
    const call = await Call.create({
      caller_id: req.userId,
      listener_id,
      call_type: call_type || 'audio',
      rate_per_minute: listener.rate_per_minute
    });

    res.status(201).json({
      message: 'Call initiated',
      call
    });
  } catch (error) {
    console.error('Create call error:', error);
    res.status(500).json({ error: 'Failed to initiate call' });
  }
});

// GET /api/calls/:call_id
// Get call details
router.get('/:call_id', authenticate, async (req, res) => {
  try {
    const call = await Call.findById(req.params.call_id);

    if (!call) {
      return res.status(404).json({ error: 'Call not found' });
    }

    // Check if user is part of the call (as caller or listener)
    const listener = await Listener.findByUserId(req.userId);
    const isListener = listener && call.listener_id === listener.listener_id;
    
    if (call.caller_id !== req.userId && !isListener) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    res.json({ call });
  } catch (error) {
    console.error('Get call error:', error);
    res.status(500).json({ error: 'Failed to fetch call' });
  }
});

// PUT /api/calls/:call_id/status
// Update call status
router.put('/:call_id/status', authenticate, async (req, res) => {
  try {
    const { status, duration_seconds } = req.body;

    if (!status) {
      return res.status(400).json({ error: 'Status is required' });
    }

    const validStatuses = ['pending', 'ringing', 'ongoing', 'completed', 'missed', 'rejected', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    // Get call and verify user is part of it
    const call = await Call.findById(req.params.call_id);
    
    if (!call) {
      return res.status(404).json({ error: 'Call not found' });
    }
    
    // Check if user is caller or listener
    const listener = await Listener.findByUserId(req.userId);
    const isListener = listener && call.listener_id === listener.listener_id;
    
    if (call.caller_id !== req.userId && !isListener) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    let additionalData = {};

    // Calculate cost if call is completed
    if (status === 'completed' && duration_seconds) {
      const cost = Call.calculateCost(duration_seconds, call.rate_per_minute);
      additionalData = {
        duration_seconds,
        total_cost: parseFloat(cost)
      };

      // Update listener stats
      const durationMinutes = Math.ceil(duration_seconds / 60);
      await Listener.incrementCallStats(call.listener_id, durationMinutes);
    }

    const updatedCall = await Call.updateStatus(
      req.params.call_id,
      status,
      additionalData
    );

    res.json({
      message: 'Call status updated',
      call: updatedCall
    });
  } catch (error) {
    console.error('Update call status error:', error);
    res.status(500).json({ error: 'Failed to update call status' });
  }
});

// GET /api/calls/history/me
// Get user's call history
router.get('/history/me', authenticate, async (req, res) => {
  try {
    const limit = req.query.limit ? parseInt(req.query.limit) : 20;
    const offset = req.query.offset ? parseInt(req.query.offset) : 0;

    const calls = await Call.getUserCallHistory(req.userId, limit, offset);

    res.json({
      calls,
      count: calls.length
    });
  } catch (error) {
    console.error('Get call history error:', error);
    res.status(500).json({ error: 'Failed to fetch call history' });
  }
});

// GET /api/calls/history/listener
// Get listener's call history (for listeners to see their callers)
router.get('/history/listener', authenticate, async (req, res) => {
  try {
    const limit = req.query.limit ? parseInt(req.query.limit) : 20;
    const offset = req.query.offset ? parseInt(req.query.offset) : 0;

    // Get listener_id for this user
    const listener = await Listener.findByUserId(req.userId);
    
    if (!listener) {
      return res.status(404).json({ error: 'Listener profile not found' });
    }

    const calls = await Call.getListenerCallHistory(listener.listener_id, limit, offset);

    res.json({
      calls,
      count: calls.length
    });
  } catch (error) {
    console.error('Get listener call history error:', error);
    res.status(500).json({ error: 'Failed to fetch call history' });
  }
});

// GET /api/calls/active/me
// Get user's active calls
router.get('/active/me', authenticate, async (req, res) => {
  try {
    const calls = await Call.getActiveCalls(req.userId);

    res.json({
      calls,
      count: calls.length
    });
  } catch (error) {
    console.error('Get active calls error:', error);
    res.status(500).json({ error: 'Failed to fetch active calls' });
  }
});

// POST /api/calls/:call_id/rating
// Rate a completed call
router.post('/:call_id/rating', authenticate, async (req, res) => {
  try {
    const { rating, review_text } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ error: 'Rating must be between 1 and 5' });
    }

    // Get call details
    const call = await Call.findById(req.params.call_id);

    if (!call) {
      return res.status(404).json({ error: 'Call not found' });
    }

    if (call.caller_id !== req.userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    if (call.status !== 'completed') {
      return res.status(400).json({ error: 'Can only rate completed calls' });
    }

    // Check if already rated
    const alreadyRated = await Rating.isCallRated(req.params.call_id);
    if (alreadyRated) {
      return res.status(400).json({ error: 'Call already rated' });
    }

    // Create rating
    const ratingRecord = await Rating.create({
      call_id: req.params.call_id,
      listener_id: call.listener_id,
      user_id: req.userId,
      rating: parseFloat(rating),
      review_text
    });

    // Update listener's average rating and total ratings
    const averageData = await Rating.getListenerAverageRating(call.listener_id);
    await Listener.updateRatingStats(call.listener_id, averageData.average_rating, averageData.total_ratings);

    res.status(201).json({
      message: 'Rating submitted successfully',
      rating: ratingRecord
    });
  } catch (error) {
    console.error('Create rating error:', error);
    res.status(500).json({ error: 'Failed to submit rating' });
  }
});

// POST /api/calls/random
// Initiate a random call with a random listener
router.post('/random', authenticate, async (req, res) => {
  try {
    const { call_type } = req.body;

    // Get a random available listener
    const listeners = await Listener.getRandomAvailable(1);

    if (listeners.length === 0) {
      return res.status(404).json({ error: 'No available listeners found' });
    }

    const listener = listeners[0];

    if (!listener.is_available || !listener.is_online) {
      return res.status(400).json({ error: 'Listener is not available' });
    }

    // Create call with random listener
    const call = await Call.create({
      caller_id: req.userId,
      listener_id: listener.listener_id,
      call_type: call_type || 'audio',
      rate_per_minute: listener.rate_per_minute
    });

    res.status(201).json({
      message: 'Random call initiated',
      call,
      listener: {
        listener_id: listener.listener_id,
        professional_name: listener.professional_name,
        avatar_url: listener.profile_image,
        rating: listener.average_rating,
        city: listener.city
      }
    });
  } catch (error) {
    console.error('Random call error:', error);
    res.status(500).json({ error: 'Failed to initiate random call' });
  }
});

// POST /api/calls/agora/token
// Generate Agora RTC token for a call
router.post('/agora/token', authenticate, async (req, res) => {
  try {
    const { channel_name, uid } = req.body;

    if (!channel_name) {
      return res.status(400).json({ error: 'channel_name is required' });
    }

    const appId = config.agora.appId;
    const appCertificate = config.agora.appCertificate;

    if (!appId || !appCertificate) {
      console.error('Agora credentials not configured');
      return res.status(500).json({ error: 'Agora credentials not configured' });
    }

    // Use provided uid or default to 0 (will be assigned by Agora)
    const userUid = uid ? parseInt(uid) : 0;
    
    // Token expiry time (5 minutes from now)
    const expirationTimeInSeconds = config.agora.tokenExpirySeconds;
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

    // Build token with uid
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channel_name,
      userUid,
      RtcRole.PUBLISHER,
      privilegeExpiredTs
    );

    res.json({
      token,
      channel_name,
      uid: userUid,
      expires_at: new Date(privilegeExpiredTs * 1000).toISOString()
    });
  } catch (error) {
    console.error('Generate Agora token error:', error);
    res.status(500).json({ error: 'Failed to generate Agora token' });
  }
});

export default router;
