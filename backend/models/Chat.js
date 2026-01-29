import { pool } from '../db.js';

class Chat {
  // Create or get existing chat between two users
  static async findOrCreate(user1_id, user2_id) {
    // First, try to find existing chat
    const findQuery = `
      SELECT * FROM chats 
      WHERE (user1_id = $1 AND user2_id = $2) 
         OR (user1_id = $2 AND user2_id = $1)
    `;
    const findResult = await pool.query(findQuery, [user1_id, user2_id]);

    if (findResult.rows.length > 0) {
      return findResult.rows[0];
    }

    // Create new chat if doesn't exist
    const createQuery = `
      INSERT INTO chats (user1_id, user2_id)
      VALUES ($1, $2)
      RETURNING *
    `;
    const createResult = await pool.query(createQuery, [user1_id, user2_id]);
    return createResult.rows[0];
  }

  // Get chat by ID
  static async findById(chat_id) {
    const query = 'SELECT * FROM chats WHERE chat_id = $1';
    const result = await pool.query(query, [chat_id]);
    return result.rows[0];
  }

  // Get user's all chats
  static async getUserChats(user_id) {
    const query = `
      SELECT c.*, 
             CASE 
               WHEN c.user1_id = $1 THEN u2.display_name
               ELSE u1.display_name
             END as other_user_name,
             CASE 
               WHEN c.user1_id = $1 THEN u2.avatar_url
               ELSE u1.avatar_url
             END as other_user_avatar,
             CASE 
               WHEN c.user1_id = $1 THEN c.user2_id
               ELSE c.user1_id
             END as other_user_id,
             (SELECT COUNT(*) FROM messages 
              WHERE chat_id = c.chat_id 
                AND sender_id != $1 
                AND is_read = FALSE) as unread_count
      FROM chats c
      JOIN users u1 ON c.user1_id = u1.user_id
      JOIN users u2 ON c.user2_id = u2.user_id
      WHERE (c.user1_id = $1 OR c.user2_id = $1)
        AND c.is_active = TRUE
      ORDER BY c.last_message_at DESC NULLS LAST, c.created_at DESC
    `;
    const result = await pool.query(query, [user_id]);
    return result.rows;
  }

  // Update last message
  static async updateLastMessage(chat_id, message_content) {
    const query = `
      UPDATE chats 
      SET last_message = $1, last_message_at = CURRENT_TIMESTAMP
      WHERE chat_id = $2
      RETURNING *
    `;
    const result = await pool.query(query, [message_content, chat_id]);
    return result.rows[0];
  }

  // Delete/deactivate chat
  static async deactivate(chat_id) {
    const query = 'UPDATE chats SET is_active = FALSE WHERE chat_id = $1';
    await pool.query(query, [chat_id]);
  }
}

class Message {
  // Send a message
  static async create(messageData) {
    const {
      chat_id,
      sender_id,
      message_type = 'text',
      message_content,
      media_url = null
    } = messageData;

    const query = `
      INSERT INTO messages (chat_id, sender_id, message_type, message_content, media_url)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `;

    const values = [chat_id, sender_id, message_type, message_content, media_url];
    const result = await pool.query(query, values);

    // Update last message in chat
    await Chat.updateLastMessage(chat_id, message_content);

    return result.rows[0];
  }

  // Get messages for a chat
  static async getChatMessages(chat_id, limit = 50, offset = 0) {
    const query = `
      SELECT m.*, u.display_name as sender_name, u.avatar_url as sender_avatar
      FROM messages m
      JOIN users u ON m.sender_id = u.user_id
      WHERE m.chat_id = $1
      ORDER BY m.created_at DESC
      LIMIT $2 OFFSET $3
    `;
    const result = await pool.query(query, [chat_id, limit, offset]);
    return result.rows.reverse(); // Return in chronological order
  }

  // Mark messages as read
  static async markAsRead(chat_id, user_id) {
    const query = `
      UPDATE messages 
      SET is_read = TRUE, read_at = CURRENT_TIMESTAMP
      WHERE chat_id = $1 
        AND sender_id != $2 
        AND is_read = FALSE
      RETURNING message_id
    `;
    const result = await pool.query(query, [chat_id, user_id]);
    return result.rows;
  }

  // Get unread message count
  static async getUnreadCount(user_id) {
    const query = `
      SELECT COUNT(*) as unread_count
      FROM messages m
      JOIN chats c ON m.chat_id = c.chat_id
      WHERE (c.user1_id = $1 OR c.user2_id = $1)
        AND m.sender_id != $1
        AND m.is_read = FALSE
    `;
    const result = await pool.query(query, [user_id]);
    return result.rows[0].unread_count;
  }
}

export { Chat, Message };
