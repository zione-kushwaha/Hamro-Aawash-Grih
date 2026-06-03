import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/room_entity.dart';

class RoomCard extends StatelessWidget {
  final RoomEntity room;
  final VoidCallback onTap;

  const RoomCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Theme.of(context).cardTheme.color,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8.r, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppNetworkImage(
                  url: room.primaryImage,
                  height: 180.h,
                  width: double.infinity,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                ),
                if (!room.isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                      ),
                      child: const Center(child: Text('Not Available', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                  ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(room.typeName, style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Room ${room.roomNumber}', style: Theme.of(context).textTheme.titleSmall),
                      Row(children: [
                        const Icon(Icons.star, color: AppColors.secondary, size: 14),
                        SizedBox(width: 2.w),
                        Text(room.rating.toStringAsFixed(1), style: TextStyle(fontSize: 12.sp)),
                      ]),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(children: [
                    const Icon(Icons.people_outline, size: 14, color: AppColors.grey500),
                    SizedBox(width: 4.w),
                    Text('${room.capacity} guests', style: TextStyle(fontSize: 12.sp, color: AppColors.grey500)),
                    SizedBox(width: 12.w),
                    const Icon(Icons.layers_outlined, size: 14, color: AppColors.grey500),
                    SizedBox(width: 4.w),
                    Text('Floor ${room.floor}', style: TextStyle(fontSize: 12.sp, color: AppColors.grey500)),
                  ]),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        spacing: 4.w,
                        children: room.amenities.take(2).map((a) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(a, style: TextStyle(fontSize: 10.sp)),
                        )).toList(),
                      ),
                      Text(
                        'Rs. ${room.pricePerNight.toStringAsFixed(0)}/night',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
