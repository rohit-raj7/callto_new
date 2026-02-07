import express from 'express';
import jwt from 'jsonwebtoken';
import axios from 'axios';
import { OAuth2Client } from 'google-auth-library';
import Admin from '../models/Admin.js';
import Listener from '../models/Listener.js';
import config from '../config/config.js';
import { pool } from '../db.js';
import { authenticateAdmin } from '../middleware/auth.js';

const router = express.Router();
const googleClient = new OAuth2Client(process.env.admin_google_client_id);

// Admin Google login
router.post('/google-login', async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ error: 'Token is required' });
    }

    let userInfo;

    // Verify Google token
    try {
      // First, try to verify as ID token
      const ticket = await googleClient.verifyIdToken({
        idToken: token,
      });

      const payload = ticket.getPayload();

      userInfo = {
        email: payload.email,
        full_name: payload.name,
      };
    } catch (idTokenError) {
      // If ID token verification fails, try as access token
      console.log('ID token verification failed, trying access token...');
      try {
        const googleRes = await axios.get(
          `https://www.googleapis.com/oauth2/v3/userinfo?access_token=${token}`
        );

        const googleUser = googleRes.data;

        userInfo = {
          email: googleUser.email,
          full_name: googleUser.name,
        };
      } catch (accessTokenError) {
        console.error('Google token verification failed:', accessTokenError);
        return res.status(401).json({ error: 'Invalid Google token' });
      }
    }

    // Check if email matches the admin email
    if (userInfo.email !== 'calltoofficials@gmail.com') {
      return res.status(401).json({ error: 'Unauthorized: Not an admin email' });
    }

    // Find or create admin
    let admin = await Admin.findByEmail(userInfo.email);
    if (!admin) {
      // Create admin if not exists
      const hashedPassword = await Admin.hashPassword('defaultpassword'); // Not used, but required
      admin = await Admin.create({
        email: userInfo.email,
        password_hash: hashedPassword,
        full_name: userInfo.full_name,
      });
    }

    // Update last login
    await Admin.updateLastLogin(admin.admin_id);

    // Generate JWT token
    const jwtToken = jwt.sign(
      { admin_id: admin.admin_id, email: admin.email },
      config.jwt.secret,
      { expiresIn: config.jwt.expiresIn }
    );

    res.json({
      message: 'Login successful',
      token: jwtToken,
      admin: {
        admin_id: admin.admin_id,
        email: admin.email,
        full_name: admin.full_name
      }
    });
  } catch (error) {
    console.error('Admin Google login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/admin/listeners
// Get all listeners for admin panel
router.get('/listeners', async (req, res) => {
  try {
    const listeners = await Listener.getAllForAdmin();
    res.json({ listeners });
  } catch (error) {
    console.error('Get admin listeners error:', error);
    res.status(500).json({ error: 'Failed to fetch listeners' });
  }
});

// GET /api/admin/contact-messages
// Fetch contact/support messages for admin panel
router.get('/contact-messages', authenticateAdmin, async (req, res) => {
  try {
    const { page = 1, limit = 50, source, search } = req.query;
    const perPage = Math.min(Math.max(Number(limit) || 50, 1), 200);
    const currentPage = Math.max(Number(page) || 1, 1);
    const offset = (currentPage - 1) * perPage;

    const conds = [];
    const params = [];
    let idx = 1;

    if (source && (source === 'contact' || source === 'support')) {
      conds.push(`source = $${idx++}`);
      params.push(source);
    }

    if (search) {
      conds.push(`(name ILIKE $${idx} OR email ILIKE $${idx} OR message ILIKE $${idx})`);
      params.push(`%${String(search).trim()}%`);
      idx += 1;
    }

    const where = conds.length ? `WHERE ${conds.join(' AND ')}` : '';
    const listQuery = `
      SELECT contact_id, source, name, email, message, user_id, created_at
      FROM contact_messages
      ${where}
      ORDER BY created_at DESC
      LIMIT $${idx} OFFSET $${idx + 1}
    `;
    const listParams = [...params, perPage, offset];

    const countQuery = `
      SELECT COUNT(*)::int AS count
      FROM contact_messages
      ${where}
    `;

    const [listResult, countResult] = await Promise.all([
      pool.query(listQuery, listParams),
      pool.query(countQuery, params)
    ]);

    res.json({
      messages: listResult.rows,
      count: countResult.rows[0]?.count || 0,
      page: currentPage,
      limit: perPage
    });
  } catch (error) {
    console.error('Get contact messages error:', error);
    res.status(500).json({ error: 'Failed to fetch contact messages' });
  }
});

export default router;