import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/socket_service.dart';
import '../../services/chat_service.dart';
import '../../services/storage_service.dart';
import '../../services/chat_state_manager.dart';
import '../../models/chat_model.dart';

class ChatPage extends StatefulWidget {
  final String expertName;
  final String imagePath;
  final String? chatId; // Chat ID from backend
  final String? otherUserId; // The other user's ID
  final String? otherUserAvatar;

  const ChatPage({
    super.key,
    required this.expertName,
    required this.imagePath,
    this.chatId,
    this.otherUserId,
    this.otherUserAvatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SocketService _socketService = SocketService();
  final ChatService _chatService = ChatService();
  final StorageService _storage = StorageService();
  final ChatStateManager _chatStateManager = ChatStateManager();
  
  final List<Message> _messages = [];
  String? _chatId;
  String? _currentUserId;
  bool _isLoading = true;
  bool _isTyping = false;
  bool _otherUserTyping = false;
  bool _otherUserOnline = false; // User online status
  String? _errorMessage;
  
  // Track if we've received history from socket
  bool _historyReceived = false;
  
  // Stream subscriptions
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _historySubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;
  StreamSubscription<Map<String, dynamic>>? _errorSubscription;
  StreamSubscription<Map<String, dynamic>>? _readSubscription;

  @override
  void initState() {
    super.initState();
    // Add lifecycle observer to handle app background/foreground
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes while on chat screen
    // WhatsApp-style: keep connection but update viewing state
    switch (state) {
      case AppLifecycleState.resumed:
        print('[ChatPage-Listener] App resumed - re-joining chat room');
        _chatStateManager.appResumed();
        if (_chatId != null) {
          _socketService.joinChatRoom(_chatId!);
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        print('[ChatPage-Listener] App paused/inactive');
        _chatStateManager.appPaused();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeChat() async {
    try {
      // Get current user ID
      _currentUserId = await _storage.getUserId();
      
      if (_currentUserId == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      // If we already have a chatId, use it
      if (widget.chatId != null) {
        _chatId = widget.chatId;
      } else if (widget.otherUserId != null) {
        // Create or get chat with the other user
        final result = await _chatService.createOrGetChat(widget.otherUserId!);
        if (result.success && result.chat != null) {
          _chatId = result.chat!.chatId;
        } else {
          setState(() {
            _errorMessage = result.error ?? 'Failed to create chat';
            _isLoading = false;
          });
          return;
        }
      } else {
        setState(() {
          _errorMessage = 'No chat ID or user ID provided';
          _isLoading = false;
        });
        return;
      }

      // Ensure socket is connected
      final connected = await _socketService.connect();
      if (!connected) {
        setState(() {
          _errorMessage = 'Failed to connect to server';
          _isLoading = false;
        });
        return;
      }

      // Setup socket listeners BEFORE joining room
      _setupSocketListeners();

      // Join the chat room - this will:
      // 1. Join socket room for real-time messages
      // 2. Update ChatStateManager to track we're viewing this chat
      // 3. Tell server we're actively viewing (no notifications)
      _socketService.joinChatRoom(_chatId!);
      
      // Also load messages from API as fallback (in case socket history doesn't arrive)
      _loadMessagesFromApi();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing chat: $e';
        _isLoading = false;
      });
    }
  }

  /// Load messages from REST API as fallback
  Future<void> _loadMessagesFromApi() async {
    if (_chatId == null) return;
    
    // Wait a bit for socket history, then load from API if not received
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!_historyReceived && mounted) {
      print('[ChatPage-Listener] Socket history not received, loading from API');
      try {
        final result = await _chatService.getChatMessages(
          chatId: _chatId!,
          limit: 50,
          offset: 0,
        );
        
        if (result.success && mounted && !_historyReceived) {
          setState(() {
            _messages.clear();
            _messages.addAll(result.messages);
          });
          _scrollToBottom();
          
          // Mark messages as read
          _socketService.markChatAsRead(_chatId!);
        }
      } catch (e) {
        print('[ChatPage-Listener] Error loading messages from API: $e');
      }
    }
  }

  void _setupSocketListeners() {
    // Listen for incoming messages (real-time)
    // WhatsApp-style: Messages appear instantly without refresh
    _messageSubscription = _socketService.onChatMessage.listen((data) {
      final chatId = data['chatId']?.toString();
      if (chatId == _chatId && data['message'] != null) {
        final messageData = data['message'] as Map<String, dynamic>;
        final message = Message.fromJson(messageData);
        
        print('[ChatPage-Listener] Received message from socket: ${message.messageContent} (senderId: ${message.senderId})');
        
        setState(() {
          // Check if this is confirmation of our own message (replace optimistic)
          if (message.senderId == _currentUserId) {
            // Find and replace the optimistic message with same content
            final optimisticIndex = _messages.indexWhere((m) => 
              m.messageId.startsWith('temp_') && 
              m.messageContent == message.messageContent);
            
            if (optimisticIndex != -1) {
              print('[ChatPage-Listener] Replacing optimistic message with confirmed message');
              _messages[optimisticIndex] = message;
              return; // Already updated
            }
          }
          
          // Check for duplicates by messageId
          if (!_messages.any((m) => m.messageId == message.messageId)) {
            _messages.add(message);
            print('[ChatPage-Listener] Added new message to list');
          } else {
            print('[ChatPage-Listener] Message already exists, skipping duplicate');
          }
        });
        _scrollToBottom();
        
        // Mark as read if from other user (we're viewing the chat)
        if (message.senderId != _currentUserId) {
          _socketService.markChatAsRead(_chatId!);
        }
      }
    });

    // Listen for chat history (sent when joining room)
    _historySubscription = _socketService.onChatHistory.listen((data) {
      final chatId = data['chatId']?.toString();
      if (chatId == _chatId && data['messages'] != null) {
        _historyReceived = true;
        final messagesList = data['messages'] as List;
        
        print('[ChatPage-Listener] Received history: ${messagesList.length} messages');
        
        setState(() {
          _messages.clear();
          for (var msgData in messagesList) {
            _messages.add(Message.fromJson(Map<String, dynamic>.from(msgData)));
          }
        });
        _scrollToBottom();
        
        // Mark messages as read
        _socketService.markChatAsRead(_chatId!);
      }
    });

    // Listen for typing indicators
    _typingSubscription = _socketService.onChatTyping.listen((data) {
      final chatId = data['chatId']?.toString();
      if (chatId == _chatId && data['userId'] != _currentUserId) {
        setState(() {
          _otherUserTyping = data['isTyping'] == true;
        });
      }
    });

    // Listen for read receipts
    _readSubscription = _socketService.onChatMessagesRead.listen((data) {
      final chatId = data['chatId']?.toString();
      if (chatId == _chatId) {
        // Could update UI to show read status
        print('[ChatPage-Listener] Messages marked as read by ${data['readBy']}');
      }
    });

    // Listen for errors
    _errorSubscription = _socketService.onChatError.listen((data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    
    // Leave chat room - this updates ChatStateManager and notifies server
    if (_chatId != null) {
      _socketService.leaveChatRoom(_chatId!);
    }
    
    // Cancel subscriptions
    _messageSubscription?.cancel();
    _historySubscription?.cancel();
    _typingSubscription?.cancel();
    _readSubscription?.cancel();
    _errorSubscription?.cancel();
    
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _chatId == null || _currentUserId == null) return;

    _controller.clear();
    _sendTypingIndicator(false);

    // Create temporary message ID for optimistic update
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    
    // Optimistic update: Add message locally IMMEDIATELY (WhatsApp-style)
    final optimisticMessage = Message(
      messageId: tempId,
      chatId: _chatId!,
      senderId: _currentUserId!,
      senderName: 'You',
      messageType: 'text',
      messageContent: text,
      createdAt: DateTime.now(),
      isRead: false,
    );
    
    setState(() {
      _messages.add(optimisticMessage);
    });
    _scrollToBottom();

    // Try socket first (for real-time delivery to other user)
    if (_socketService.isConnected) {
      print('[ChatPage] Sending message via socket');
      _socketService.sendChatMessage(
        chatId: _chatId!,
        content: text,
      );
    } else {
      // Socket not connected - try to reconnect and use API fallback
      print('[ChatPage] Socket not connected, using API fallback');
      try {
        final result = await _chatService.sendMessage(
          chatId: _chatId!,
          content: text,
        );
        
        if (result.success && result.message != null) {
          // Replace optimistic message with real one
          setState(() {
            final index = _messages.indexWhere((m) => m.messageId == tempId);
            if (index != -1) {
              _messages[index] = result.message!;
            }
          });
        } else {
          // Show error and remove optimistic message
          setState(() {
            _messages.removeWhere((m) => m.messageId == tempId);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.error ?? 'Failed to send message'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('[ChatPage] Error sending message: $e');
        // Remove optimistic message on error
        setState(() {
          _messages.removeWhere((m) => m.messageId == tempId);
        });
      }
      
      // Try to reconnect socket for future messages
      _socketService.connect().then((_) {
        if (_chatId != null) {
          _socketService.joinChatRoom(_chatId!);
        }
      });
    }
  }

  void _sendTypingIndicator(bool typing) {
    if (_isTyping != typing && _chatId != null) {
      _isTyping = typing;
      _socketService.sendTypingIndicator(chatId: _chatId!, isTyping: typing);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFEBEE),
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.pinkAccent),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFEBEE),
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _initializeChat();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFEBEE), Color(0xFFFCE4EC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_otherUserTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_otherUserTyping && index == _messages.length) {
                    return _buildTypingIndicator();
                  }

                  final message = _messages[index];
                  final isUser = message.senderId == _currentUserId;

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.pinkAccent
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: isUser
                                    ? const Radius.circular(20)
                                    : const Radius.circular(4),
                                bottomRight: isUser
                                    ? const Radius.circular(4)
                                    : const Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message.messageContent,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                            child: Text(
                              _formatTime(message.createdAt),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                // Text Field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Share what's on your mind...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: const Color(0xFFFFF1F5),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.pinkAccent, width: 1),
                      ),
                    ),
                    onChanged: (text) {
                      _sendTypingIndicator(text.isNotEmpty);
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                const SizedBox(width: 12),

                // Send Button
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                    tooltip: 'Send message',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.pinkAccent,
      elevation: 2,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.otherUserAvatar != null
                ? NetworkImage(widget.otherUserAvatar!)
                : AssetImage(widget.imagePath) as ImageProvider,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.expertName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  if (_otherUserTyping) ...[
                    const Text(
                      'typing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            // Add menu options like report, block, etc.
          },
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
