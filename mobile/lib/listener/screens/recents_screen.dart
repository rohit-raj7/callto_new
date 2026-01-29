import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/call_service.dart';
import '../../models/call_model.dart';

class RecentsScreen extends StatefulWidget {
  const RecentsScreen({super.key});

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
  final CallService _callService = CallService();
  
  bool _showAll = true;
  bool _isLoading = true;
  String? _error;
  List<Call> _callHistory = [];

  @override
  void initState() {
    super.initState();
    _loadCallHistory();
  }

  Future<void> _loadCallHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _callService.getListenerCallHistory(limit: 50);
      
      if (result.success) {
        setState(() {
          _callHistory = result.calls;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.error;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load call history';
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    return DateFormat('h:mm a').format(local);
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final callDate = DateTime(local.year, local.month, local.day);

    if (callDate == today) {
      return 'Today';
    } else if (callDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(local);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'missed':
        return 'Missed';
      case 'rejected':
        return 'Declined';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'rejected':
        return Colors.orange;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Get filtered calls
  List<Call> get _filteredCalls {
    if (_showAll) return _callHistory;
    return _callHistory.where((call) => call.status == 'missed').toList();
  }

  // Group calls by date
  Map<String, List<Call>> _groupCallsByDate() {
    final Map<String, List<Call>> grouped = {};
    for (final call in _filteredCalls) {
      final dateKey = _formatDate(call.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(call);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFEEBF1), Color(0xFFF7F3FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildCustomHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error!, style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadCallHistory,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredCalls.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadCallHistory,
                              child: _buildCallList(),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call_received, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _showAll ? 'No recent calls' : 'No missed calls',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Calls from users will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallList() {
    final groupedCalls = _groupCallsByDate();
    final dateKeys = groupedCalls.keys.toList();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = dateKeys[index];
        final calls = groupedCalls[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            ...calls.map((call) => _buildRecentItemCard(call)),
          ],
        );
      },
    );
  }

  /// -------- Custom Header with Back Button ----------
  Widget _buildCustomHeader(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back + Filter Toggle
            Row(
              children: [
                _buildBackButton(context),
                const SizedBox(width: 8),
                Text(
                  _showAll ? 'All' : 'Missed',
                  style: TextStyle(
                    color: _showAll ? Colors.blueAccent : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Switch(
                  value: _showAll,
                  onChanged: (value) {
                    setState(() => _showAll = value);
                  },
                  activeTrackColor: Colors.blue[200],
                  activeColor: Colors.white,
                  inactiveTrackColor: Colors.red.shade200,
                  inactiveThumbColor: Colors.red,
                ),
              ],
            ),

            // Title and Refresh
            Row(
              children: [
                const Text(
                  'Recents',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadCallHistory,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// -------- Back Button ----------
  Widget _buildBackButton(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    
    if (!canPop) {
      return const SizedBox(width: 48);
    }
    
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back_ios_new,
            size: 18, color: Colors.black87),
      ),
    );
  }

  /// -------- Recent Card ----------
  Widget _buildRecentItemCard(Call call) {
    // For listener, show caller info (the user who called them)
    final name = call.callerName ?? 'Unknown User';
    final avatar = call.callerAvatar ?? 'https://randomuser.me/api/portraits/lego/1.jpg';
    final status = call.status;
    final isCompleted = status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEE9F2), Color(0xFFFBEFFF)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            // Avatar + Status
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: avatar.startsWith('http')
                      ? NetworkImage(avatar)
                      : AssetImage(avatar) as ImageProvider,
                  backgroundColor: Colors.grey.shade200,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${call.formattedDuration} • ${_formatTime(call.createdAt)}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  if (call.totalCost != null && isCompleted)
                    Text(
                      'Earned: ${call.formattedCost}',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            /// Chat Button
            _buildChatButton(),
          ],
        ),
      ),
    );
  }

  /// -------- Chat Button ----------
  Widget _buildChatButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () {
        // TODO: Navigate to chat with user
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: const Icon(
          Icons.chat_bubble_outline,
          color: Colors.black54,
        ),
      ),
    );
  }
}
