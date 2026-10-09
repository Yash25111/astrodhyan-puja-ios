import 'dart:async';
import 'dart:io';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'payment_gateway.dart';
import 'payment_models.dart';

PaymentGateway createGateway() => RazorpayMobileGateway();

class RazorpayMobileGateway extends PaymentGateway {
  RazorpayMobileGateway({Razorpay? razorpay})
    : _razorpay = razorpay ?? Razorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  final Razorpay _razorpay;
  Completer<PaymentResult>? _completer;

  @override
  Future<PaymentResult> open(Map<String, dynamic> options) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return Future.error(
        const PaymentException(
          'Razorpay payment works on Android, iOS, and Flutter web. macOS desktop does not have a Razorpay plugin implementation.',
        ),
      );
    }
    if (_completer != null && !_completer!.isCompleted) {
      return Future.error(
        const PaymentException('A payment is already in progress.'),
      );
    }

    final completer = Completer<PaymentResult>();
    _completer = completer;
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

  @override
  void dispose() {
    _razorpay.clear();
  }
}
