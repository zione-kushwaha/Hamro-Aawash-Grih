import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/usecases/room_usecases.dart';

// Events
abstract class RoomEvent extends Equatable {
  const RoomEvent();
  @override
  List<Object?> get props => [];
}

class LoadRooms extends RoomEvent {
  final RoomType? type;
  final double? maxPrice;
  final int? capacity;
  final bool refresh;
  const LoadRooms({this.type, this.maxPrice, this.capacity, this.refresh = false});
  @override
  List<Object?> get props => [type, maxPrice, capacity, refresh];
}

class LoadMoreRooms extends RoomEvent {}

class LoadRoomById extends RoomEvent {
  final String id;
  const LoadRoomById(this.id);
  @override
  List<Object> get props => [id];
}

class LoadFeaturedRooms extends RoomEvent {}

class CheckAvailability extends RoomEvent {
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  const CheckAvailability({required this.roomId, required this.checkIn, required this.checkOut});
  @override
  List<Object> get props => [roomId, checkIn, checkOut];
}

class SearchRooms extends RoomEvent {
  final String query;
  const SearchRooms(this.query);
  @override
  List<Object> get props => [query];
}

// States
abstract class RoomState extends Equatable {
  const RoomState();
  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}
class RoomLoading extends RoomState {}

class RoomsLoaded extends RoomState {
  final List<RoomEntity> rooms;
  final bool hasMore;
  final String? lastDocId;
  const RoomsLoaded({required this.rooms, required this.hasMore, this.lastDocId});
  @override
  List<Object?> get props => [rooms, hasMore];
}

class RoomDetailLoaded extends RoomState {
  final RoomEntity room;
  final bool? isAvailable;
  const RoomDetailLoaded({required this.room, this.isAvailable});
  @override
  List<Object?> get props => [room, isAvailable];
}

class FeaturedRoomsLoaded extends RoomState {
  final List<RoomEntity> rooms;
  const FeaturedRoomsLoaded(this.rooms);
  @override
  List<Object> get props => [rooms];
}

class RoomError extends RoomState {
  final String message;
  const RoomError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final GetRooms getRooms;
  final GetRoomById getRoomById;
  final GetFeaturedRooms getFeaturedRooms;
  final CheckRoomAvailability checkRoomAvailability;

  List<RoomEntity> _rooms = [];
  String? _lastDocId;
  RoomType? _currentType;
  double? _currentMaxPrice;
  int? _currentCapacity;

  RoomBloc({
    required this.getRooms,
    required this.getRoomById,
    required this.getFeaturedRooms,
    required this.checkRoomAvailability,
  }) : super(RoomInitial()) {
    on<LoadRooms>(_onLoadRooms);
    on<LoadMoreRooms>(_onLoadMoreRooms);
    on<LoadRoomById>(_onLoadRoomById);
    on<LoadFeaturedRooms>(_onLoadFeaturedRooms);
    on<CheckAvailability>(_onCheckAvailability);
  }

  Future<void> _onLoadRooms(LoadRooms event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    _currentType = event.type;
    _currentMaxPrice = event.maxPrice;
    _currentCapacity = event.capacity;
    _rooms = [];
    _lastDocId = null;

    final result = await getRooms(GetRoomsParams(
      type: event.type, maxPrice: event.maxPrice, capacity: event.capacity,
    ));
    result.fold(
      (f) => emit(RoomError(f.message)),
      (rooms) {
        _rooms = rooms;
        _lastDocId = rooms.isNotEmpty ? rooms.last.id : null;
        emit(RoomsLoaded(rooms: rooms, hasMore: rooms.length == 10, lastDocId: _lastDocId));
      },
    );
  }

  Future<void> _onLoadMoreRooms(LoadMoreRooms event, Emitter<RoomState> emit) async {
    if (state is! RoomsLoaded || !(state as RoomsLoaded).hasMore) return;
    final result = await getRooms(GetRoomsParams(
      type: _currentType, maxPrice: _currentMaxPrice, capacity: _currentCapacity,
      lastDocumentId: _lastDocId,
    ));
    result.fold(
      (f) => emit(RoomError(f.message)),
      (rooms) {
        _rooms = [..._rooms, ...rooms];
        _lastDocId = rooms.isNotEmpty ? rooms.last.id : _lastDocId;
        emit(RoomsLoaded(rooms: _rooms, hasMore: rooms.length == 10, lastDocId: _lastDocId));
      },
    );
  }

  Future<void> _onLoadRoomById(LoadRoomById event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await getRoomById(event.id);
    result.fold(
      (f) => emit(RoomError(f.message)),
      (room) => emit(RoomDetailLoaded(room: room)),
    );
  }

  Future<void> _onLoadFeaturedRooms(LoadFeaturedRooms event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    final result = await getFeaturedRooms(NoParams());
    result.fold(
      (f) => emit(RoomError(f.message)),
      (rooms) => emit(FeaturedRoomsLoaded(rooms)),
    );
  }

  Future<void> _onCheckAvailability(CheckAvailability event, Emitter<RoomState> emit) async {
    if (state is RoomDetailLoaded) {
      final room = (state as RoomDetailLoaded).room;
      final result = await checkRoomAvailability(
        CheckAvailabilityParams(roomId: event.roomId, checkIn: event.checkIn, checkOut: event.checkOut),
      );
      result.fold(
        (f) => emit(RoomError(f.message)),
        (available) => emit(RoomDetailLoaded(room: room, isAvailable: available)),
      );
    }
  }
}
