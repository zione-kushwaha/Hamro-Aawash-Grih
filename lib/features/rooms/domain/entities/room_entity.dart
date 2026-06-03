import 'package:equatable/equatable.dart';

enum RoomType { standard, deluxe, suite, presidential }

class RoomEntity extends Equatable {
  final String id;
  final String roomNumber;
  final RoomType type;
  final String typeName;
  final int capacity;
  final double pricePerNight;
  final String description;
  final List<String> amenities;
  final List<String> imageUrls;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final int floor;

  const RoomEntity({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.typeName,
    required this.capacity,
    required this.pricePerNight,
    required this.description,
    required this.amenities,
    required this.imageUrls,
    required this.isAvailable,
    required this.rating,
    required this.reviewCount,
    required this.floor,
  });

  String get primaryImage =>
      imageUrls.isNotEmpty ? imageUrls.first : 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800';

  @override
  List<Object?> get props => [id, roomNumber, type, pricePerNight, isAvailable];
}
