import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_config.dart';
import 'storage_service.dart';

/// Incoming call data model
class IncomingCall {
  final String callId;
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String? topic;
  final String? language;
  final String? gender;
  final int? age;
  final DateTime timestamp;
  int waitTimeSeconds;

  IncomingCall({
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    this.topic,
    this.language,
    this.gender,
    this.age,
    required this.timestamp,
    this.waitTimeSeconds = 0,
  });

  factory IncomingCall.fromJson(Map<String, dynamic> json) {
    final avatarUrl = json['caller_avatar'] ?? json['callerAvatar'];
    print('[IncomingCall] Parsing call - callerName: ${json['caller_name'] ?? json['callerName']}, callerAvatar: $avatarUrl');
    return IncomingCall(
      callId: json['call_id']?.toString() ?? json['callId']?.toString() ?? '',
      callerId: json['caller_id']?.toString() ?? json['callerId']?.toString() ?? '',
      callerName: json['caller_name'] ?? json['callerName'] ?? 'Unknown',
      callerAvatar: avatarUrl,
      topic: json['topic'],
      language: json['language'] ?? 'English',
      gender: json['gender'],
      age: json['age'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'call_id': callId,
    'caller_id': callerId,
    'caller_name': callerName,
    'caller_avatar': callerAvatar,
    'topic': topic,
    'language': language,
    'gender': gender,
    'age': age,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Socket service for real-time communication
class SocketService {
    // Private controller fields
    StreamController<IncomingCall>? _incomingCallController;
    StreamController<Map<String, dynamic>>? _callAcceptedController;
    StreamController<Map<String, dynamic>>? _callRejectedController;
    StreamController<Map<String, dynamic>>? _callEndedController;
    StreamController<Map<String, dynamic>>? _callConnectedController;
    StreamController<bool>? _connectionStateController;
    StreamController<String>? _userOnlineController;
    StreamController<String>? _userOfflineController;
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final StorageService _storage = StorageService();
  bool _isConnected = false;
  String? _listenerUserId;
  final Map<String, bool> listenerOnlineMap = {}; // Tracks all listeners' online status
  final StreamController<Map<String, bool>> _listenerStatusController = StreamController.broadcast();
  bool _connecting = false;
  bool _listenerRegistered = false;
  void _log(String msg) {
    print('[SOCKET] $msg');
  }

  // Getters that lazily create controllers if needed
  StreamController<IncomingCall> get _incomingCall {
    _incomingCallController ??= StreamController<IncomingCall>.broadcast();
    return _incomingCallController!;
  }
  // Public stream for incoming-call event
  Stream<IncomingCall> get onIncomingCallEvent => _incomingCall.stream;
  
  StreamController<Map<String, dynamic>> get _callAccepted {
    _callAcceptedController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _callAcceptedController!;
  }
  
  StreamController<Map<String, dynamic>> get _callRejected {
    _callRejectedController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _callRejectedController!;
  }
  
  StreamController<Map<String, dynamic>> get _callEnded {
    _callEndedController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _callEndedController!;
  }
  
  StreamController<Map<String, dynamic>> get _callConnected {
    _callConnectedController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _callConnectedController!;
  }
  
  StreamController<bool> get _connectionState {
    _connectionStateController ??= StreamController<bool>.broadcast();
    return _connectionStateController!;
  }

  StreamController<String> get _userOnline {
    _userOnlineController ??= StreamController<String>.broadcast();
    return _userOnlineController!;
  }

  StreamController<String> get _userOffline {
    _userOfflineController ??= StreamController<String>.broadcast();
    return _userOfflineController!;
  }

  // Public streams
  Stream<IncomingCall> get onIncomingCall => _incomingCall.stream;
  Stream<Map<String, dynamic>> get onCallAccepted => _callAccepted.stream;
  Stream<Map<String, dynamic>> get onCallRejected => _callRejected.stream;
  Stream<Map<String, dynamic>> get onCallEnded => _callEnded.stream;
  Stream<Map<String, dynamic>> get onCallConnected => _callConnected.stream;
  Stream<bool> get onConnectionStateChange => _connectionState.stream;
  Stream<String> get onUserOnline => _userOnline.stream;
  Stream<String> get onUserOffline => _userOffline.stream;

  bool get isConnected => _socket?.connected ?? false;
  
  // Completer for waiting on connection
  Completer<bool>? _connectionCompleter;
  String? _currentUserId;


  /// Heartbeat timer
  Timer? _heartbeatTimer;

  /// Connect to the socket server and setup listeners
  Future<bool> connect() async {
    if (_isConnected) return true;
    if (_connecting) {
      if (_connectionCompleter != null) return _connectionCompleter!.future;
      return false;
    }
    
    _connecting = true;
    _connectionCompleter = Completer<bool>();
    
    final userId = await _storage.getUserId();
    if (userId == null) {
      _log('No userId found, cannot connect');
      _connecting = false;
      _connectionCompleter!.complete(false);
      return false;
    }
    
    _currentUserId = userId;
    _log('Connecting socket for userId=$userId');
    
    _socket?.dispose();
    _socket = IO.io(
      ApiConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setExtraHeaders({'Connection': 'keep-alive'})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      _log('Socket connected: id=${_socket!.id}');
      _connectionState.add(true);
      
      // Always join as user
      _log('Emitting user:join $userId');
      _socket!.emit('user:join', userId);
      
      // Also join as listener if we were a listener
      if (_listenerOnline) {
        _log('Emitting listener:join $userId');
        _socket!.emit('listener:join', userId);
      }
      
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.complete(true);
      }
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      _log('Socket connect error: $err');
      _connectionState.add(false);
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.complete(false);
      }
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _log('Socket disconnected');
      _connectionState.add(false);
    });

    // --- RE-REGISTER ALL LISTENERS ON EVERY NEW SOCKET INSTANCE ---
    _socket!.on('listener_status', (data) {
      if (data is Map && data['listenerUserId'] != null && data['online'] != null) {
        final id = data['listenerUserId'].toString();
        final online = data['online'] == true;
        listenerOnlineMap[id] = online;
        _listenerStatusController.add(Map.from(listenerOnlineMap));
      }
    });

    _socket!.on('listeners:initial_status', (data) {
      _log('Received initial listener status: $data');
      if (data is List) {
        // Clear old online status (optional, but good for sync)
        listenerOnlineMap.clear();
        for (var id in data) {
          listenerOnlineMap[id.toString()] = true;
        }
        _listenerStatusController.add(Map.from(listenerOnlineMap));
      }
    });

    _socket!.on('incoming-call', (data) {
      _log('Incoming call received: $data');
      try {
        if (data is Map<String, dynamic>) {
          _incomingCall.add(IncomingCall.fromJson(data));
        } else if (data is Map) {
          _incomingCall.add(IncomingCall.fromJson(Map<String, dynamic>.from(data)));
        }
      } catch (e) {
        _log('Error parsing incoming-call: $e');
      }
    });

    _socket!.on('call:accepted', (data) {
      _callAccepted.add(data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data));
    });
    _socket!.on('call:rejected', (data) {
      _callRejected.add(data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data));
    });
    _socket!.on('call:failed', (data) {
      _log('Call failed: $data');
      // We can add a stream for call:failed if needed, or just log it
    });
    _socket!.on('call:ended', (data) {
      _callEnded.add(data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data));
    });
    _socket!.on('call:connected', (data) {
      _callConnected.add(data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data));
    });

    _socket!.connect();
    _connecting = false;
    return true;
  }

  /// Connect to the socket server ONCE and setup listeners (Alias for connect for compatibility)
  Future<void> connectListener() async {
    await connect();
  }

  /// Emit online (app resumed/foreground)
  void emitListenerOnline() {
    if (_isConnected && _currentUserId != null) {
      _log('Emitting listener:join (online) $_currentUserId');
      _socket!.emit('listener:join', _currentUserId);
    }
  }

  /// Emit offline (app paused/detached)
  void emitListenerOffline() {
    if (_isConnected && _currentUserId != null) {
      _log('Emitting listener:offline $_currentUserId');
      _socket!.emit('listener:offline', { 'listenerUserId': _currentUserId });
    }
  }

  /// For user screens: subscribe to online map
  Stream<Map<String, bool>> get listenerStatusStream => _listenerStatusController.stream;

  /// For listener screens: check own online
  bool get isListenerOnline => _currentUserId != null && listenerOnlineMap[_currentUserId!] == true;

  // Getter and setter for listenerOnline
  bool _listenerOnline = false;
  bool get listenerOnline => _listenerOnline;
  set listenerOnline(bool value) => _listenerOnline = value;

  /// Set listener online/offline and update presence
  Future<void> setListenerOnline(bool online) async {
    listenerOnline = online;
    if (!online) {
      // Emit offline event immediately
      final userId = await _storage.getUserId();
      if (_socket != null && _socket!.connected && userId != null) {
        print('[LISTENER] Emitting user:offline for userId: $userId');
        _socket!.emit('user:offline', { 'userId': userId });
      }
      disconnect();
    } else {
      // Connect and emit online event
      print('[LISTENER] Going online, connecting socket...');
      final connected = await connect();
      if (connected && _socket != null && _socket!.connected) {
        final userId = await _storage.getUserId();
        if (userId != null) {
          print('[LISTENER] Explicitly emitting user:join and listener:join for userId: $userId');
          _socket!.emit('user:join', userId);
          _socket!.emit('listener:join', userId);
        }
      }
    }
  }

  /// Handle app going to background - disconnect socket to mark offline quickly
  Future<void> onAppBackground() async {
    if (listenerOnline) {
      final userId = await _storage.getUserId();
      if (_socket != null && _socket!.connected && userId != null) {
        _socket!.emit('user:offline', { 'userId': userId });
      }
      disconnect();
    }
  }

  /// Handle app coming to foreground - reconnect if was online
  Future<void> onAppForeground() async {
    if (listenerOnline) {
      await connect();
    }
  }

  /// Disconnect from the socket server
  void disconnect() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Initiate a call (emit to server)
  void initiateCall({
    required String callId,
    required String listenerId,
    required String callerName,
    String? callerAvatar,
    String? topic,
    String? language,
    String? gender,
    int? age,
  }) {
    _log('Initiating call $callId to $listenerId');
    _socket?.emit('call:initiate', {
      'callId': callId,
      'callerId': _currentUserId, // Add callerId
      'listenerId': listenerId,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
      'topic': topic,
      'language': language,
      'gender': gender,
      'age': age,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void emitCallJoined({required String callId, String? otherUserId}) {
    _log('Emitting call:joined for $callId');
    _socket?.emit('call:joined', {
      'callId': callId,
      'otherUserId': otherUserId,
    });
  }

  /// Accept an incoming call
  void acceptCall({required String callId, required String callerId}) {
    _log('Accepting call $callId from $callerId');
    _socket?.emit('call:accept', {
      'callId': callId,
      'callerId': callerId,
    });
  }

  /// Reject an incoming call
  void rejectCall({required String callId, required String callerId}) {
    _log('Rejecting call $callId from $callerId');
    _socket?.emit('call:reject', {
      'callId': callId,
      'callerId': callerId,
    });
  }

  /// End a call
  void endCall({required String callId, String? otherUserId, String? reason}) {
    _log('Ending call $callId');
    _socket?.emit('call:end', {
      'callId': callId,
      'otherUserId': otherUserId,
      'reason': reason ?? 'user_ended',
    });
  }

  /// Notify that user joined a channel (for web simulation)
  void joinedChannel({
    required String callId,
    required String channelName,
  }) {
    print('Socket: Emitting call:joined for channel $channelName');
    _socket?.emit('call:joined', {
      'callId': callId,
      'channelName': channelName,
    });
  }

  /// Notify that user left a channel
  void leftChannel({
    required String channelName,
  }) {
    _socket?.emit('call:left', {
      'channelName': channelName,
    });
  }

  /// Dispose all resources - Note: For singleton, we just disconnect, don't close controllers
  /// since they may be reused. Controllers are recreated lazily if needed.
  void dispose() {
    disconnect();
    // Close and null out controllers so they can be recreated
    _incomingCallController?.close();
    _incomingCallController = null;
    _callAcceptedController?.close();
    _callAcceptedController = null;
    _callRejectedController?.close();
    _callRejectedController = null;
    _callEndedController?.close();
    _callEndedController = null;
    _callConnectedController?.close();
    _callConnectedController = null;
    _connectionStateController?.close();
    _connectionStateController = null;
    _userOnlineController?.close();
    _userOnlineController = null;
    _userOfflineController?.close();
    _userOfflineController = null;
  }
}
