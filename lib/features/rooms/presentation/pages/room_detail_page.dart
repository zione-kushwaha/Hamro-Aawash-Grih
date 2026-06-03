import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/room_bloc.dart';

class RoomDetailPage extends StatefulWidget {
  final String roomId;
  const RoomDetailPage({super.key, required this.roomId});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  DateTime? _checkIn;
  DateTime? _checkOut;

  @override
  void initState() {
    super.initState();
    context.read<RoomBloc>().add(LoadRoomById(widget.roomId));
  }

  Future<void> _pickDate(bool isCheckIn) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? now
          : (_checkIn?.add(const Duration(days: 1)) ?? now.add(const Duration(days: 1))),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        _checkOut = null;
      } else {
        _checkOut = picked;
      }
    });
    if (!isCheckIn && _checkIn != null) {
      context.read<RoomBloc>().add(
            CheckAvailability(roomId: widget.roomId, checkIn: _checkIn!, checkOut: picked),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomBloc, RoomState>(
      builder: (context, state) {
        if (state is RoomLoading) return const Scaffold(body: AppLoadingIndicator());
        if (state is RoomError) return Scaffold(body: AppErrorWidget(message: state.message));
        if (state is! RoomDetailLoaded) return const Scaffold(body: AppLoadingIndicator());

        final room = state.room;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280.h,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: AppNetworkImage(url: room.primaryImage, height: 280.h),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(20.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(room.typeName,
                              style: Theme.of(context).textTheme.headlineSmall),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(
                            'Rs. ${room.pricePerNight.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          ),
                          Text('/night',
                              style: TextStyle(fontSize: 12.sp, color: AppColors.grey500)),
                        ]),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(children: [
                      const Icon(Icons.star, color: AppColors.secondary, size: 18),
                      SizedBox(width: 4.w),
                      Text('${room.rating} (${room.reviewCount} reviews)',
                          style: Theme.of(context).textTheme.bodySmall),
                      SizedBox(width: 16.w),
                      const Icon(Icons.people_outline, size: 18, color: AppColors.grey600),
                      SizedBox(width: 4.w),
                      Text('Up to ${room.capacity} guests',
                          style: Theme.of(context).textTheme.bodySmall),
                    ]),
                    SizedBox(height: 16.h),
                    Text('Description', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8.h),
                    Text(room.description, style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(height: 16.h),
                    Text('Amenities', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: room.amenities
                          .map((a) => Chip(label: Text(a, style: TextStyle(fontSize: 12.sp))))
                          .toList(),
                    ),
                    SizedBox(height: 24.h),
                    Text('Select Dates', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 12.h),
                    Row(children: [
                      Expanded(
                          child: _DateCard(
                              label: 'Check-In', date: _checkIn, onTap: () => _pickDate(true))),
                      SizedBox(width: 12.w),
                      Expanded(
                          child: _DateCard(
                              label: 'Check-Out', date: _checkOut, onTap: () => _pickDate(false))),
                    ]),
                    if (state.isAvailable != null) ...[
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: state.isAvailable! ? AppColors.successLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(children: [
                          Icon(state.isAvailable! ? Icons.check_circle : Icons.cancel,
                              color: state.isAvailable! ? AppColors.success : AppColors.error),
                          SizedBox(width: 8.w),
                          Text(state.isAvailable!
                              ? 'Available for selected dates'
                              : 'Not available for selected dates'),
                        ]),
                      ),
                    ],
                    SizedBox(height: 32.h),
                  ]),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(16.w),
            child: AppButton(
              label: 'Book Now',
              onPressed: (state.isAvailable == true && _checkIn != null && _checkOut != null)
                  ? () => context.push('/booking/${room.id}',
                      extra: {'checkIn': _checkIn, 'checkOut': _checkOut})
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class _DateCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DateCard({required this.label, this.date, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.grey500)),
            SizedBox(height: 4.h),
            Text(
              date != null ? '${date!.day}/${date!.month}/${date!.year}' : 'Select date',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ]),
        ),
      );
}
