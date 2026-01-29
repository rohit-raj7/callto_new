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
    return IncomingCall(
      callId: json['call_id']?.toString() ?? json['callId']?.toString() ?? '',
      callerId: json['caller_id']?.toString() ?? json['callerId']?.toString() ?? '',
      callerName: json['caller_name'] ?? json['callerName'] ?? 'Unknown',
      callerAvatar: json['caller_avatar'] ?? json['callerAvatar'],
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

  /// Connect to the socket server ONCE and setup listeners
  Future<void> connectListener() async {
    if (_connecting || _isConnected) return;
    _connecting = true;
    _listenerUserId = await _storage.getUserId();
    if (_listenerUserId == null) {
      _log('No listenerUserId found, cannot connect');
      _connecting = false;
      return;
    }
    _log('Connecting socket for listenerUserId=$_listenerUserId');
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
      if (_listenerUserId != null) {
        _log('Emitting listener:join $_listenerUserId');
        _socket!.emit('listener:join', _listenerUserId);
      }
    });
    _socket!.onDisconnect((_) {
      _isConnected = false;
      _log('Socket disconnected');
      _connectionState.add(false);
    });
    _socket!.onConnectError((err) {
      _isConnected = false;
      _log('Socket connect error: $err');
      _connectionState.add(false);
    });
    if (!_listenerRegistered) {
      _listenerRegistered = true;
      _socket!.on('listener_status', (data) {
        // --- FIX: Only update status from real events, not default ---
        if (data is Map && data['listenerUserId'] != null && data['online'] != null) {
          final id = data['listenerUserId'].toString();
          final online = data['online'] == true;
          listenerOnlineMap[id] = online;
          _listenerStatusController.add(Map.from(listenerOnlineMap));
        }
      });
    }
    _socket!.connect();
    _connecting = false;
  }

  /// Emit online (app resumed/foreground)
  void emitListenerOnline() {
    if (_isConnected && _listenerUserId != null) {
      _log('Emitting listener:join (online) $_listenerUserId');
      _socket!.emit('listener:join', _listenerUserId);
    }
  }

  /// Emit offline (app paused/detached)
  void emitListenerOffline() {
    if (_isConnected && _listenerUserId != null) {
      _log('Emitting listener:offline $_listenerUserId');
      _socket!.emit('listener:offline', { 'listenerUserId': _listenerUserId });
    }
  }

  /// For user screens: subscribe to online map
  Stream<Map<String, bool>> get listenerStatusStream => _listenerStatusController.stream;

  /// For listener screens: check own online
  bool get isListenerOnline => _listenerUserId != null && listenerOnlineMap[_listenerUserId!] == true;

  /// Dispose

  // Getter and setter for listenerOnline
  bool _listenerOnline = false;
  bool get listenerOnline => _listenerOnline;
  set listenerOnline(bool value) => _listenerOnline = value;

  // Placeholder connect() method
  Future<bool> connect() async {
    // Implement actual connection logic as needed
    // For now, just simulate a successful connection
    await Future.delayed(Duration(milliseconds: 100));
    return true;
  }

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
          print('[LISTENER] Explicitly emitting user:online for userId: $userId');
          _socket!.emit('user:online', { 'userId': userId });
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
    String? callerName,
    String? callerAvatar,
    String? topic,
    String? language,
    String? gender,
    int? age,
  }) {
    print('Socket: Initiating call to listenerId: $listenerId, callId: $callId');
    _socket?.emit('call:initiate', {
      'callId': callId,
      'listenerId': listenerId,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
      'topic': topic,
      'language': language,
      'gender': gender,
      'age': age,
    });
  }

  /// Accept an incoming call
  void acceptCall({
    required String callId,
    required String callerId,
  }) {
    _socket?.emit('call:accept', {
      'callId': callId,
      'callerId': callerId,
    });
  }

  /// Reject an incoming call
  void rejectCall({
    required String callId,
    required String callerId,
  }) {
    _socket?.emit('call:reject', {
      'callId': callId,
      'callerId': callerId,
    });
  }

  /// End a call
  void endCall({
    required String callId,
    required String otherUserId,
  }) {
    _socket?.emit('call:end', {
      'callId': callId,
      'otherUserId': otherUserId,
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
