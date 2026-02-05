import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/audio_route_service.dart';
import '../../services/agora_service.dart';
import '../../services/socket_service.dart';
import '../../services/call_service.dart';

// Agora App ID - loaded from backend via token request
const String _agoraAppId = '3ce923c6b5cb422bae0674cc9ddf11f0';

class Calling extends StatefulWidget {
  final String callerName;
  final String callerAvatar;
  final String userName;
  final String? userAvatar;
  final String? channelName;
  final String? listenerId;
  final String? listenerDbId; // The listener_id for database calls
  final String? topic;
  final String? language;
  final String? gender;

  const Calling({
    super.key,
    required this.callerName,
    required this.callerAvatar,
    this.userName = 'You',
    this.userAvatar,
    this.channelName,
    this.listenerId,
    this.listenerDbId,
    this.topic,
    this.language,
    this.gender,
  });

  @override
  State<Calling> createState() => _CallingState();
}

class _CallingState extends State<Calling> with WidgetsBindingObserver, TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _pulseController;

  late final AudioRouteService _audioRoute;
  final AgoraService _agoraService = AgoraService();
  final SocketService _socketService = SocketService();
  final CallService _callService = CallService();
  StreamSubscription? _callConnectedSubscription;
  StreamSubscription? _callEndedSubscription;
  StreamSubscription? _callRejectedSubscription;
  
  bool _isCallConnected = false;
  int _callDuration = 0;
  Timer? _callTimer;
  bool _isMuted = false;
  bool _hasStartedAudio = false;
  String? _connectionError;
  String? _currentChannelName;
  bool _isCallEnding = false; // Prevent multiple end call triggers
  String? _callId; // Store the call ID from database
  bool _isCallInitiating = true; // Track call initiation status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _audioRoute = AudioRouteService();
    _audioRoute.state.addListener(_onAudioRouteChanged);

    _audioPlayer = AudioPlayer();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Setup socket listeners for call events
    _setupSocketListeners();
    
    _initAudio();
    
    // If channelName is provided, call was already created (backward compatibility)
    // Otherwise, create the call first, then init Agora
    if (widget.channelName != null) {
      _callId = widget.channelName;
      _isCallInitiating = false;
      _initAgora();
    } else {
      _initiateCallAndConnect();
    }
  }

  /// Create call in database and emit socket event, then init Agora
  Future<void> _initiateCallAndConnect() async {
    print('User: Initiating call to listener...');
    
    // Connect to socket first
    final connected = await _socketService.connect();
    if (!connected) {
      if (mounted) {
        setState(() {
          _connectionError = 'Failed to connect. Please try again.';
          _isCallInitiating = false;
        });
      }
      return;
    }

    // Create call in database
    final callResult = await _callService.initiateCall(
      listenerId: widget.listenerDbId ?? widget.listenerId ?? '',
      callType: 'audio',
    );

    if (!callResult.success) {
      if (mounted) {
        setState(() {
          _connectionError = callResult.error ?? 'Failed to initiate call';
          _isCallInitiating = false;
        });
        _stopRingtone();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
      return;
    }

    _callId = callResult.call!.callId;
    print('User: Call created with ID: $_callId');

    // Emit socket event to notify listener
    final targetUserId = widget.listenerId;
    if (targetUserId != null && _callId != null) {
      print('User: Emitting call initiation to listener: $targetUserId');
      _socketService.initiateCall(
        callId: _callId!,
        listenerId: targetUserId,
        callerName: widget.userName,
        callerAvatar: widget.userAvatar,
        topic: widget.topic ?? 'General',
        language: widget.language ?? 'English',
        gender: widget.gender,
      );
    }

    if (mounted) {
      setState(() {
        _isCallInitiating = false;
      });
    }

    // Now initialize Agora with the call ID
    _initAgora();
  }

  void _setupSocketListeners() {
    // Listen for call connected (both parties joined)
    _callConnectedSubscription = _socketService.onCallConnected.listen((data) {
      print('User: Received call:connected event');
      if (mounted && !_isCallConnected) {
        _onCallConnected();
      }
    });

    // Listen for call ended (from socket or peer disconnect)
    _callEndedSubscription = _socketService.onCallEnded.listen((data) {
      print('User: Call ended by listener - ${data['reason'] ?? 'unknown'}');
      if (mounted) {
        // Check if it's a call error (listener offline)
        if (data['code'] == 'LISTENER_OFFLINE') {
          setState(() {
            _connectionError = data['error'] ?? 'Listener is offline';
          });
          _stopRingtone();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _endCall();
          });
        } else {
          _endCall();
        }
      }
    });

    // Listen for call rejected
    _callRejectedSubscription = _socketService.onCallRejected.listen((data) {
      print('User: Call rejected by listener');
      if (mounted) {
        setState(() {
          _connectionError = 'Call was declined';
        });
        _stopRingtone();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _endCall();
        });
      }
    });

  }

  void _onCallConnected() {
    print('User: Call is now connected!');
    _stopRingtone();
    setState(() {
      _isCallConnected = true;
    });
    _startCallTimer();
  }

  void _onAudioRouteChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initAudio() async {
    if (_hasStartedAudio) return;
    _hasStartedAudio = true;

    await _audioRoute.start();
    await _playRingtone();
  }

  /// Initialize Agora RTC
  Future<void> _initAgora() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() {
        _connectionError = 'Microphone permission denied';
      });
      return;
    }

    // Use callId from database, or widget.channelName for backward compatibility
    final channelName = _callId ?? widget.channelName ?? 
        'call_${widget.listenerId ?? DateTime.now().millisecondsSinceEpoch}';
    _currentChannelName = channelName;
    
    print('User: Joining Agora channel: $channelName');

    // Fetch token from backend
    final tokenResult = await _agoraService.fetchToken(channelName: channelName);
    
    if (!tokenResult.success || tokenResult.token == null) {
      setState(() {
        _connectionError = tokenResult.error ?? 'Failed to get call token';
      });
      _stopRingtone();
      // Navigate back after showing error
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) Navigator.pop(context);
      });
      return;
    }
    
    print('User: Got token, UID: ${tokenResult.uid}');

    // Initialize Agora engine
    final initialized = await _agoraService.initEngine(appId: _agoraAppId);
    if (!initialized) {
      setState(() {
        _connectionError = 'Failed to initialize call engine';
      });
      _stopRingtone();
      return;
    }

    // Register event handlers
    _agoraService.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        print('User: Joined channel successfully: ${connection.channelId}');
        // Notify server that we joined the call
        _socketService.emitCallJoined(
          callId: channelName,
          otherUserId: widget.listenerId,
        );
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        print('User: Listener joined the call! UID: $remoteUid');
        _stopRingtone();
        setState(() {
          _isCallConnected = true;
        });
        _startCallTimer();
      },
      onUserOffline: (connection, remoteUid, reason) {
        print('User: Listener left: $remoteUid, reason: $reason');
        // End call when remote user leaves
        if (mounted) {
          _endCall();
        }
      },
      onError: (err, msg) {
        print('User: Agora error: $err - $msg');
        // Only show error if not already connected (avoid spurious errors)
        if (!_isCallConnected && mounted) {
          setState(() {
            _connectionError = 'Call error: $msg';
          });
        }
      },
      onConnectionStateChanged: (connection, state, reason) {
        print('User: Connection state: $state, reason: $reason');
        if (state == ConnectionStateType.connectionStateFailed) {
          // Provide more context based on the reason
          String errorMsg = 'Connection failed';
          if (reason == ConnectionChangedReasonType.connectionChangedTokenExpired) {
            errorMsg = 'Call session expired. Please try again.';
          } else if (reason == ConnectionChangedReasonType.connectionChangedRejectedByServer) {
            errorMsg = 'Connection rejected. Please try again.';
          } else if (reason == ConnectionChangedReasonType.connectionChangedInvalidToken) {
            errorMsg = 'Invalid call token. Please try again.';
          }
          if (mounted) {
            setState(() {
              _connectionError = errorMsg;
            });
          }
          _endCall();
        } else if (state == ConnectionStateType.connectionStateReconnecting) {
          print('User: Reconnecting...');
        }
      },
    ));

    // Join channel
    final joined = await _agoraService.joinChannel(
      token: tokenResult.token!,
      channelName: channelName,
      uid: tokenResult.uid ?? 0,
    );

    if (!joined) {
      setState(() {
        _connectionError = 'Failed to join call';
      });
      _stopRingtone();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      print('User: Join channel request sent, waiting for listener to accept...');
      _currentChannelName = channelName;
      
      // Emit socket event that we joined the channel (for web simulation)
      _socketService.joinedChannel(
        callId: channelName,
        channelName: channelName,
      );
      
      // Set timeout for no answer (45 seconds)
      Future.delayed(const Duration(seconds: 45), () {
        if (mounted && !_isCallConnected && !_isCallEnding) {
          setState(() {
            _connectionError = 'No answer';
          });
          _stopRingtone();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _endCall();
          });
        }
      });
    }
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _callDuration++);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.paused) {
      // App went to background
      _audioPlayer.pause();
      // Don't end call on background - user might return
    } else if (state == AppLifecycleState.resumed && !_isCallConnected) {
      _audioPlayer.resume();
    } else if (state == AppLifecycleState.detached) {
      // App is being closed - end call properly
      print('User: App detached, ending call');
      _endCall();
    }
  }

  Future<void> _playRingtone() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('voice/sample.mp3'));
  }

  void _stopRingtone() {
    _audioPlayer.stop();
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _agoraService.muteLocalAudio(_isMuted);
  }

  Future<void> _toggleAudioOutput() async {
    await _audioRoute.cycleUserMode();
    // Also update Agora speaker setting
    final isSpeaker = _activeAudioMode == AudioMode.speaker;
    await _agoraService.setEnableSpeakerphone(isSpeaker);
  }

  void _endCall() async {
    // Prevent multiple end call triggers
    if (_isCallEnding) return;
    _isCallEnding = true;
    
    print('User: Ending call...');
    
    _stopRingtone();
    _callTimer?.cancel();
    
    // Update call status to completed with duration
    if (_currentChannelName != null) {
      final callService = CallService();
      final status = _isCallConnected ? 'completed' : 'cancelled';
      final duration = _isCallConnected ? _callDuration : null;
      
      await callService.updateCallStatus(
        callId: _currentChannelName!,
        status: status,
        durationSeconds: duration,
      );
    }
    
    // Leave channel and reset Agora service (allows reuse)
    await _agoraService.reset();
    
    // Notify the listener that call has ended
    if (widget.listenerId != null && _currentChannelName != null) {
      _socketService.endCall(
        callId: _currentChannelName!,
        otherUserId: widget.listenerId!,
      );
    }
    
    // Notify socket that we left the channel
    if (_currentChannelName != null) {
      _socketService.leftChannel(channelName: _currentChannelName!);
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  AudioMode get _activeAudioMode => _audioRoute.state.value.effectiveMode;

  /// Icon for active audio mode
  IconData _getDeviceIcon() {
    switch (_activeAudioMode) {
      case AudioMode.bluetooth:
        return Icons.bluetooth_audio;
      case AudioMode.headset:
        return Icons.headset;
      case AudioMode.speaker:
        return Icons.volume_up;
    }
  }

  /// Status text for active audio mode
  String _getDeviceStatusText() {
    switch (_activeAudioMode) {
      case AudioMode.bluetooth:
        return 'Bluetooth Connected';
      case AudioMode.headset:
        return 'Using Headphones';
      case AudioMode.speaker:
        return 'Using Speaker';
    }
  }

  /// Label for the toggle button
  String _getAudioButtonLabel() {
    switch (_activeAudioMode) {
      case AudioMode.bluetooth:
        return 'Bluetooth';
      case AudioMode.headset:
        return 'Headset';
      case AudioMode.speaker:
        return 'Speaker';
    }
  }

  /// Color for active audio mode
  Color _getDeviceColor() {
    switch (_activeAudioMode) {
      case AudioMode.bluetooth:
        return Colors.blueAccent;
      case AudioMode.headset:
        return Colors.greenAccent;
      case AudioMode.speaker:
        return Colors.white70;
    }
  }

  Widget _buildAvatarImage(String? imagePath, Color fallbackColor, double radius) {
    if (imagePath == null || imagePath.isEmpty) {
      return _buildFallbackAvatar(fallbackColor, radius);
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
        errorBuilder: (_, __, ___) => _buildFallbackAvatar(fallbackColor, radius),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildFallbackAvatar(fallbackColor, radius);
        },
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: radius * 2,
      height: radius * 2,
      errorBuilder: (_, __, ___) => _buildFallbackAvatar(fallbackColor, radius),
    );
  }

  Widget _buildFallbackAvatar(Color color, double radius) {
    return Container(
      color: color,
      child: Icon(
        Icons.person,
        size: radius,
        color: Colors.white70,
      ),
    );
  }

  /// Build control button
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, // Reduced from 68
            height: 56, // Reduced from 68
            decoration: BoxDecoration(
              color: isActive ? color : const Color(0xFF2A2A3E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Cancel all socket subscriptions
    _callConnectedSubscription?.cancel();
    _callEndedSubscription?.cancel();
    _callRejectedSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _audioRoute.state.removeListener(_onAudioRouteChanged);
    _audioRoute.dispose();
    _callTimer?.cancel();
    
    // Clean up media resources
    _agoraService.dispose();
    
    // Notify server we left the channel
    if (_currentChannelName != null) {
      _socketService.leftChannel(channelName: _currentChannelName!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Colors.pinkAccent;
    const Color backgroundColor = Color(0xFF121220);
    const Color cardColor = Color(0xFF1E1E2E);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundColor, const Color(0xFF1A1A2E), const Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: <Widget>[
                        // Custom App Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Back button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                                  onPressed: _endCall,
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  "Call To",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              // Spacer to keep title centered (same width as back button area)
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Audio device status chip
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Container(
                            key: ValueKey(_activeAudioMode),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getDeviceColor().withOpacity(0.2),
                                  _getDeviceColor().withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: _getDeviceColor().withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getDeviceIcon(), color: _getDeviceColor(), size: 18),
                                const SizedBox(width: 10),
                                Text(
                                  _getDeviceStatusText(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _getDeviceColor(),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 1),

                        // Caller avatar section with enhanced design
                        SizedBox(
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow rings
                              if (!_isCallConnected) ...[
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 140 + (30 * _pulseController.value),
                                      height: 140 + (30 * _pulseController.value),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: accentColor.withOpacity(0.15 * (1 - _pulseController.value)),
                                          width: 1,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 110 + (20 * _pulseController.value),
                                      height: 110 + (20 * _pulseController.value),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: accentColor.withOpacity(0.25 * (1 - _pulseController.value)),
                                          width: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                              // Connected state ring
                              if (_isCallConnected)
                                Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.withOpacity(0.3),
                                        Colors.green.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(color: Colors.green.withOpacity(0.5), width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 25,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              // Avatar with enhanced styling
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _buildAvatarImage(widget.callerAvatar, const Color(0xFFB39DDB), 55),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Caller name with enhanced styling
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            widget.callerName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24, // Reduced from 28
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Call status with enhanced design
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.2),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _isCallConnected
                              ? Container(
                                  key: const ValueKey('connected'),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.withOpacity(0.2),
                                        Colors.green.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(0.5),
                                              blurRadius: 6,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _formatDuration(_callDuration),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.green,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  key: const ValueKey('connecting'),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        (_connectionError != null ? Colors.red : accentColor).withOpacity(0.2),
                                        (_connectionError != null ? Colors.red : accentColor).withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: (_connectionError != null ? Colors.red : accentColor).withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_connectionError == null)
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      else
                                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                      const SizedBox(width: 14),
                                      Flexible(
                                        child: Text(
                                          _connectionError ?? 'Connecting...',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: _connectionError != null ? Colors.red : accentColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),

                        const Spacer(flex: 1),

                        // User section with card design
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // User avatar with glow effect
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isCallConnected ? Colors.green : accentColor).withOpacity(0.35),
                                      blurRadius: 14,
                                      spreadRadius: 2.5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _buildAvatarImage(widget.userAvatar, const Color(0xFFB39DDB), 28),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // User info
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.userName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _isCallConnected ? 'In Call' : 'Calling...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _isCallConnected ? Colors.green : Colors.white54,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Control buttons
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16), // Reduced from 24
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8), // Reduced horizontal from 16
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildControlButton(
                                icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                                label: _isMuted ? 'Unmute' : 'Mute',
                                color: _isMuted ? const Color(0xFFEF5350) : Colors.white70,
                                onTap: _toggleMute,
                                isActive: _isMuted,
                              ),

                              // End call button
                              GestureDetector(
                                onTap: _endCall,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 64, // Reduced from 72
                                      height: 64, // Reduced from 72
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF5350),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.call_end_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'End Call',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              _buildControlButton(
                                icon: _getDeviceIcon(),
                                label: _getAudioButtonLabel(),
                                color: _getDeviceColor(),
                                onTap: _toggleAudioOutput,
                                isActive: _activeAudioMode != AudioMode.speaker,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
