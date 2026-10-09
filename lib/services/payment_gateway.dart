import 'payment_gateway_stub.dart'
    if (dart.library.io) 'payment_gateway_io.dart'
    if (dart.library.html) 'payment_gateway_web.dart';
import 'payment_models.dart';

abstract class PaymentGateway {
  const PaymentGateway();

  Future<PaymentResult> open(Map<String, dynamic> options);

  void dispose() {}
}

PaymentGateway createPaymentGateway() => createGateway();
