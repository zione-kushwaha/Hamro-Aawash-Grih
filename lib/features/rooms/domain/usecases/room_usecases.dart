import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

class GetRooms extends UseCase<List<RoomEntity>, GetRoomsParams> {
  final RoomRepository repository;
  GetRooms(this.repository);

  @override
  Future<Either<Failure, List<RoomEntity>>> call(GetRoomsParams params) => repository.getRooms(
        type: params.type,
        maxPrice: params.maxPrice,
        capacity: params.capacity,
        checkIn: params.checkIn,
        checkOut: params.checkOut,
        searchQuery: params.searchQuery,
        lastDocumentId: params.lastDocumentId,
        pageSize: params.pageSize,
      );
}

class GetRoomsParams extends Equatable {
  final RoomType? type;
  final double? maxPrice;
  final int? capacity;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? searchQuery;
  final String? lastDocumentId;
  final int pageSize;

  const GetRoomsParams({
    this.type,
    this.maxPrice,
    this.capacity,
    this.checkIn,
    this.checkOut,
    this.searchQuery,
    this.lastDocumentId,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [type, maxPrice, capacity, checkIn, checkOut, searchQuery, lastDocumentId];
}

class GetRoomById extends UseCase<RoomEntity, String> {
  final RoomRepository repository;
  GetRoomById(this.repository);

  @override
  Future<Either<Failure, RoomEntity>> call(String id) => repository.getRoomById(id);
}

class GetFeaturedRooms extends UseCase<List<RoomEntity>, NoParams> {
  final RoomRepository repository;
  GetFeaturedRooms(this.repository);

  @override
  Future<Either<Failure, List<RoomEntity>>> call(NoParams params) => repository.getFeaturedRooms();
}

class CheckRoomAvailability extends UseCase<bool, CheckAvailabilityParams> {
  final RoomRepository repository;
  CheckRoomAvailability(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckAvailabilityParams params) =>
      repository.checkAvailability(params.roomId, params.checkIn, params.checkOut);
}

class CheckAvailabilityParams extends Equatable {
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  const CheckAvailabilityParams({required this.roomId, required this.checkIn, required this.checkOut});

  @override
  List<Object> get props => [roomId, checkIn, checkOut];
}
