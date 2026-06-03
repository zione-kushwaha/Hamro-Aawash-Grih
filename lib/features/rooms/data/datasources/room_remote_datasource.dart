import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/room_entity.dart';
import '../models/room_model.dart';

abstract class RoomRemoteDataSource {
  Future<List<RoomModel>> getRooms({
    RoomType? type,
    double? maxPrice,
    int? capacity,
    String? lastDocumentId,
    int pageSize = 10,
  });
  Future<RoomModel> getRoomById(String id);
  Future<List<RoomModel>> getFeaturedRooms();
  Future<bool> checkAvailability(String roomId, DateTime checkIn, DateTime checkOut);
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final FirebaseFirestore _firestore;

  RoomRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<RoomModel>> getRooms({
    RoomType? type,
    double? maxPrice,
    int? capacity,
    String? lastDocumentId,
    int pageSize = 10,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(AppConstants.roomsCollection)
          .where('is_available', isEqualTo: true)
          .orderBy('price_per_night')
          .limit(pageSize);

      if (type != null) query = query.where('type', isEqualTo: type.name);
      if (maxPrice != null) query = query.where('price_per_night', isLessThanOrEqualTo: maxPrice);
      if (capacity != null) query = query.where('capacity', isGreaterThanOrEqualTo: capacity);

      if (lastDocumentId != null) {
        final lastDoc = await _firestore.collection(AppConstants.roomsCollection).doc(lastDocumentId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs.map(RoomModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RoomModel> getRoomById(String id) async {
    try {
      final doc = await _firestore.collection(AppConstants.roomsCollection).doc(id).get();
      if (!doc.exists) throw const NotFoundException('Room not found');
      return RoomModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<RoomModel>> getFeaturedRooms() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.roomsCollection)
          .where('is_available', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(6)
          .get();
      return snapshot.docs.map(RoomModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> checkAvailability(String roomId, DateTime checkIn, DateTime checkOut) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('room_id', isEqualTo: roomId)
          .where('status', whereIn: ['confirmed', 'checked_in'])
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final bookedIn = (data['check_in'] as Timestamp).toDate();
        final bookedOut = (data['check_out'] as Timestamp).toDate();
        if (checkIn.isBefore(bookedOut) && checkOut.isAfter(bookedIn)) return false;
      }
      return true;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
