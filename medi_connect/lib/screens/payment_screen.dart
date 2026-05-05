import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../theme/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final double amount;
  final String doctorName;

  const PaymentScreen({
    Key? key,
    required this.bookingId,
    required this.amount,
    required this.doctorName,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  String _selectedMethod = 'hesabpay';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'hesabpay',
      'name': 'HesabPay',
      'icon': Icons.account_balance_wallet,
      'description': 'Pay with HesabPay wallet',
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'description': 'Pay with your card',
    },
    {
      'id': 'cash',
      'name': 'Cash on Visit',
      'icon': Icons.money,
      'description': 'Pay at the clinic',
    },
  ];

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      if (_selectedMethod == 'cash') {
        // For cash payment, just confirm the booking
        Navigator.pop(context, {'method': 'cash', 'status': 'pending'});
        return;
      }

      // Create payment intent
      final intent = await _paymentService.createPayment(
        bookingId: widget.bookingId,
        amount: widget.amount,
        paymentMethod: _selectedMethod,
      );

      // For HesabPay, show payment URL (in real app, open in webview)
      if (_selectedMethod == 'hesabpay') {
        _showPaymentDialog(intent);
      } else {
        // For card, show card input form
        _showCardPaymentDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showPaymentDialog(PaymentIntent intent) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Complete Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Amount: ${intent.amount} ${intent.currency}'),
            SizedBox(height: 16),
            Text('Order ID: ${intent.orderId}'),
            SizedBox(height: 16),
            Text(
              'In a real app, you would be redirected to HesabPay to complete the payment.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, {'method': _selectedMethod, 'status': 'cancelled'});
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Simulate payment confirmation
              try {
                await _paymentService.confirmPayment(
                  orderId: intent.orderId,
                  transactionId: 'MOCK_${DateTime.now().millisecondsSinceEpoch}',
                );
                Navigator.pop(context);
                Navigator.pop(context, {'method': _selectedMethod, 'status': 'completed'});
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment confirmation failed: $e')),
                );
              }
            },
            child: Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _showCardPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Card Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Expiry',
                      hintText: 'MM/YY',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, {'method': 'card', 'status': 'completed'});
            },
            child: Text('Pay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Doctor'),
                        Text(
                          widget.doctorName,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Consultation Fee'),
                        Text(
                          '${widget.amount} AFN',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.amount} AFN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Payment Methods
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            ..._paymentMethods.map((method) {
              final isSelected = _selectedMethod == method['id'];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                child: ListTile(
                  leading: Icon(
                    method['icon'],
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(
                    method['name'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(method['description']),
                  trailing: Radio<String>(
                    value: method['id'],
                    groupValue: _selectedMethod,
                    onChanged: (value) {
                      setState(() => _selectedMethod = value!);
                    },
                  ),
                  onTap: () {
                    setState(() => _selectedMethod = method['id']);
                  },
                ),
              );
            }).toList(),

            SizedBox(height: 24),

            // Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                ),
                child: _isProcessing
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _selectedMethod == 'cash'
                            ? 'Confirm Booking'
                            : 'Proceed to Payment',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            SizedBox(height: 16),

            // Security Note
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your payment information is secure and encrypted',
                      style: TextStyle(fontSize: 12, color: Colors.green[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
