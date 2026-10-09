import 'payment_gateway.dart';
import 'payment_models.dart';

PaymentGateway createGateway() => const UnsupportedPaymentGateway();

class UnsupportedPaymentGateway extends PaymentGateway {
  const UnsupportedPaymentGateway();

  @override
  Future<PaymentResult> open(Map<String, dynamic> options) {
    return Future.error(
      const PaymentException(
        'Payment gateway is not supported on this platform.',
      ),
    );
  }
}
