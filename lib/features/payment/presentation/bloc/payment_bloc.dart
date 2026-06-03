import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/payment_usecases.dart';

// Events
abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object?> get props => [];
}

class InitiatePaymentRequested extends PaymentEvent {
  final String bookingId;
  final double amount;
  const InitiatePaymentRequested({required this.bookingId, required this.amount});
  @override
  List<Object> get props => [bookingId, amount];
}

class VerifyPaymentRequested extends PaymentEvent {
  final String paymentId;
  final String refId;
  const VerifyPaymentRequested({required this.paymentId, required this.refId});
  @override
  List<Object> get props => [paymentId, refId];
}

class LoadUserPayments extends PaymentEvent {
  final String userId;
  const LoadUserPayments(this.userId);
  @override
  List<Object> get props => [userId];
}

// States
abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}
class PaymentLoading extends PaymentState {}

class PaymentInitiated extends PaymentState {
  final PaymentEntity payment;
  const PaymentInitiated(this.payment);
  @override
  List<Object> get props => [payment];
}

class PaymentSuccess extends PaymentState {
  final PaymentEntity payment;
  const PaymentSuccess(this.payment);
  @override
  List<Object> get props => [payment];
}

class PaymentsLoaded extends PaymentState {
  final List<PaymentEntity> payments;
  const PaymentsLoaded(this.payments);
  @override
  List<Object> get props => [payments];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final InitiatePayment initiatePayment;
  final VerifyPayment verifyPayment;
  final GetUserPayments getUserPayments;

  PaymentBloc({
    required this.initiatePayment, required this.verifyPayment, required this.getUserPayments,
  }) : super(PaymentInitial()) {
    on<InitiatePaymentRequested>(_onInitiate);
    on<VerifyPaymentRequested>(_onVerify);
    on<LoadUserPayments>(_onLoadPayments);
  }

  Future<void> _onInitiate(InitiatePaymentRequested e, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    final result = await initiatePayment(InitiatePaymentParams(bookingId: e.bookingId, amount: e.amount));
    result.fold((f) => emit(PaymentError(f.message)), (p) => emit(PaymentInitiated(p)));
  }

  Future<void> _onVerify(VerifyPaymentRequested e, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    final result = await verifyPayment(VerifyPaymentParams(paymentId: e.paymentId, refId: e.refId));
    result.fold((f) => emit(PaymentError(f.message)), (p) => emit(PaymentSuccess(p)));
  }

  Future<void> _onLoadPayments(LoadUserPayments e, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    final result = await getUserPayments(e.userId);
    result.fold((f) => emit(PaymentError(f.message)), (p) => emit(PaymentsLoaded(p)));
  }
}
