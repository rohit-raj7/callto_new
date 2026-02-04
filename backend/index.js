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
import chatRoutes from './routes/chats.js';
import adminRoutes from './routes/admin.js';
import User from './models/User.js';

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
app.use('/api/chats', chatRoutes);
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

// Socket.IO connection handler
io.on('connection', (socket) => {
  console.log(`[SOCKET] Connected: ${socket.id}`);

  // 1. IDENTITY & PRESENCE
  
  // User joins (can be regular user or listener)
  socket.on('user:join', (userId) => {
    if (!userId) return;
    socket.userId = userId;
    connectedUsers.set(userId, socket.id);
    lastSeenMap.set(userId, Date.now());
    
    // Clear any pending offline timeout
    if (presenceTimeouts.has(userId)) {
      clearTimeout(presenceTimeouts.get(userId));
      presenceTimeouts.delete(userId);
    }
    
    io.emit('user:online', { userId });
    console.log(`[SOCKET] User joined: ${userId}`);

    // Send current online listeners to the newly joined user
    const onlineListeners = Array.from(listenerSockets.keys());
    socket.emit('listeners:initial_status', onlineListeners);
  });

  // Listener specific join (for availability tracking)
  socket.on('listener:join', (listenerUserId) => {
    if (!listenerUserId) return;
    socket.userId = listenerUserId; // Sync with userId
    socket.listenerUserId = listenerUserId;
    
    // Remove old socket if exists to prevent ghost sessions
    if (listenerSockets.has(listenerUserId)) {
      const oldSocketId = listenerSockets.get(listenerUserId);
      if (oldSocketId && oldSocketId !== socket.id) {
        const oldSocket = io.sockets.sockets.get(oldSocketId);
        if (oldSocket) oldSocket.disconnect(true);
      }
    }
    
    listenerSockets.set(listenerUserId, socket.id);
    connectedUsers.set(listenerUserId, socket.id); // Also ensure in connectedUsers
    
    io.emit('listener_status', { listenerUserId, online: true, timestamp: Date.now() });
    console.log(`[SOCKET] Listener joined: ${listenerUserId}`);
  });

  // Explicit offline event
  socket.on('listener:offline', (data) => {
    const { listenerUserId } = data || {};
    if (listenerUserId) {
      listenerSockets.delete(listenerUserId);
      io.emit('listener_status', { listenerUserId, online: false, timestamp: Date.now() });
      console.log(`[SOCKET] Listener offline: ${listenerUserId}`);
    }
  });

  // 2. CALL HANDLING

  // Initiate call: User -> Listener
  socket.on('call:initiate', (data) => {
    const { listenerId, ...callData } = data || {};
    // Check both maps for the listener's socket
    const listenerSocketId = listenerSockets.get(listenerId) || connectedUsers.get(listenerId);
    
    if (listenerSocketId) {
      io.to(listenerSocketId).emit('incoming-call', callData);
      console.log(`[SOCKET] call:initiate: Forwarded to listener ${listenerId}`);
    } else {
      console.log(`[SOCKET] call:initiate: Listener ${listenerId} NOT online`);
      // Optionally notify the caller that the listener is offline
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
