import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/room_entity.dart';

abstract class RoomRepository {
  Future<Either<Failure, List<RoomEntity>>> getRooms({
    RoomType? type,
    double? maxPrice,
    int? capacity,
    DateTime? checkIn,
    DateTime? checkOut,
    String? searchQuery,
    String? lastDocumentId,
    int pageSize = 10,
  });
  Future<Either<Failure, RoomEntity>> getRoomById(String id);
  Future<Either<Failure, List<RoomEntity>>> getFeaturedRooms();
  Future<Either<Failure, bool>> checkAvailability(String roomId, DateTime checkIn, DateTime checkOut);
}
