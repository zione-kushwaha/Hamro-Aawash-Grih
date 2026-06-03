import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class InitiatePayment extends UseCase<PaymentEntity, InitiatePaymentParams> {
  final PaymentRepository repository;
  InitiatePayment(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(InitiatePaymentParams p) =>
      repository.initiatePayment(bookingId: p.bookingId, amount: p.amount);
}

class InitiatePaymentParams extends Equatable {
  final String bookingId;
  final double amount;
  const InitiatePaymentParams({required this.bookingId, required this.amount});

  @override
  List<Object> get props => [bookingId, amount];
}

class VerifyPayment extends UseCase<PaymentEntity, VerifyPaymentParams> {
  final PaymentRepository repository;
  VerifyPayment(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(VerifyPaymentParams p) =>
      repository.verifyPayment(paymentId: p.paymentId, refId: p.refId);
}

class VerifyPaymentParams extends Equatable {
  final String paymentId;
  final String refId;
  const VerifyPaymentParams({required this.paymentId, required this.refId});

  @override
  List<Object> get props => [paymentId, refId];
}

class GetUserPayments extends UseCase<List<PaymentEntity>, String> {
  final PaymentRepository repository;
  GetUserPayments(this.repository);

  @override
  Future<Either<Failure, List<PaymentEntity>>> call(String userId) =>
      repository.getUserPayments(userId);
}
