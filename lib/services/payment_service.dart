import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentResult {
  const PaymentResult({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });
  final String paymentId;
  final String orderId;
  final String signature;
}

class PaymentException implements Exception {
  const PaymentException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PaymentService {
  static const testKey = 'rzp_test_4C4H3EaqkCBpYu';

  PaymentService({Razorpay? razorpay}) : _razorpay = razorpay ?? Razorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }
  final Razorpay _razorpay;
  Completer<PaymentResult>? _completer;
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
    if (_completer != null && !_completer!.isCompleted) {
      return Future.error(
        const PaymentException('A payment is already in progress.'),
      );
    }
    final completer = Completer<PaymentResult>();
    _completer = completer;
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
    try {
      _razorpay.open(options);
    } catch (error) {
      _completeError(
        PaymentException('Unable to open payment gateway: $error'),
      );
    }
    return completer.future;
  }

  void _onSuccess(PaymentSuccessResponse response) {
    _completeSuccess(
      PaymentResult(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      ),
    );
  }

  void _onError(PaymentFailureResponse response) {
    final message = response.message?.trim().isNotEmpty == true
        ? response.message!
        : 'Payment failed or was cancelled.';
    _completeError(PaymentException(message));
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    final wallet = response.walletName ?? 'external wallet';
    _completeError(PaymentException('External wallet selected: $wallet'));
  }

  void _completeSuccess(PaymentResult result) {
    final completer = _completer;
    _completer = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  void _completeError(Object error) {
    final completer = _completer;
    _completer = null;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error);
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
