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

// Socket.IO connection handler
io.on('connection', (socket) => {
    // Handle call:initiate from Flutter: emit incoming-call to callee
    socket.on('call:initiate', (data) => {
      const { listenerId, ...callData } = data || {};
      const listenerSocketId = connectedUsers.get(listenerId) || listenerSockets.get(listenerId);
      if (listenerSocketId) {
        io.to(listenerSocketId).emit('incoming-call', callData);
        console.log(`[SOCKET] call:initiate: sent incoming-call to ${listenerId}`);
      } else {
        console.log(`[SOCKET] call:initiate: listener ${listenerId} not online`);
      }
    });
  console.log(`SOCKET CONNECTED: ${socket.id}`);

  // Listener joins with their user_id
  socket.on('listener:join', (listenerUserId) => {
    if (!listenerUserId) return;
    // Remove old socket if exists
    if (listenerSockets.has(listenerUserId)) {
      const oldSocketId = listenerSockets.get(listenerUserId);
      if (oldSocketId && oldSocketId !== socket.id) {
        // Disconnect old socket
        const oldSocket = io.sockets.sockets.get(oldSocketId);
        if (oldSocket) {
          oldSocket.disconnect(true);
        }
      }
    }
    listenerSockets.set(listenerUserId, socket.id);
    socket.listenerUserId = listenerUserId;
    // --- FIX: Always emit online status immediately ---
    io.emit('listener_status', { listenerUserId, online: true, timestamp: Date.now() });
    console.log(`[SOCKET] io.emit listener_status ONLINE for ${listenerUserId}`);
  });

  // Explicit offline event (for app background)
  socket.on('listener:offline', (data) => {
    const { listenerUserId } = data || {};
    if (listenerUserId && listenerSockets.has(listenerUserId)) {
      listenerSockets.delete(listenerUserId);
      // --- FIX: Only emit offline if truly offline ---
      io.emit('listener_status', { listenerUserId, online: false, timestamp: Date.now() });
      console.log(`[SOCKET] io.emit listener_status OFFLINE for ${listenerUserId}`);
    }
  });

  // On disconnect, mark listener as offline
  socket.on('disconnect', () => {
    if (socket.listenerUserId && listenerSockets.has(socket.listenerUserId)) {
      listenerSockets.delete(socket.listenerUserId);
      io.emit('listener_status', { listenerUserId: socket.listenerUserId, online: false, timestamp: Date.now() });
      console.log(`[SOCKET] DISCONNECT: listenerUserId=${socket.listenerUserId}, socket.id=${socket.id}`);
    }
    console.log(`SOCKET DISCONNECTED: ${socket.id}`);
  });

  // Call accept
  socket.on('call:accept', (data) => {
    const { callId, callerId } = data;
    console.log(`✓ Call ${callId} accepted by ${socket.userId}`);
    const callerSocketId = connectedUsers.get(callerId);
    if (callerSocketId) {
      io.to(callerSocketId).emit('call:accepted', {
        callId,
        listenerId: socket.userId
      });
    }
  });

  // When a user joins an Agora channel (for web simulation)
  socket.on('call:joined', (data) => {
    const { callId, channelName } = data;
    console.log(`📱 User ${socket.userId} joined channel ${channelName}`);
    // Track users in this channel
    if (!activeChannels.has(channelName)) {
      activeChannels.set(channelName, new Set());
    }
    activeChannels.get(channelName).add(socket.userId);
    const usersInChannel = activeChannels.get(channelName);
    console.log(`   Users in channel ${channelName}:`, Array.from(usersInChannel));
    // If 2 users are in the channel, notify both that call is connected
    if (usersInChannel.size >= 2) {
      console.log(`✓ Both parties in channel ${channelName}, sending call:connected`);
      usersInChannel.forEach(userId => {
        const userSocketId = connectedUsers.get(userId);
        if (userSocketId) {
          io.to(userSocketId).emit('call:connected', {
            callId,
            channelName
          });
        }
      });
    }
  });

  // When a user leaves a channel
  socket.on('call:left', (data) => {
    const { channelName } = data;
    if (activeChannels.has(channelName)) {
      activeChannels.get(channelName).delete(socket.userId);
      if (activeChannels.get(channelName).size === 0) {
        activeChannels.delete(channelName);
      }
    }
  });

  // Call reject
  socket.on('call:reject', (data) => {
    const { callId, callerId } = data;
    const callerSocketId = connectedUsers.get(callerId);
    if (callerSocketId) {
      io.to(callerSocketId).emit('call:rejected', {
        callId,
        listenerId: socket.userId
      });
    }
  });

  // Call end
  socket.on('call:end', (data) => {
    const { callId, otherUserId } = data;
    const otherSocketId = connectedUsers.get(otherUserId);
    if (otherSocketId) {
      io.to(otherSocketId).emit('call:ended', {
        callId,
        endedBy: socket.userId
      });
    }
  });

  // Disconnect - notify other users in active channels
  socket.on('disconnect', () => {
    if (socket.userId) {
      // Find all channels this user was in and notify other participants
      for (const [channelName, users] of activeChannels.entries()) {
        if (users.has(socket.userId)) {
          // Notify all other users in this channel that this user left
          users.forEach(userId => {
            if (userId !== socket.userId) {
              const otherSocketId = connectedUsers.get(userId);
              if (otherSocketId) {
                console.log(`📞 Notifying ${userId} that ${socket.userId} disconnected from ${channelName}`);
                io.to(otherSocketId).emit('call:ended', {
                  callId: channelName,
                  endedBy: socket.userId,
                  reason: 'peer_disconnected'
                });
              }
            }
          });
          // Remove user from channel
          users.delete(socket.userId);
          if (users.size === 0) {
            activeChannels.delete(channelName);
          }
        }
      }

      // Debounce offline: wait 1s before marking offline, cancel if heartbeat comes in
      if (presenceTimeouts.has(socket.userId)) {
        clearTimeout(presenceTimeouts.get(socket.userId));
      }
      const timeoutId = setTimeout(async () => {
        // Only mark offline if lastSeen is >1s ago
        const lastSeen = lastSeenMap.get(socket.userId) || 0;
        if (Date.now() - lastSeen > 1000) {
          connectedUsers.delete(socket.userId);
          lastSeenMap.delete(socket.userId);
          presenceTimeouts.delete(socket.userId);
          // Update DB last_seen
          try {
            await User.updateLastSeen(socket.userId);
          } catch (err) {
            console.error('Failed to update last_seen in DB:', err);
          }
          io.emit('user:offline', { userId: socket.userId });
          console.log(`User ${socket.userId} marked offline after debounce`);
        }
      }, 1000);
      presenceTimeouts.set(socket.userId, timeoutId);
      console.log(`User ${socket.userId} disconnected, will mark offline in 1s if no heartbeat`);
    }
    console.log(`✗ Socket disconnected: ${socket.id}`);
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
