import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'payment_gateway.dart';
import 'payment_models.dart';

PaymentGateway createGateway() => RazorpayWebGateway();

class RazorpayWebGateway extends PaymentGateway {
  Completer<PaymentResult>? _completer;

  @override
  Future<PaymentResult> open(Map<String, dynamic> options) {
    if (_completer != null && !_completer!.isCompleted) {
      return Future.error(
        const PaymentException('A payment is already in progress.'),
      );
    }

    final razorpayConstructor = globalContext['Razorpay'];
    if (razorpayConstructor == null ||
        !razorpayConstructor.typeofEquals('function')) {
      return Future.error(
        const PaymentException(
          'Razorpay Checkout script is missing. Please reload the web app and try again.',
        ),
      );
    }

    final completer = Completer<PaymentResult>();
    _completer = completer;

    final checkoutOptions = Map<String, dynamic>.from(options)
      ..['handler'] = ((JSObject response) {
        _onSuccess(response);
      }).toJS
      ..['modal'] = {
        'ondismiss': (() {
          _completeError(const PaymentException('Payment was cancelled.'));
        }).toJS,
      };

    try {
      final razorpay = (razorpayConstructor as JSFunction)
          .callAsConstructor<JSObject>(checkoutOptions.jsify());
      razorpay.callMethod<JSAny?>(
        'on'.toJS,
        'payment.failed'.toJS,
        ((JSObject response) {
          final error = response['error'] as JSObject?;
          final description = error == null
              ? ''
              : _propertyAsString(error, 'description').trim();
          _completeError(
            PaymentException(
              description.isNotEmpty
                  ? description
                  : 'Payment failed or was cancelled.',
            ),
          );
        }).toJS,
      );
      razorpay.callMethod<JSAny?>('open'.toJS);
    } catch (error) {
      _completeError(
        PaymentException('Unable to open payment gateway: $error'),
      );
    }

    return completer.future;
  }

  void _onSuccess(JSObject response) {
    final paymentId = _propertyAsString(response, 'razorpay_payment_id');
    final orderId = _propertyAsString(response, 'razorpay_order_id');
    final signature = _propertyAsString(response, 'razorpay_signature');

    _completeSuccess(
      PaymentResult(
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      ),
    );
  }

  String _propertyAsString(JSObject object, String property) {
    return object[property].dartify()?.toString() ?? '';
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
  void dispose() {}
}
