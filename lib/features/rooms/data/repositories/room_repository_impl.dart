import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_remote_datasource.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RoomRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<RoomEntity>>> getRooms({
    RoomType? type, double? maxPrice, int? capacity,
    DateTime? checkIn, DateTime? checkOut, String? searchQuery,
    String? lastDocumentId, int pageSize = 10,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final rooms = await remoteDataSource.getRooms(
        type: type, maxPrice: maxPrice, capacity: capacity,
        lastDocumentId: lastDocumentId, pageSize: pageSize,
      );
      return Right(rooms);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, RoomEntity>> getRoomById(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.getRoomById(id));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<RoomEntity>>> getFeaturedRooms() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.getFeaturedRooms());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAvailability(String roomId, DateTime checkIn, DateTime checkOut) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.checkAvailability(roomId, checkIn, checkOut));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
