import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.roomNumber,
    required super.type,
    required super.typeName,
    required super.capacity,
    required super.pricePerNight,
    required super.description,
    required super.amenities,
    required super.imageUrls,
    required super.isAvailable,
    required super.rating,
    required super.reviewCount,
    required super.floor,
  });

  factory RoomModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RoomModel(
      id: doc.id,
      roomNumber: d['room_number'] ?? '',
      type: RoomType.values.firstWhere(
        (t) => t.name == (d['type'] ?? 'standard'),
        orElse: () => RoomType.standard,
      ),
      typeName: d['type_name'] ?? 'Standard',
      capacity: d['capacity'] ?? 2,
      pricePerNight: (d['price_per_night'] ?? 0).toDouble(),
      description: d['description'] ?? '',
      amenities: List<String>.from(d['amenities'] ?? []),
      imageUrls: List<String>.from(d['image_urls'] ?? []),
      isAvailable: d['is_available'] ?? true,
      rating: (d['rating'] ?? 0).toDouble(),
      reviewCount: d['review_count'] ?? 0,
      floor: d['floor'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'room_number': roomNumber,
        'type': type.name,
        'type_name': typeName,
        'capacity': capacity,
        'price_per_night': pricePerNight,
        'description': description,
        'amenities': amenities,
        'image_urls': imageUrls,
        'is_available': isAvailable,
        'rating': rating,
        'review_count': reviewCount,
        'floor': floor,
      };
}
