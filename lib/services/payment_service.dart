export 'payment_models.dart';

import 'payment_gateway.dart';
import 'payment_models.dart';

class PaymentService {
  static const liveKey = 'rzp_live_RyzmO6CkhGXqPa';

  PaymentService({PaymentGateway? gateway})
    : _gateway = gateway ?? createPaymentGateway();

  final PaymentGateway _gateway;

  Future<PaymentResult> startCheckout({
    required String orderId,
    required num amountInRupees,
    required String contact,
    required String key,
    String? email,
    String description = 'Puja booking',
  }) {
    if (key.trim().isEmpty) {
      return Future.error(const PaymentException('Payment key is missing.'));
    }
    if (orderId.trim().isEmpty) {
      return Future.error(
        const PaymentException('Payment order ID is missing.'),
      );
    }
    if (amountInRupees <= 0) {
      return Future.error(
        const PaymentException('Payment amount must be greater than zero.'),
      );
    }
    final options = <String, dynamic>{
      'key': key,
      // Razorpay Checkout expects amount in the smallest currency unit.
      'amount': (amountInRupees * 100).round(),
      'currency': 'INR',
      'name': 'Divine Puja',
      'description': description,
      'order_id': orderId,
      'prefill': {
        'contact': contact,
        if (email != null && email.isNotEmpty) 'email': email,
      },
      'theme': {'color': '#E86416'},
    };
    return _gateway.open(options);
  }

  void dispose() {
    _gateway.dispose();
  }
}
