import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_entity.dart';

// Abstract contract - add new providers without modifying this
abstract class PaymentRepository {
  Future<Either<Failure, PaymentEntity>> initiatePayment({
    required String bookingId,
    required double amount,
  });
  Future<Either<Failure, PaymentEntity>> verifyPayment({
    required String paymentId,
    required String refId,
  });
  Future<Either<Failure, List<PaymentEntity>>> getUserPayments(String userId);
  Future<Either<Failure, PaymentEntity>> getPaymentById(String id);
  Future<Either<Failure, void>> requestRefund(String paymentId);
}
