import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import config from './config/config.js';
import { testConnection, ensureSchema } from './db.js';
// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: config.cors,
  pingTimeout: config.socketIO.pingTimeout,
  pingInterval: config.socketIO.pingInterval
});

// Import routes
import authRoutes from './routes/auth.js';
import userRoutes from './routes/users.js';
import listenerRoutes from './routes/listeners.js';
import callRoutes from './routes/calls.js';
import createChatsRouter from './routes/chats.js';
import adminRoutes from './routes/admin.js';
import User from './models/User.js';
import { Chat, Message } from './models/Chat.js';

// ============================================
// MIDDLEWARE
// ============================================

// Security middleware
app.use(helmet());

// CORS
app.use(cors(config.cors));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Compression
app.use(compression());

// Logging
if (config.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Rate limiting
const limiter = rateLimit({
  windowMs: config.rateLimit.windowMs,
  max: config.rateLimit.max,
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// ============================================
// ROUTES
// ============================================

// Health check
app.get('/', (req, res) => {
  res.json({
    message: 'Call To API Server',
    version: '1.0.0',
    status: 'running'
  });
});

// API health check
app.get('/api/health', async (req, res) => {
  try {
    const dbConnected = await testConnection();
    res.json({
      status: 'healthy',
      database: dbConnected ? 'connected' : 'disconnected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      error: error.message
    });
  }
});

// Mount API routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/listeners', listenerRoutes);
app.use('/api/calls', callRoutes);
app.use('/api/chats', createChatsRouter(io)); // Pass io for real-time message delivery
app.use('/api/admin', adminRoutes);

// ============================================
// SOCKET.IO - REAL-TIME FEATURES
// ============================================



// In-memory maps
const connectedUsers = new Map(); // Map of userId -> socketId
const listenerSockets = new Map(); // Map of listenerUserId -> socketId
const activeChannels = new Map(); // Map of channelName -> Set of userIds in channel
const lastSeenMap = new Map(); // Map of userId -> timestamp
const presenceTimeouts = new Map(); // Map of userId -> timeoutId

// WhatsApp-style chat state tracking
const userChatState = new Map(); // Map of userId -> { activelyViewingChatId, appState: 'foreground'|'background' }

// Socket.IO connection handler
io.on('connection', (socket) => {
  console.log(`[SOCKET] Connected: ${socket.id}`);

  // 1. IDENTITY & PRESENCE
  
  // User joins (can be regular user or listener)
  socket.on('user:join', (data) => {
    // Support both old format (just userId string) and new format (object with userId, userName, avatar)
    let userId, userName, userAvatar, activelyViewingChatId;
    if (typeof data === 'string') {
      userId = data;
    } else if (data && typeof data === 'object') {
      userId = data.userId;
      userName = data.userName;
      userAvatar = data.userAvatar;
      activelyViewingChatId = data.activelyViewingChatId; // WhatsApp-style: which chat is open
    }
    
    if (!userId) return;
    socket.userId = userId;
    socket.userName = userName || 'Unknown';
    socket.userAvatar = userAvatar;
    connectedUsers.set(userId, socket.id);
    lastSeenMap.set(userId, Date.now());
    
    // Initialize or update user chat state (WhatsApp-style tracking)
    userChatState.set(userId, {
      activelyViewingChatId: activelyViewingChatId || null,
      appState: 'foreground'
    });
    
    // Join user's personal room for notifications
    socket.join(`user_${userId}`);
    console.log(`[SOCKET] User ${userId} joined personal room: user_${userId}`);
    
    // Clear any pending offline timeout
    if (presenceTimeouts.has(userId)) {
      clearTimeout(presenceTimeouts.get(userId));
      presenceTimeouts.delete(userId);
    }
    
    io.emit('user:online', { userId });
    console.log(`[SOCKET] User joined: ${userId} (${userName || 'unknown name'}), activeChat: ${activelyViewingChatId || 'none'}`);

    // Send current online listeners to the newly joined user
    const onlineListeners = Array.from(listenerSockets.keys());
    socket.emit('listeners:initial_status', onlineListeners);
  });

  // Listener specific join (for availability tracking)
  // CRITICAL: This is what makes a listener available to receive calls
  // Must be emitted when listener app is open (any page)
  socket.on('listener:join', (listenerUserId) => {
    if (!listenerUserId) return;
    socket.userId = listenerUserId; // Sync with userId
    socket.listenerUserId = listenerUserId;
    
    // Remove old socket if exists to prevent ghost sessions
    if (listenerSockets.has(listenerUserId)) {
      const oldSocketId = listenerSockets.get(listenerUserId);
      if (oldSocketId && oldSocketId !== socket.id) {
        console.log(`[SOCKET] listener:join: Removing old socket ${oldSocketId} for listener ${listenerUserId}`);
        const oldSocket = io.sockets.sockets.get(oldSocketId);
        if (oldSocket) oldSocket.disconnect(true);
      }
    }
    
    // Register listener as available for calls
    listenerSockets.set(listenerUserId, socket.id);
    connectedUsers.set(listenerUserId, socket.id); // Also ensure in connectedUsers
    
    io.emit('listener_status', { listenerUserId, online: true, timestamp: Date.now() });
    console.log(`[SOCKET] listener:join: ✓ Listener ${listenerUserId} is now ONLINE (socket: ${socket.id})`);
    console.log(`[SOCKET] listener:join: Total online listeners: ${listenerSockets.size}`);
  });

  // Explicit offline event - listener manually going offline
  // NOTE: This should only be called when listener explicitly goes offline,
  // NOT when navigating between pages in the app
  socket.on('listener:offline', (data) => {
    const { listenerUserId } = data || {};
    if (listenerUserId) {
      listenerSockets.delete(listenerUserId);
      io.emit('listener_status', { listenerUserId, online: false, timestamp: Date.now() });
      console.log(`[SOCKET] listener:offline: ✓ Listener ${listenerUserId} manually went OFFLINE`);
    }
  });

  // 2. CALL HANDLING

  // Initiate call: User -> Listener
  // CRITICAL: This checks if listener is online by looking for their socket
  // Listener is online if they have an entry in listenerSockets OR connectedUsers
  socket.on('call:initiate', (data) => {
    const { listenerId, ...callData } = data || {};
    
    // Check both maps for the listener's socket
    // listenerSockets: explicitly registered as listener (listener:join)
    // connectedUsers: any connected user (user:join)
    const listenerSocketId = listenerSockets.get(listenerId) || connectedUsers.get(listenerId);
    
    console.log(`[SOCKET] call:initiate: Looking for listener ${listenerId}`);
    console.log(`[SOCKET] call:initiate: listenerSockets has: ${listenerSockets.has(listenerId)}`);
    console.log(`[SOCKET] call:initiate: connectedUsers has: ${connectedUsers.has(listenerId)}`);
    console.log(`[SOCKET] call:initiate: Found socketId: ${listenerSocketId || 'NONE'}`);
    
    if (listenerSocketId) {
      // Listener is online - forward the call
      io.to(listenerSocketId).emit('incoming-call', callData);
      console.log(`[SOCKET] call:initiate: ✓ Forwarded to listener ${listenerId} (socket: ${listenerSocketId})`);
    } else {
      // Listener is not connected
      console.log(`[SOCKET] call:initiate: ✗ Listener ${listenerId} NOT online (no socket found)`);
      // Notify the caller that the listener is offline
      socket.emit('call:failed', { callId: callData.callId, reason: 'listener_offline' });
    }
  });

  // Accept call: Listener -> User
  socket.on('call:accept', (data) => {
    const { callId, callerId } = data;
    console.log(`[SOCKET] call:accept: Call ${callId} accepted by ${socket.userId}`);
    const callerSocketId = connectedUsers.get(callerId);
    if (callerSocketId) {
      io.to(callerSocketId).emit('call:accepted', {
        callId,
        listenerId: socket.userId
      });
    }
  });

  // Reject call: Listener -> User
  socket.on('call:reject', (data) => {
    const { callId, callerId } = data;
    console.log(`[SOCKET] call:reject: Call ${callId} rejected by ${socket.userId}`);
    const callerSocketId = connectedUsers.get(callerId);
    if (callerSocketId) {
      io.to(callerSocketId).emit('call:rejected', {
        callId,
        listenerId: socket.userId
      });
    }
  });

  // Joined Agora channel (for both parties)
  socket.on('call:joined', (data) => {
    const { callId, channelName } = data;
    const userId = socket.userId;
    if (!userId) return;

    console.log(`[SOCKET] User ${userId} joined channel ${channelName}`);
    
    if (!activeChannels.has(channelName)) {
      activeChannels.set(channelName, new Set());
    }
    activeChannels.get(channelName).add(userId);
    
    const usersInChannel = activeChannels.get(channelName);
    if (usersInChannel.size >= 2) {
      console.log(`[SOCKET] Both parties in ${channelName}, emitting call:connected`);
      usersInChannel.forEach(uid => {
        const sid = connectedUsers.get(uid);
        if (sid) {
          io.to(sid).emit('call:connected', { callId, channelName });
        }
      });
    }
  });

  // End call
  socket.on('call:end', (data) => {
    const { callId, otherUserId } = data;
    console.log(`[SOCKET] call:end: Call ${callId} ended by ${socket.userId}`);
    const otherSocketId = connectedUsers.get(otherUserId);
    if (otherSocketId) {
      io.to(otherSocketId).emit('call:ended', {
        callId,
        endedBy: socket.userId
      });
    }
  });

  // Leave channel
  socket.on('call:left', (data) => {
    const { channelName } = data;
    if (activeChannels.has(channelName) && socket.userId) {
      activeChannels.get(channelName).delete(socket.userId);
      if (activeChannels.get(channelName).size === 0) {
        activeChannels.delete(channelName);
      }
    }
  });

  // ============================================
  // 2.5 CHAT HANDLING (Real-time messaging)
  // ============================================

  // Join a chat room
  socket.on('chat:join', async (data) => {
    const { chatId, isActivelyViewing = true } = data || {};
    if (!chatId || !socket.userId) {
      console.log(`[SOCKET] chat:join failed - missing chatId or userId`);
      return;
    }

    // Join the Socket.IO room for this chat
    socket.join(`chat_${chatId}`);
    socket.chatRooms = socket.chatRooms || new Set();
    socket.chatRooms.add(chatId);
    
    // WhatsApp-style: Track which chat user is actively viewing
    if (isActivelyViewing) {
      const state = userChatState.get(socket.userId) || { appState: 'foreground' };
      state.activelyViewingChatId = chatId;
      userChatState.set(socket.userId, state);
    }
    
    console.log(`[SOCKET] User ${socket.userId} joined chat room: ${chatId} (activelyViewing: ${isActivelyViewing})`);

    // Fetch and send chat history
    try {
      const messages = await Message.getChatMessages(chatId, 50, 0);
      socket.emit('chat:history', {
        chatId,
        messages,
        count: messages.length
      });
    } catch (error) {
      console.error(`[SOCKET] Error fetching chat history:`, error);
      socket.emit('chat:error', { error: 'Failed to fetch chat history' });
    }
  });

  // Leave a chat room
  socket.on('chat:leave', (data) => {
    const { chatId } = data || {};
    if (!chatId) return;

    socket.leave(`chat_${chatId}`);
    if (socket.chatRooms) {
      socket.chatRooms.delete(chatId);
    }
    
    // WhatsApp-style: Clear actively viewing state
    const state = userChatState.get(socket.userId);
    if (state && state.activelyViewingChatId === chatId) {
      state.activelyViewingChatId = null;
      userChatState.set(socket.userId, state);
    }
    
    console.log(`[SOCKET] User ${socket.userId} left chat room: ${chatId}`);
  });

  // WhatsApp-style: Update which chat user is actively viewing
  socket.on('chat:set_active_viewing', (data) => {
    const { chatId, isActivelyViewing } = data || {};
    if (!socket.userId) return;
    
    const state = userChatState.get(socket.userId) || { appState: 'foreground' };
    state.activelyViewingChatId = isActivelyViewing ? chatId : null;
    userChatState.set(socket.userId, state);
    
    console.log(`[SOCKET] User ${socket.userId} set actively viewing: ${chatId || 'none'}`);
  });

  // WhatsApp-style: Track app foreground/background state
  socket.on('user:app_state', (data) => {
    const { userId, state: appState, activelyViewingChatId } = data || {};
    if (!userId) return;
    
    const chatState = userChatState.get(userId) || {};
    chatState.appState = appState || 'foreground';
    
    // Also update actively viewing chat if provided
    if (appState === 'background') {
      chatState.activelyViewingChatId = null; // Not viewing any chat when in background
    } else if (activelyViewingChatId !== undefined) {
      chatState.activelyViewingChatId = activelyViewingChatId;
    }
    
    userChatState.set(userId, chatState);
    console.log(`[SOCKET] User ${userId} app state: ${appState}, activeChat: ${chatState.activelyViewingChatId || 'none'}`);
  });

  // Send a message in a chat
  socket.on('chat:send', async (data) => {
    const { chatId, content, messageType = 'text', mediaUrl } = data || {};
    
    if (!chatId || !content || !socket.userId) {
      console.log(`[SOCKET] chat:send failed - missing required fields`);
      socket.emit('chat:error', { error: 'Missing required fields' });
      return;
    }

    try {
      // Save message to database (Chat & Message already imported at module level)
      const message = await Message.create({
        chat_id: chatId,
        sender_id: socket.userId,
        message_type: messageType,
        message_content: content,
        media_url: mediaUrl
      });

      const messageData = {
        chatId,
        message: {
          ...message,
          sender_name: socket.userName || 'Unknown',
          sender_avatar: socket.userAvatar
        }
      };

      // Broadcast message to all users in the chat room IMMEDIATELY (real-time UI update)
      io.to(`chat_${chatId}`).emit('chat:message', messageData);

      // Send notification to offline/non-viewing users asynchronously (don't block)
      Chat.findById(chatId).then(chat => {
        if (chat) {
          const otherUserId = chat.user1_id === socket.userId ? chat.user2_id : chat.user1_id;
          const otherUserState = userChatState.get(otherUserId);
          
          const isOtherUserViewingThisChat = otherUserState && 
            otherUserState.appState === 'foreground' && 
            otherUserState.activelyViewingChatId === chatId;
          
          if (!isOtherUserViewingThisChat) {
            io.to(`user_${otherUserId}`).emit('chat:new_message_notification', messageData);
            console.log(`[SOCKET] Sent notification to user_${otherUserId}`);
          }
        }
      }).catch(err => console.error('[SOCKET] Notification error:', err));

      console.log(`[SOCKET] Message sent in chat ${chatId} by ${socket.userId}`);
    } catch (error) {
      console.error(`[SOCKET] Error sending message:`, error);
      socket.emit('chat:error', { error: 'Failed to send message' });
    }
  });

  // Typing indicator
  socket.on('chat:typing', (data) => {
    const { chatId, isTyping } = data || {};
    if (!chatId || !socket.userId) return;

    // Broadcast typing status to others in the chat room (not the sender)
    socket.to(`chat_${chatId}`).emit('chat:user_typing', {
      chatId,
      userId: socket.userId,
      userName: socket.userName || 'Unknown',
      isTyping: isTyping === true
    });
  });

  // Mark messages as read
  socket.on('chat:read', async (data) => {
    const { chatId } = data || {};
    if (!chatId || !socket.userId) return;

    try {
      await Message.markAsRead(chatId, socket.userId);
      
      // Notify the other user that messages were read
      socket.to(`chat_${chatId}`).emit('chat:messages_read', {
        chatId,
        readBy: socket.userId
      });
    } catch (error) {
      console.error(`[SOCKET] Error marking messages as read:`, error);
    }
  });

  // WhatsApp-style: Delete message for everyone
  // This permanently deletes from DB and broadcasts to both users
  // Backend does NOT store placeholder text - that's client-side only
  socket.on('delete_message', async (data) => {
    const { messageId, chatId, senderId, receiverId } = data || {};
    
    if (!messageId || !senderId) {
      console.log(`[SOCKET] delete_message failed - missing messageId or senderId`);
      socket.emit('chat:error', { error: 'Missing required fields for delete' });
      return;
    }

    try {
      // Delete message from database (validates sender ownership)
      const result = await Message.delete(messageId, senderId);
      
      if (!result.success) {
        console.log(`[SOCKET] delete_message failed: ${result.error}`);
        socket.emit('chat:error', { error: result.error });
        return;
      }

      console.log(`[SOCKET] Message ${messageId} deleted from DB by ${senderId}`);

      // Broadcast delete event to all users in the chat room
      // Both sender and receiver will save this locally and show placeholder
      const deleteData = {
        messageId,
        chatId: result.chatId || chatId,
        deletedBy: senderId
      };

      // Emit to chat room (for users currently in the chat)
      io.to(`chat_${chatId}`).emit('message:deleted', deleteData);
      
      // Also emit to both users' personal rooms (in case they're not in chat room)
      io.to(`user_${senderId}`).emit('message:deleted', deleteData);
      if (receiverId) {
        io.to(`user_${receiverId}`).emit('message:deleted', deleteData);
      }

      console.log(`[SOCKET] Delete event broadcast for message ${messageId}`);
    } catch (error) {
      console.error(`[SOCKET] Error deleting message:`, error);
      socket.emit('chat:error', { error: 'Failed to delete message' });
    }
  });

  // 3. DISCONNECTION

  socket.on('disconnect', () => {
    const userId = socket.userId;
    const listenerUserId = socket.listenerUserId;

    console.log(`[SOCKET] Disconnected: ${socket.id} (User: ${userId}, Listener: ${listenerUserId})`);

    // Handle listener cleanup
    if (listenerUserId && listenerSockets.get(listenerUserId) === socket.id) {
      listenerSockets.delete(listenerUserId);
      io.emit('listener_status', { listenerUserId, online: false, timestamp: Date.now() });
      console.log(`[SOCKET] Listener marked offline: ${listenerUserId}`);
    }

    // Handle user cleanup and active calls
    if (userId) {
      // Notify others in active channels
      for (const [channelName, users] of activeChannels.entries()) {
        if (users.has(userId)) {
          users.forEach(otherUid => {
            if (otherUid !== userId) {
              const otherSid = connectedUsers.get(otherUid);
              if (otherSid) {
                io.to(otherSid).emit('call:ended', {
                  callId: channelName,
                  endedBy: userId,
                  reason: 'peer_disconnected'
                });
              }
            }
          });
          users.delete(userId);
          if (users.size === 0) activeChannels.delete(channelName);
        }
      }

      // Debounce offline status
      if (presenceTimeouts.has(userId)) {
        clearTimeout(presenceTimeouts.get(userId));
      }
      
      const timeoutId = setTimeout(async () => {
        const lastSeen = lastSeenMap.get(userId) || 0;
        if (Date.now() - lastSeen > 1000) {
          connectedUsers.delete(userId);
          lastSeenMap.delete(userId);
          presenceTimeouts.delete(userId);
          userChatState.delete(userId); // Clean up chat state on disconnect
          
          try {
            // await User.updateLastSeen(userId); 
          } catch (err) {}
          
          io.emit('user:offline', { userId });
          console.log(`[SOCKET] User ${userId} marked offline (debounce)`);
        }
      }, 1000);
      
      presenceTimeouts.set(userId, timeoutId);
    }
  });
});



// ============================================
// ERROR HANDLING
// ============================================

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    ...(config.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// ============================================
// SERVER STARTUP
// ============================================

const PORT = config.PORT;

async function startServer() {
  try {
    // Test database connection
    console.log('🔗 Connecting to AWS RDS PostgreSQL...');
    const connected = await testConnection();
    
    if (!connected) {
      console.error('❌ Failed to connect to database. Exiting...');
      process.exit(1);
    }

    // Ensure schema has required columns (safe, idempotent)
    try {
      await ensureSchema();
    } catch (err) {
      console.error('❌ Failed to ensure database schema:', err.message);
      process.exit(1);
    }

    // Start server
    server.listen(PORT, () => {
      console.log('\n' + '='.repeat(50));
      console.log(`🚀 Call To Backend Server`);
      console.log(`📡 Environment: ${config.NODE_ENV}`);
      console.log(`🌐 Server running on port ${PORT}`);
      console.log(`🔌 Socket.IO ready for connections`);
      console.log(`📊 API endpoints available at http://localhost:${PORT}/api`);
      console.log('='.repeat(50) + '\n');
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

// Start the server
startServer();

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('\n🛑 SIGTERM signal received: closing server gracefully');
  server.close(() => {
    console.log('✓ Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('\n🛑 SIGINT signal received: closing server gracefully');
  server.close(() => {
    console.log('✓ Server closed');
    process.exit(0);
  });
});

export { app, server, io };



















// import express from 'express';
// import http from 'http';
// import { Server } from 'socket.io';
// import cors from 'cors';
// import helmet from 'helmet';
// import morgan from 'morgan';
// import compression from 'compression';
// import rateLimit from 'express-rate-limit';
// import config from './config/config.js';
// import { testConnection, ensureSchema } from './db.js';
// // Initialize Express app
// const app = express();
// const server = http.createServer(app);
// const io = new Server(server, {
//   cors: config.cors,
//   pingTimeout: config.socketIO.pingTimeout,
//   pingInterval: config.socketIO.pingInterval
// });

// // Import routes
// import authRoutes from './routes/auth.js';
// import userRoutes from './routes/users.js';
// import listenerRoutes from './routes/listeners.js';
// import callRoutes from './routes/calls.js';
// import chatRoutes from './routes/chats.js';
// import adminRoutes from './routes/admin.js';
// import User from './models/User.js';

// // ============================================
// // MIDDLEWARE
// // ============================================

// // Security middleware
// app.use(helmet());

// // CORS
// app.use(cors(config.cors));

// // Body parsing
// app.use(express.json({ limit: '10mb' }));
// app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// // Compression
// app.use(compression());

// // Logging
// if (config.NODE_ENV === 'development') {
//   app.use(morgan('dev'));
// } else {
//   app.use(morgan('combined'));
// }

// // Rate limiting
// const limiter = rateLimit({
//   windowMs: config.rateLimit.windowMs,
//   max: config.rateLimit.max,
//   message: 'Too many requests from this IP, please try again later.'
// });
// app.use('/api/', limiter);

// // ============================================
// // ROUTES
// // ============================================

// // Health check
// app.get('/', (req, res) => {
//   res.json({
//     message: 'Call To API Server',
//     version: '1.0.0',
//     status: 'running'
//   });
// });

// // API health check
// app.get('/api/health', async (req, res) => {
//   try {
//     const dbConnected = await testConnection();
//     res.json({
//       status: 'healthy',
//       database: dbConnected ? 'connected' : 'disconnected',
//       timestamp: new Date().toISOString()
//     });
//   } catch (error) {
//     res.status(500).json({
//       status: 'unhealthy',
//       error: error.message
//     });
//   }
// });

// // Mount API routes
// app.use('/api/auth', authRoutes);
// app.use('/api/users', userRoutes);
// app.use('/api/listeners', listenerRoutes);
// app.use('/api/calls', callRoutes);
// app.use('/api/chats', chatRoutes);
// app.use('/api/admin', adminRoutes);

// // ============================================
// // SOCKET.IO - REAL-TIME FEATURES
// // ============================================



// // In-memory maps
// const connectedUsers = new Map(); // Map of userId -> socketId
// const listenerSockets = new Map(); // Map of listenerUserId -> socketId
// const activeChannels = new Map(); // Map of channelName -> Set of userIds in channel
// const lastSeenMap = new Map(); // Map of userId -> timestamp
// const presenceTimeouts = new Map(); // Map of userId -> timeoutId

// // Socket.IO connection handler
// io.on('connection', (socket) => {
//   console.log(`[SOCKET] Connected: ${socket.id}`);

//   // 1. IDENTITY & PRESENCE
  
//   // User joins (can be regular user or listener)
//   socket.on('user:join', (userId) => {
//     if (!userId) return;
//     socket.userId = userId;
//     connectedUsers.set(userId, socket.id);
//     lastSeenMap.set(userId, Date.now());
    
//     // Clear any pending offline timeout
//     if (presenceTimeouts.has(userId)) {
//       clearTimeout(presenceTimeouts.get(userId));
//       presenceTimeouts.delete(userId);
//     }
    
//     io.emit('user:online', { userId });
//     console.log(`[SOCKET] User joined: ${userId}`);

//     // Send current online listeners to the newly joined user
//     const onlineListeners = Array.from(listenerSockets.keys());
//     socket.emit('listeners:initial_status', onlineListeners);
//   });

//   // Listener specific join (for availability tracking)
//   socket.on('listener:join', (listenerUserId) => {
//     if (!listenerUserId) return;
//     socket.userId = listenerUserId; // Sync with userId
//     socket.listenerUserId = listenerUserId;
    
//     // Remove old socket if exists to prevent ghost sessions
//     if (listenerSockets.has(listenerUserId)) {
//       const oldSocketId = listenerSockets.get(listenerUserId);
//       if (oldSocketId && oldSocketId !== socket.id) {
//         const oldSocket = io.sockets.sockets.get(oldSocketId);
//         if (oldSocket) oldSocket.disconnect(true);
//       }
//     }
    
//     listenerSockets.set(listenerUserId, socket.id);
//     connectedUsers.set(listenerUserId, socket.id); // Also ensure in connectedUsers
    
//     io.emit('listener_status', { listenerUserId, online: true, timestamp: Date.now() });
//     console.log(`[SOCKET] Listener joined: ${listenerUserId}`);
//   });

//   // Explicit offline event
//   socket.on('listener:offline', (data) => {
//     const { listenerUserId } = data || {};
//     if (listenerUserId) {
//       listenerSockets.delete(listenerUserId);
//       io.emit('listener_status', { listenerUserId, online: false, timestamp: Date.now() });
//       console.log(`[SOCKET] Listener offline: ${listenerUserId}`);
//     }
//   });

//   // 2. CALL HANDLING

//   // Initiate call: User -> Listener
//   socket.on('call:initiate', (data) => {
//     const { listenerId, ...callData } = data || {};
//     // Check both maps for the listener's socket
//     const listenerSocketId = listenerSockets.get(listenerId) || connectedUsers.get(listenerId);
    
//     if (listenerSocketId) {
//       io.to(listenerSocketId).emit('incoming-call', callData);
//       console.log(`[SOCKET] call:initiate: Forwarded to listener ${listenerId}`);
//     } else {
//       console.log(`[SOCKET] call:initiate: Listener ${listenerId} NOT online`);
//       // Optionally notify the caller that the listener is offline
//       socket.emit('call:failed', { callId: callData.callId, reason: 'listener_offline' });
//     }
//   });

//   // Accept call: Listener -> User
//   socket.on('call:accept', (data) => {
//     const { callId, callerId } = data;
//     console.log(`[SOCKET] call:accept: Call ${callId} accepted by ${socket.userId}`);
//     const callerSocketId = connectedUsers.get(callerId);
//     if (callerSocketId) {
//       io.to(callerSocketId).emit('call:accepted', {
//         callId,
//         listenerId: socket.userId
//       });
//     }
//   });

//   // Reject call: Listener -> User
//   socket.on('call:reject', (data) => {
//     const { callId, callerId } = data;
//     console.log(`[SOCKET] call:reject: Call ${callId} rejected by ${socket.userId}`);
//     const callerSocketId = connectedUsers.get(callerId);
//     if (callerSocketId) {
//       io.to(callerSocketId).emit('call:rejected', {
//         callId,
//         listenerId: socket.userId
//       });
//     }
//   });

//   // Joined Agora channel (for both parties)
//   socket.on('call:joined', (data) => {
//     const { callId, channelName } = data;
//     const userId = socket.userId;
//     if (!userId) return;

//     console.log(`[SOCKET] User ${userId} joined channel ${channelName}`);
    
//     if (!activeChannels.has(channelName)) {
//       activeChannels.set(channelName, new Set());
//     }
//     activeChannels.get(channelName).add(userId);
    
//     const usersInChannel = activeChannels.get(channelName);
//     if (usersInChannel.size >= 2) {
//       console.log(`[SOCKET] Both parties in ${channelName}, emitting call:connected`);
//       usersInChannel.forEach(uid => {
//         const sid = connectedUsers.get(uid);
//         if (sid) {
//           io.to(sid).emit('call:connected', { callId, channelName });
//         }
//       });
//     }
//   });

//   // End call
//   socket.on('call:end', (data) => {
//     const { callId, otherUserId } = data;
//     console.log(`[SOCKET] call:end: Call ${callId} ended by ${socket.userId}`);
//     const otherSocketId = connectedUsers.get(otherUserId);
//     if (otherSocketId) {
//       io.to(otherSocketId).emit('call:ended', {
//         callId,
//         endedBy: socket.userId
//       });
//     }
//   });

//   // Leave channel
//   socket.on('call:left', (data) => {
//     const { channelName } = data;
//     if (activeChannels.has(channelName) && socket.userId) {
//       activeChannels.get(channelName).delete(socket.userId);
//       if (activeChannels.get(channelName).size === 0) {
//         activeChannels.delete(channelName);
//       }
//     }
//   });

//   // 3. DISCONNECTION

//   socket.on('disconnect', () => {
//     const userId = socket.userId;
//     const listenerUserId = socket.listenerUserId;

//     console.log(`[SOCKET] Disconnected: ${socket.id} (User: ${userId}, Listener: ${listenerUserId})`);

//     // Handle listener cleanup
//     if (listenerUserId && listenerSockets.get(listenerUserId) === socket.id) {
//       listenerSockets.delete(listenerUserId);
//       io.emit('listener_status', { listenerUserId, online: false, timestamp: Date.now() });
//       console.log(`[SOCKET] Listener marked offline: ${listenerUserId}`);
//     }

//     // Handle user cleanup and active calls
//     if (userId) {
//       // Notify others in active channels
//       for (const [channelName, users] of activeChannels.entries()) {
//         if (users.has(userId)) {
//           users.forEach(otherUid => {
//             if (otherUid !== userId) {
//               const otherSid = connectedUsers.get(otherUid);
//               if (otherSid) {
//                 io.to(otherSid).emit('call:ended', {
//                   callId: channelName,
//                   endedBy: userId,
//                   reason: 'peer_disconnected'
//                 });
//               }
//             }
//           });
//           users.delete(userId);
//           if (users.size === 0) activeChannels.delete(channelName);
//         }
//       }

//       // Debounce offline status
//       if (presenceTimeouts.has(userId)) {
//         clearTimeout(presenceTimeouts.get(userId));
//       }
      
//       const timeoutId = setTimeout(async () => {
//         const lastSeen = lastSeenMap.get(userId) || 0;
//         if (Date.now() - lastSeen > 1000) {
//           connectedUsers.delete(userId);
//           lastSeenMap.delete(userId);
//           presenceTimeouts.delete(userId);
          
//           try {
//             // await User.updateLastSeen(userId); 
//           } catch (err) {}
          
//           io.emit('user:offline', { userId });
//           console.log(`[SOCKET] User ${userId} marked offline (debounce)`);
//         }
//       }, 1000);
      
//       presenceTimeouts.set(userId, timeoutId);
//     }
//   });
// });



// // ============================================
// // ERROR HANDLING
// // ============================================

// // 404 handler
// app.use((req, res) => {
//   res.status(404).json({
//     error: 'Route not found',
//     path: req.originalUrl
//   });
// });

// // Global error handler
// app.use((err, req, res, next) => {
//   console.error('Error:', err);
  
//   res.status(err.status || 500).json({
//     error: err.message || 'Internal server error',
//     ...(config.NODE_ENV === 'development' && { stack: err.stack })
//   });
// });

// // ============================================
// // SERVER STARTUP
// // ============================================

// const PORT = config.PORT;

// async function startServer() {
//   try {
//     // Test database connection
//     console.log('🔗 Connecting to AWS RDS PostgreSQL...');
//     const connected = await testConnection();
    
//     if (!connected) {
//       console.error('❌ Failed to connect to database. Exiting...');
//       process.exit(1);
//     }

//     // Ensure schema has required columns (safe, idempotent)
//     try {
//       await ensureSchema();
//     } catch (err) {
//       console.error('❌ Failed to ensure database schema:', err.message);
//       process.exit(1);
//     }

//     // Start server
//     server.listen(PORT, () => {
//       console.log('\n' + '='.repeat(50));
//       console.log(`🚀 Call To Backend Server`);
//       console.log(`📡 Environment: ${config.NODE_ENV}`);
//       console.log(`🌐 Server running on port ${PORT}`);
//       console.log(`🔌 Socket.IO ready for connections`);
//       console.log(`📊 API endpoints available at http://localhost:${PORT}/api`);
//       console.log('='.repeat(50) + '\n');
//     });
//   } catch (error) {
//     console.error('❌ Failed to start server:', error);
//     process.exit(1);
//   }
// }

// // Start the server
// startServer();

// // Handle graceful shutdown
// process.on('SIGTERM', () => {
//   console.log('\n🛑 SIGTERM signal received: closing server gracefully');
//   server.close(() => {
//     console.log('✓ Server closed');
//     process.exit(0);
//   });
// });

// process.on('SIGINT', () => {
//   console.log('\n🛑 SIGINT signal received: closing server gracefully');
//   server.close(() => {
//     console.log('✓ Server closed');
//     process.exit(0);
//   });
// });

// export { app, server, io };import express from 'express';
// import http from 'http';
// import { Server } from 'socket.io';
// import cors from 'cors';
// import helmet from 'helmet';
// import morgan from 'morgan';
// import compression from 'compression';
// import rateLimit from 'express-rate-limit';
// import config from './config/config.js';
// import { testConnection, ensureSchema } from './db.js';
// // Initialize Express app
// const app = express();
// const server = http.createServer(app);
// const io = new Server(server, {
//   cors: config.cors,
//   pingTimeout: config.socketIO.pingTimeout,
//   pingInterval: config.socketIO.pingInterval
// });

// // Import routes
// import authRoutes from './routes/auth.js';
// import userRoutes from './routes/users.js';
// import listenerRoutes from './routes/listeners.js';
// import callRoutes from './routes/calls.js';
// import chatRoutes from './routes/chats.js';
// import adminRoutes from './routes/admin.js';
// import User from './models/User.js';

// // ============================================
// // MIDDLEWARE
// // ============================================

// // Security middleware
// app.use(helmet());

// // CORS
// app.use(cors(config.cors));

// // Body parsing
// app.use(express.json({ limit: '10mb' }));
// app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// // Compression
// app.use(compression());

// // Logging
// if (config.NODE_ENV === 'development') {
//   app.use(morgan('dev'));
// } else {
//   app.use(morgan('combined'));
// }

// // Rate limiting
// const limiter = rateLimit({
//   windowMs: config.rateLimit.windowMs,
//   max: config.rateLimit.max,
//   message: 'Too many requests from this IP, please try again later.'
// });
// app.use('/api/', limiter);

// // ============================================
// // ROUTES
// // ============================================

// // Health check
// app.get('/', (req, res) => {
//   res.json({
//     message: 'Call To API Server',
//     version: '1.0.0',
//     status: 'running'
//   });
// });

// // API health check
// app.get('/api/health', async (req, res) => {
//   try {
//     const dbConnected = await testConnection();
//     res.json({
//       status: 'healthy',
//       database: dbConnected ? 'connected' : 'disconnected',
//       timestamp: new Date().toISOString()
//     });
//   } catch (error) {
//     res.status(500).json({
//       status: 'unhealthy',
//       error: error.message
//     });
//   }
// });

// // Mount API routes
// app.use('/api/auth', authRoutes);
// app.use('/api/users', userRoutes);
// app.use('/api/listeners', listenerRoutes);
// app.use('/api/calls', callRoutes);
// app.use('/api/chats', chatRoutes);
// app.use('/api/admin', adminRoutes);

// // ============================================
// // SOCKET.IO - REAL-TIME FEATURES
// // ============================================



// // In-memory maps
// const connectedUsers = new Map(); // Map of userId -> socketId
// const listenerSockets = new Map(); // Map of listenerUserId -> socketId
// const activeChannels = new Map(); // Map of channelName -> Set of userIds in channel
// const lastSeenMap = new Map(); // Map of userId -> timestamp
// const presenceTimeouts = new Map(); // Map of userId -> timeoutId

// // Socket.IO connection handler
// io.on('connection', (socket) => {
//   console.log(`[SOCKET] Connected: ${socket.id}`);

//   // 1. IDENTITY & PRESENCE
  
//   // User joins (can be regular user or listener)
//   socket.on('user:join', (userId) => {
//     if (!userId) return;
//     socket.userId = userId;
//     connectedUsers.set(userId, socket.id);
//     lastSeenMap.set(userId, Date.now());
    
//     // Clear any pending offline timeout
//     if (presenceTimeouts.has(userId)) {
//       clearTimeout(presenceTimeouts.get(userId));
//       presenceTimeouts.delete(userId);
//     }
    
//     io.emit('user:online', { userId });
//     console.log(`[SOCKET] User joined: ${userId}`);

//     // Send current online listeners to the newly joined user
//     const onlineListeners = Array.from(listenerSockets.keys());
//     socket.emit('listeners:initial_status', onlineListeners);
//   });

//   // Listener specific join (for availability tracking)
//   socket.on('listener:join', (listenerUserId) => {
//     if (!listenerUserId) return;
//     socket.userId = listenerUserId; // Sync with userId
//     socket.listenerUserId = listenerUserId;
    
//     // Remove old socket if exists to prevent ghost sessions
//     if (listenerSockets.has(listenerUserId)) {
//       const oldSocketId = listenerSockets.get(listenerUserId);
//       if (oldSocketId && oldSocketId !== socket.id) {
//         const oldSocket = io.sockets.sockets.get(oldSocketId);
//         if (oldSocket) oldSocket.disconnect(true);
//       }
//     }
    
//     listenerSockets.set(listenerUserId, socket.id);
//     connectedUsers.set(listenerUserId, socket.id); // Also ensure in connectedUsers
    
//     io.emit('listener_status', { listenerUserId, online: true, timestamp: Date.now() });
//     console.log(`[SOCKET] Listener joined: ${listenerUserId}`);
//   });

//   // Explicit offline event
//   socket.on('listener:offline', (data) => {
//     const { listenerUserId } = data || {};
//     if (listenerUserId) {
//       listenerSockets.delete(listenerUserId);
//       io.emit('listener_status', { listenerUserId, online: false, timestamp: Date.now() });
//       console.log(`[SOCKET] Listener offline: ${listenerUserId}`);
//     }
//   });

//   // 2. CALL HANDLING

//   // Initiate call: User -> Listener
//   socket.on('call:initiate', (data) => {
//     const { listenerId, ...callData } = data || {};
//     // Check both maps for the listener's socket
//     const listenerSocketId = listenerSockets.get(listenerId) || connectedUsers.get(listenerId);
    
//     if (listenerSocketId) {
//       io.to(listenerSocketId).emit('incoming-call', callData);
//       console.log(`[SOCKET] call:initiate: Forwarded to listener ${listenerId}`);
//     } else {
//       console.log(`[SOCKET] call:initiate: Listener ${listenerId} NOT online`);
//       // Optionally notify the caller that the listener is offline
//       socket.emit('call:failed', { callId: callData.callId, reason: 'listener_offline' });
//     }
//   });

//   // Accept call: Listener -> User
//   socket.on('call:accept', (data) => {
//     const { callId, callerId } = data;
//     console.log(`[SOCKET] call:accept: Call ${callId} accepted by ${socket.userId}`);
//     const callerSocketId = connectedUsers.get(callerId);
//     if (callerSocketId) {
//       io.to(callerSocketId).emit('call:accepted', {
//         callId,
//         listenerId: socket.userId
//       });
//     }
//   });

//   // Reject call: Listener -> User
//   socket.on('call:reject', (data) => {
//     const { callId, callerId } = data;
//     console.log(`[SOCKET] call:reject: Call ${callId} rejected by ${socket.userId}`);
//     const callerSocketId = connectedUsers.get(callerId);
//     if (callerSocketId) {
//       io.to(callerSocketId).emit('call:rejected', {
//         callId,
//         listenerId: socket.userId
//       });
//     }
//   });

//   // Joined Agora channel (for both parties)
//   socket.on('call:joined', (data) => {
//     const { callId, channelName } = data;
//     const userId = socket.userId;
//     if (!userId) return;

//     console.log(`[SOCKET] User ${userId} joined channel ${channelName}`);
    
//     if (!activeChannels.has(channelName)) {
//       activeChannels.set(channelName, new Set());
//     }
//     activeChannels.get(channelName).add(userId);
    
//     const usersInChannel = activeChannels.get(channelName);
//     if (usersInChannel.size >= 2) {
//       console.log(`[SOCKET] Both parties in ${channelName}, emitting call:connected`);
//       usersInChannel.forEach(uid => {
//         const sid = connectedUsers.get(uid);
//         if (sid) {
//           io.to(sid).emit('call:connected', { callId, channelName });
//         }
//       });
//     }
//   });

//   // End call
//   socket.on('call:end', (data) => {
//     const { callId, otherUserId } = data;
//     console.log(`[SOCKET] call:end: Call ${callId} ended by ${socket.userId}`);
//     const otherSocketId = connectedUsers.get(otherUserId);
//     if (otherSocketId) {
//       io.to(otherSocketId).emit('call:ended', {
//         callId,
//         endedBy: socket.userId
//       });
//     }
//   });

//   // Leave channel
//   socket.on('call:left', (data) => {
//     const { channelName } = data;
//     if (activeChannels.has(channelName) && socket.userId) {
//       activeChannels.get(channelName).delete(socket.userId);
//       if (activeChannels.get(channelName).size === 0) {
//         activeChannels.delete(channelName);
//       }
//     }
//   });

//   // 3. DISCONNECTION

//   socket.on('disconnect', () => {
//     const userId = socket.userId;
//     const listenerUserId = socket.listenerUserId;

//     console.log(`[SOCKET] Disconnected: ${socket.id} (User: ${userId}, Listener: ${listenerUserId})`);

//     // Handle listener cleanup
//     if (listenerUserId && listenerSockets.get(listenerUserId) === socket.id) {
//       listenerSockets.delete(listenerUserId);
//       io.emit('listener_status', { listenerUserId, online: false, timestamp: Date.now() });
//       console.log(`[SOCKET] Listener marked offline: ${listenerUserId}`);
//     }

//     // Handle user cleanup and active calls
//     if (userId) {
//       // Notify others in active channels
//       for (const [channelName, users] of activeChannels.entries()) {
//         if (users.has(userId)) {
//           users.forEach(otherUid => {
//             if (otherUid !== userId) {
//               const otherSid = connectedUsers.get(otherUid);
//               if (otherSid) {
//                 io.to(otherSid).emit('call:ended', {
//                   callId: channelName,
//                   endedBy: userId,
//                   reason: 'peer_disconnected'
//                 });
//               }
//             }
//           });
//           users.delete(userId);
//           if (users.size === 0) activeChannels.delete(channelName);
//         }
//       }

//       // Debounce offline status
//       if (presenceTimeouts.has(userId)) {
//         clearTimeout(presenceTimeouts.get(userId));
//       }
      
//       const timeoutId = setTimeout(async () => {
//         const lastSeen = lastSeenMap.get(userId) || 0;
//         if (Date.now() - lastSeen > 1000) {
//           connectedUsers.delete(userId);
//           lastSeenMap.delete(userId);
//           presenceTimeouts.delete(userId);
          
//           try {
//             // await User.updateLastSeen(userId); 
//           } catch (err) {}
          
//           io.emit('user:offline', { userId });
//           console.log(`[SOCKET] User ${userId} marked offline (debounce)`);
//         }
//       }, 1000);
      
//       presenceTimeouts.set(userId, timeoutId);
//     }
//   });
// });



// // ============================================
// // ERROR HANDLING
// // ============================================

// // 404 handler
// app.use((req, res) => {
//   res.status(404).json({
//     error: 'Route not found',
//     path: req.originalUrl
//   });
// });

// // Global error handler
// app.use((err, req, res, next) => {
//   console.error('Error:', err);
  
//   res.status(err.status || 500).json({
//     error: err.message || 'Internal server error',
//     ...(config.NODE_ENV === 'development' && { stack: err.stack })
//   });
// });

// // ============================================
// // SERVER STARTUP
// // ============================================

// const PORT = config.PORT;

// async function startServer() {
//   try {
//     // Test database connection
//     console.log('🔗 Connecting to AWS RDS PostgreSQL...');
//     const connected = await testConnection();
    
//     if (!connected) {
//       console.error('❌ Failed to connect to database. Exiting...');
//       process.exit(1);
//     }

//     // Ensure schema has required columns (safe, idempotent)
//     try {
//       await ensureSchema();
//     } catch (err) {
//       console.error('❌ Failed to ensure database schema:', err.message);
//       process.exit(1);
//     }

//     // Start server
//     server.listen(PORT, () => {
//       console.log('\n' + '='.repeat(50));
//       console.log(`🚀 Call To Backend Server`);
//       console.log(`📡 Environment: ${config.NODE_ENV}`);
//       console.log(`🌐 Server running on port ${PORT}`);
//       console.log(`🔌 Socket.IO ready for connections`);
//       console.log(`📊 API endpoints available at http://localhost:${PORT}/api`);
//       console.log('='.repeat(50) + '\n');
//     });
//   } catch (error) {
//     console.error('❌ Failed to start server:', error);
//     process.exit(1);
//   }
// }

// // Start the server
// startServer();

// // Handle graceful shutdown
// process.on('SIGTERM', () => {
//   console.log('\n🛑 SIGTERM signal received: closing server gracefully');
//   server.close(() => {
//     console.log('✓ Server closed');
//     process.exit(0);
//   });
// });

// process.on('SIGINT', () => {
//   console.log('\n🛑 SIGINT signal received: closing server gracefully');
//   server.close(() => {
//     console.log('✓ Server closed');
//     process.exit(0);
//   });
// });

// export { app, server, io };