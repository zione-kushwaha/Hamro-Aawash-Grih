import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/booking_entity.dart';
import '../bloc/booking_bloc.dart';

class BookingHistoryPage extends StatelessWidget {
  final String userId;
  const BookingHistoryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    context.read<BookingBloc>().add(LoadUserBookings(userId));
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) return const AppLoadingIndicator();
          if (state is BookingError) return AppErrorWidget(message: state.message);
          if (state is BookingsLoaded) {
            if (state.bookings.isEmpty) {
              return const AppEmptyWidget(message: 'No bookings yet', icon: Icons.hotel_outlined);
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: state.bookings.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) => BookingCard(
                booking: state.bookings[i],
                onTap: () => context.push('/booking/detail/${state.bookings[i].id}'),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback onTap;
  const BookingCard({super.key, required this.booking, required this.onTap});

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.pending: return AppColors.pending;
      case BookingStatus.confirmed: return AppColors.confirmed;
      case BookingStatus.checkedIn: return AppColors.checkedIn;
      case BookingStatus.checkedOut: return AppColors.checkedOut;
      case BookingStatus.cancelled: return AppColors.cancelled;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6.r)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(booking.roomTypeName, style: Theme.of(context).textTheme.titleSmall),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  booking.status.name.toUpperCase(),
                  style: TextStyle(color: _statusColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ]),
            SizedBox(height: 8.h),
            Text('Room ${booking.roomNumber}', style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: 4.h),
            Row(children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.grey500),
              SizedBox(width: 4.w),
              Text(
                '${booking.checkIn.day}/${booking.checkIn.month} - ${booking.checkOut.day}/${booking.checkOut.month}/${booking.checkOut.year}',
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
              ),
              SizedBox(width: 12.w),
              Text('(${booking.nights} nights)', style: TextStyle(fontSize: 12.sp, color: AppColors.grey500)),
            ]),
            SizedBox(height: 8.h),
            Text('Rs. ${booking.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ]),
        ),
      );
}

class BookingConfirmationPage extends StatelessWidget {
  final String bookingId;
  const BookingConfirmationPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    context.read<BookingBloc>().add(LoadBookingById(bookingId));
    return Scaffold(
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) return const AppLoadingIndicator();
          if (state is BookingError) return AppErrorWidget(message: state.message);
          if (state is! BookingDetailLoaded) return const AppLoadingIndicator();
          final b = state.booking;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 80.w, color: AppColors.success),
                  SizedBox(height: 16.h),
                  Text('Booking Confirmed!', style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 8.h),
                  Text('Your booking ID: ${b.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(color: AppColors.grey600, fontSize: 13.sp)),
                  SizedBox(height: 32.h),
                  _DetailRow(label: 'Room', value: '${b.roomTypeName} - ${b.roomNumber}'),
                  _DetailRow(label: 'Check-In', value: '${b.checkIn.day}/${b.checkIn.month}/${b.checkIn.year}'),
                  _DetailRow(label: 'Check-Out', value: '${b.checkOut.day}/${b.checkOut.month}/${b.checkOut.year}'),
                  _DetailRow(label: 'Guests', value: '${b.guestCount}'),
                  _DetailRow(label: 'Total', value: 'Rs. ${b.totalAmount.toStringAsFixed(0)}'),
                  SizedBox(height: 32.h),
                  AppButton(
                    label: 'Pay Now',
                    onPressed: () => context.push('/payment/${b.id}'),
                  ),
                  SizedBox(height: 12.h),
                  AppButton(
                    label: 'Pay Later',
                    outlined: true,
                    onPressed: () => context.go('/home'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: AppColors.grey600, fontSize: 14.sp)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        ]),
      );
}
