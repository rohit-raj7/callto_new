import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/agora_service.dart';
import '../../services/socket_service.dart';
import '../../services/call_service.dart';

// Agora App ID
const String _agoraAppId = '1a72ae2630224062a6192784611ffce6';

class Calling extends StatefulWidget {
  final String? callerName;
  final String? callerAvatar;
  final String? channelName;
  final String? callId;
  final String? callerId; // The user who initiated the call

  const Calling({
    super.key,
    this.callerName,
    this.callerAvatar,
    this.channelName,
    this.callId,
    this.callerId,
  });

  @override
  State<Calling> createState() => _CallingState();
}

class _CallingState extends State<Calling> with WidgetsBindingObserver, TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _pulseController;
  
  final AgoraService _agoraService = AgoraService();
  final SocketService _socketService = SocketService();
  StreamSubscription? _callConnectedSubscription;
  StreamSubscription? _callEndedSubscription;

  bool _isCallConnected = false;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  int _callDuration = 0;
  Timer? _callTimer;
  String? _connectionError;
  String? _currentChannelName;
  bool _isCallEnding = false; // Prevent multiple end call triggers

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _audioPlayer = AudioPlayer();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Listen for socket events
    _setupSocketListeners();
    
    // Play connecting sound (short notification, not ringtone)
    _playConnectingSound();
    _initAgora();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.detached) {
      // App is being closed - end call properly
      print('Listener: App detached, ending call');
      _endCall();
    }
  }

  void _setupSocketListeners() {
    // Listen for call connected (both parties joined)
    _callConnectedSubscription = _socketService.onCallConnected.listen((data) {
      print('Listener: Received call:connected event');
      if (mounted && !_isCallConnected) {
        _onCallConnected();
      }
    });

    // Listen for call ended (from socket or peer disconnect)
    _callEndedSubscription = _socketService.onCallEnded.listen((data) {
      print('Listener: Call ended by caller - ${data['reason'] ?? 'unknown'}');
      if (mounted) {
        _endCall();
      }
    });

  }

  void _onCallConnected() {
    print('Listener: Call is now connected!');
    _stopRingtone();
    setState(() {
      _isCallConnected = true;
    });
    _startCallTimer();
  }

  Future<void> _playConnectingSound() async {
    // Play a short connecting sound, not a looping ringtone
    // The listener already accepted the call, so no need for loud ringtone
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.play(AssetSource('voice/sample.mp3'));
      // Stop after 2 seconds max (just a notification sound)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_isCallConnected) {
          _audioPlayer.stop();
        }
      });
    } catch (e) {
      print('Audio play error: $e');
    }
  }

  void _stopRingtone() {
    try {
      _audioPlayer.stop();
    } catch (e) {
      print('Audio stop error: $e');
    }
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

    // Use channelName directly - it's passed from home screen as call.callId
    final channelName = widget.channelName ?? widget.callId ?? 
        'call_${DateTime.now().millisecondsSinceEpoch}';
    
    print('Listener: Joining Agora channel: $channelName');

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
    
    print('Listener: Got token, UID: ${tokenResult.uid}');

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
        print('Listener: Joined channel successfully: ${connection.channelId}');
        // Stop connecting sound when we join
        _stopRingtone();
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        print('Listener: Caller joined the call! UID: $remoteUid');
        _stopRingtone();
        setState(() {
          _isCallConnected = true;
        });
        _startCallTimer();
      },
      onUserOffline: (connection, remoteUid, reason) {
        print('Listener: Caller left: $remoteUid, reason: $reason');
        if (mounted) {
          _endCall();
        }
      },
      onError: (err, msg) {
        print('Listener: Agora error: $err - $msg');
        // Only show error if not already connected (avoid spurious errors)
        if (!_isCallConnected && mounted) {
          setState(() {
            _connectionError = 'Call error: $msg';
          });
        }
      },
      onConnectionStateChanged: (connection, state, reason) {
        print('Listener: Connection state: $state, reason: $reason');
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
          print('Listener: Reconnecting...');
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
      print('Listener: Join channel request sent, waiting for caller...');
      _currentChannelName = channelName;
      
      // Emit socket event that we joined the channel (for web simulation)
      _socketService.joinedChannel(
        callId: widget.callId ?? channelName,
        channelName: channelName,
      );
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

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _agoraService.muteLocalAudio(_isMuted);
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    _agoraService.setEnableSpeakerphone(_isSpeakerOn);
  }

  void _endCall() async {
    // Prevent multiple end call triggers
    if (_isCallEnding) return;
    _isCallEnding = true;
    
    print('Listener: Ending call...');
    
    _stopRingtone();
    _callTimer?.cancel();
    
    // Update call status to completed with duration
    final callId = widget.callId ?? _currentChannelName;
    if (callId != null) {
      final callService = CallService();
      final status = _isCallConnected ? 'completed' : 'cancelled';
      final duration = _isCallConnected ? _callDuration : null;
      
      await callService.updateCallStatus(
        callId: callId,
        status: status,
        durationSeconds: duration,
      );
    }
    
    // Leave channel and reset Agora service (allows reuse)
    await _agoraService.reset();
    
    // Notify the caller that call has ended
    if (widget.callerId != null && _currentChannelName != null) {
      _socketService.endCall(
        callId: widget.callId ?? _currentChannelName!,
        otherUserId: widget.callerId!,
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

  @override
  void dispose() {
    // Cancel all socket subscriptions
    _callConnectedSubscription?.cancel();
    _callEndedSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _callTimer?.cancel();
    _agoraService.dispose();
    if (_currentChannelName != null) {
      _socketService.leftChannel(channelName: _currentChannelName!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Colors.pinkAccent;
    const Color backgroundColor = Color(0xFF1E1E2C);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Call To",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: _endCall,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Caller avatar
              Stack(
                alignment: Alignment.center,
                children: [
                  if (!_isCallConnected) ...[
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 100 + (20 * _pulseController.value),
                          height: 100 + (20 * _pulseController.value),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accentColor.withOpacity(0.3 * (1 - _pulseController.value)),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFB39DDB),
                    backgroundImage: widget.callerAvatar != null && widget.callerAvatar!.startsWith('http')
                        ? NetworkImage(widget.callerAvatar!)
                        : null,
                    child: widget.callerAvatar == null || !widget.callerAvatar!.startsWith('http')
                        ? const Icon(Icons.person, size: 50, color: Colors.white70)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.callerName ?? 'Caller',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              
              // Connection error
              if (_connectionError != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _connectionError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              
              const SizedBox(height: 40),

              // Call status
              if (_isCallConnected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDuration(_callDuration),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                            strokeWidth: 5,
                            backgroundColor: accentColor.withOpacity(0.3),
                          ),
                        ),
                        Icon(Icons.call, size: 30, color: accentColor),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Connecting...',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              
              const Spacer(),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    isActive: _isMuted,
                    onTap: _toggleMute,
                  ),
                  
                  // End call button
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  
                  // Speaker button
                  _buildControlButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    label: 'Speaker',
                    isActive: _isSpeakerOn,
                    onTap: _toggleSpeaker,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.headset, color: Colors.white54, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Use Headphones for Better Experience',
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? Colors.white24 : Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white70,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
