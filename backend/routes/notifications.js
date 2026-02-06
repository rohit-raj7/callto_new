import express from 'express';
import { pool } from '../db.js';
import NotificationOutbox from '../models/NotificationOutbox.js';
import { authenticate, authenticateAdmin } from '../middleware/auth.js';

const router = express.Router();

router.post('/outbox', authenticateAdmin, async (req, res) => {
  try {
    const { title, body, targetRole, targetUserIds, scheduleAt } = req.body;
    if (!title || !body || !targetRole) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    if (targetRole !== 'USER' && targetRole !== 'LISTENER') {
      return res.status(400).json({ error: 'Invalid targetRole' });
    }
    const created = await NotificationOutbox.create({
      title,
      body,
      target_role: targetRole,
      target_user_ids: Array.isArray(targetUserIds) && targetUserIds.length ? targetUserIds : null,
      schedule_at: scheduleAt || null,
      created_by: req.adminId
    });
    res.json({ message: 'Notification scheduled', outbox: created });
  } catch (error) {
    res.status(500).json({ error: 'Failed to schedule notification' });
  }
});

router.get('/my', authenticate, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const offset = (Number(page) - 1) * Number(limit);
    const q = `
      SELECT notification_id as id, title, message as body, notification_type, is_read, data, created_at
      FROM notifications
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT $2 OFFSET $3
    `;
    const rows = await pool.query(q, [req.userId, Number(limit), offset]);
    res.json({ notifications: rows.rows });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

router.post('/mark-read', authenticate, async (req, res) => {
  try {
    const { id } = req.body;
    if (!id) return res.status(400).json({ error: 'id required' });
    const q = `
      UPDATE notifications
      SET is_read = TRUE
      WHERE notification_id = $1 AND user_id = $2
      RETURNING notification_id
    `;
    const r = await pool.query(q, [id, req.userId]);
    if (!r.rows.length) return res.status(404).json({ error: 'Not found' });
    res.json({ id: r.rows[0].notification_id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to mark as read' });
  }
});

router.get('/unread-count', authenticate, async (req, res) => {
  try {
    const q = `
      SELECT COUNT(*)::int AS count
      FROM notifications
      WHERE user_id = $1 AND is_read = FALSE
    `;
    const r = await pool.query(q, [req.userId]);
    res.json({ count: r.rows[0].count });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch unread count' });
  }
});

export default router;

