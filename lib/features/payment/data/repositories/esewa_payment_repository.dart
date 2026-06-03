import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';

// eSewa implementation - new providers (Khalti, Stripe) can be added
// by creating new classes implementing PaymentRepository without modifying this
class EsewaPaymentRepository implements PaymentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  EsewaPaymentRepository(this._firestore, this._auth);

  @override
  Future<Either<Failure, PaymentEntity>> initiatePayment({
    required String bookingId, required double amount,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const Left(AuthFailure('Not authenticated'));

      final paymentId = const Uuid().v4();
      final payment = PaymentEntity(
        id: paymentId, bookingId: bookingId, userId: user.uid,
        amount: amount, status: PaymentStatus.pending,
        provider: PaymentProvider.esewa, createdAt: DateTime.now(),
      );

      await _firestore.collection(AppConstants.paymentsCollection).doc(paymentId).set({
        'id': paymentId, 'booking_id': bookingId, 'user_id': user.uid,
        'amount': amount, 'status': 'pending', 'provider': 'esewa',
        'created_at': Timestamp.fromDate(payment.createdAt),
      });

      // Update booking with payment id
      await _firestore.collection(AppConstants.bookingsCollection).doc(bookingId).update({
        'payment_id': paymentId,
      });

      return Right(payment);
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> verifyPayment({
    required String paymentId, required String refId,
  }) async {
    try {
      // In production: call eSewa verification API here
      // POST https://esewa.com.np/epay/transrec with pid, rid, amt, scd
      await _firestore.collection(AppConstants.paymentsCollection).doc(paymentId).update({
        'status': 'success', 'ref_id': refId, 'updated_at': Timestamp.now(),
      });

      final doc = await _firestore.collection(AppConstants.paymentsCollection).doc(paymentId).get();
      final d = doc.data()!;

      // Update booking to confirmed
      await _firestore.collection(AppConstants.bookingsCollection)
          .doc(d['booking_id']).update({'status': 'confirmed'});

      return Right(PaymentEntity(
        id: paymentId, bookingId: d['booking_id'], userId: d['user_id'],
        amount: (d['amount'] as num).toDouble(), status: PaymentStatus.success,
        provider: PaymentProvider.esewa, refId: refId,
        createdAt: (d['created_at'] as Timestamp).toDate(), updatedAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getUserPayments(String userId) async {
    try {
      final snapshot = await _firestore.collection(AppConstants.paymentsCollection)
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();
      return Right(snapshot.docs.map((doc) {
        final d = doc.data();
        return PaymentEntity(
          id: doc.id, bookingId: d['booking_id'], userId: d['user_id'],
          amount: (d['amount'] as num).toDouble(),
          status: PaymentStatus.values.firstWhere((s) => s.name == d['status'], orElse: () => PaymentStatus.pending),
          provider: PaymentProvider.esewa, transactionId: d['transaction_id'],
          refId: d['ref_id'], createdAt: (d['created_at'] as Timestamp).toDate(),
        );
      }).toList());
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> getPaymentById(String id) async {
    try {
      final doc = await _firestore.collection(AppConstants.paymentsCollection).doc(id).get();
      if (!doc.exists) return const Left(NotFoundFailure('Payment not found'));
      final d = doc.data()!;
      return Right(PaymentEntity(
        id: doc.id, bookingId: d['booking_id'], userId: d['user_id'],
        amount: (d['amount'] as num).toDouble(),
        status: PaymentStatus.values.firstWhere((s) => s.name == d['status'], orElse: () => PaymentStatus.pending),
        provider: PaymentProvider.esewa, createdAt: (d['created_at'] as Timestamp).toDate(),
      ));
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestRefund(String paymentId) async {
    try {
      await _firestore.collection(AppConstants.paymentsCollection).doc(paymentId).update({
        'status': 'refunded', 'updated_at': Timestamp.now(),
      });
      return const Right(null);
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }
}
