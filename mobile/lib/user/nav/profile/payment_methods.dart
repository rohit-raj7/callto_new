import 'package:flutter/material.dart';
import '../../../services/payment_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/user_service.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  int? _selectedPayment;
  final TextEditingController _amountController = TextEditingController();
  final PaymentService _paymentService = PaymentService();
  final StorageService _storageService = StorageService();
  final UserService _userService = UserService();
  bool _isProcessing = false;
  String? _prefillEmail;
  String? _prefillContact;
  double? _pendingAmount;
  int? _pendingAmountInPaise;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'Google Pay',
      'icon': Icons.payment,
      'color': Colors.blue,
      'description': 'Fast & Secure',
    },
    {
      'name': 'PhonePe',
      'icon': Icons.payment,
      'color': const Color(0xFF5F27CD),
      'description': 'UPI Payment',
    },
    {
      'name': 'Paytm',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFF0066FF),
      'description': 'Digital Wallet',
    },
    {
      'name': 'Credit Card',
      'icon': Icons.credit_card,
      'color': Colors.orange,
      'description': 'Visa, MasterCard',
    },
    {
      'name': 'Debit Card',
      'icon': Icons.credit_card_outlined,
      'color': Colors.red,
      'description': 'All Banks',
    },
    {
      'name': 'Net Banking',
      'icon': Icons.account_balance,
      'color': Colors.green,
      'description': 'Direct Transfer',
    },
    {
      'name': 'BHIM UPI',
      'icon': Icons.qr_code_2,
      'color': const Color(0xFFFF6B6B),
      'description': 'UPI Transfer',
    },
    {
      'name': 'Amazon Pay',
      'icon': Icons.card_giftcard,
      'color': Colors.amber,
      'description': 'One Click Pay',
    },
  ];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_handleAmountChange);
    _paymentService.initialize();
    _loadPrefill();
  }

  Future<void> _loadPrefill() async {
    final email = await _storageService.getEmail();
    final mobile = await _storageService.getMobile();
    if (!mounted) return;
    setState(() {
      _prefillEmail = email;
      _prefillContact = mobile;
    });
  }

  void _handleAmountChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_handleAmountChange);
    _amountController.dispose();
    _paymentService.dispose();
    super.dispose();
  }

  void _setProcessing(bool value) {
    if (!mounted) return;
    setState(() {
      _isProcessing = value;
    });
  }

  double? _parseAmount() {
    final amountText = _amountController.text.trim();
    final amountValue = double.tryParse(amountText);
    if (amountValue == null || amountValue <= 0) {
      return null;
    }
    return amountValue;
  }

  Future<void> _syncWallet(double amountValue) async {
    final result = await _userService.addBalance(amountValue);
    if (!mounted) return;
    if (!result.success) {
      _showSyncFailedDialog(result.error ?? 'Wallet sync failed');
      return;
    }
  }

  void _showSuccessDialog(String paymentId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Top-up successful', style: TextStyle(color: Colors.pinkAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment successful and is being verified.'),
              const SizedBox(height: 12),
              Text('Transaction ID: $paymentId'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Payment failed', style: TextStyle(color: Colors.redAccent)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                final amountValue = _pendingAmount;
                final amountInPaise = _pendingAmountInPaise;
                if (amountValue != null && amountInPaise != null) {
                  _startCheckout(amountValue, amountInPaise);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  void _showSyncFailedDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Wallet sync failed', style: TextStyle(color: Colors.redAccent)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                final amountValue = _pendingAmount;
                if (amountValue != null) {
                  _syncWallet(amountValue);
                }
              },
              child: const Text('Retry Sync'),
            ),
          ],
        );
      },
    );
  }

  void _startCheckout(double amountValue, int amountInPaise) {
    _pendingAmount = amountValue;
    _pendingAmountInPaise = amountInPaise;
    _setProcessing(true);
    _paymentService.openCheckout(
      context: context,
      amountInPaise: amountInPaise,
      name: 'Call To',
      description: 'Wallet Top-Up',
      email: _prefillEmail,
      contact: _prefillContact,
      onSuccess: (response) {
        _setProcessing(false);
        final paymentId = response?.paymentId?.toString() ?? 'N/A';
        _showSuccessDialog(paymentId);
        _syncWallet(amountValue);
      },
      onError: (error) {
        _setProcessing(false);
        final msg = error?.message?.toString() ?? 'Payment failed';
        _showFailureDialog(msg);
      },
      onExternalWallet: (wallet) {
        _setProcessing(false);
        if (!mounted) return;
        final name = wallet?.walletName?.toString() ?? 'Wallet';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('External wallet: $name'),
            backgroundColor: Colors.pinkAccent,
          ),
        );
      },
      onCheckoutError: (message) {
        _setProcessing(false);
        _showFailureDialog(message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE4EC),
        elevation: 0,
        title: const Text(
          "Add Balance",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Amount Input Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFE4EC),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter Amount",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '₹0.00',
                      prefixIcon: const Icon(Icons.currency_rupee, color: Colors.pinkAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFFE4EC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFE4EC).withOpacity(0.1),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Minimum amount: ₹10 | Maximum amount: ₹10,000",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Methods Header
            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Payment methods grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final payment = paymentMethods[index];
                final isSelected = _selectedPayment == index;

                return GestureDetector(
                  onTap: () => setState(() => _selectedPayment = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isSelected ? payment['color'] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? payment['color']
                            : const Color(0xFFFFE4EC),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? (payment['color'] as Color).withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : (payment['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            payment['icon'] as IconData,
                            size: 32,
                            color: isSelected ? Colors.white : payment['color'],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Name
                        Text(
                          payment['name'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        // Description
                        Text(
                          payment['description'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? Colors.white70
                                : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Continue button
            if (_selectedPayment != null && _amountController.text.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _isProcessing
                      ? null
                      : () {
                    final amountValue = _parseAmount();
                    if (amountValue == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid amount'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (amountValue < 10 || amountValue > 10000) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Amount must be between ₹10 and ₹10,000'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    final amountInPaise = (amountValue * 100).round();
                    _startCheckout(amountValue, amountInPaise);
                  },
                  child: const Text(
                    "Add Balance",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _amountController.text.isEmpty
                        ? "Enter amount to continue"
                        : "Select a payment method to continue",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4EC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.pinkAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock,
                    color: Colors.pinkAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Your payment information is secure and encrypted",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black38,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
