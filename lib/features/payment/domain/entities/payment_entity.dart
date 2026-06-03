import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, success, failed, cancelled, refunded }
enum PaymentProvider { esewa }

class PaymentEntity extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final PaymentStatus status;
  final PaymentProvider provider;
  final String? transactionId;
  final String? refId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentEntity({
    required this.id, required this.bookingId, required this.userId,
    required this.amount, required this.status, required this.provider,
    this.transactionId, this.refId, required this.createdAt, this.updatedAt,
  });

  @override
  List<Object?> get props => [id, bookingId, status];
}
