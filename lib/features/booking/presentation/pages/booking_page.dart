import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/booking_bloc.dart';

class BookingPage extends StatefulWidget {
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;

  const BookingPage({
    super.key, required this.roomId, required this.checkIn, required this.checkOut,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _guestCount = 1;
  final _requestController = TextEditingController();

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  int get _nights => widget.checkOut.difference(widget.checkIn).inDays;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingCreated) {
            context.go('/booking/confirmation/${state.booking.id}');
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(
                checkIn: widget.checkIn, checkOut: widget.checkOut, nights: _nights,
              ),
              SizedBox(height: 20.h),
              Text('Number of Guests', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 12.h),
              Row(children: [
                IconButton(
                  onPressed: _guestCount > 1 ? () => setState(() => _guestCount--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.primary,
                ),
                Text('$_guestCount', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _guestCount < 6 ? () => setState(() => _guestCount++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                ),
              ]),
              SizedBox(height: 20.h),
              AppTextField(
                label: 'Special Requests (Optional)',
                hint: 'Any special requirements...',
                controller: _requestController,
                maxLines: 3,
              ),
              SizedBox(height: 32.h),
              BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) => AppButton(
                  label: 'Proceed to Payment',
                  isLoading: state is BookingLoading,
                  onPressed: () {
                    context.read<BookingBloc>().add(CreateBookingRequested(
                      roomId: widget.roomId, checkIn: widget.checkIn,
                      checkOut: widget.checkOut, guestCount: _guestCount,
                      specialRequests: _requestController.text.trim().isEmpty
                          ? null : _requestController.text.trim(),
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;

  const _SummaryCard({required this.checkIn, required this.checkOut, required this.nights});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          _Row(label: 'Check-In', value: '${checkIn.day}/${checkIn.month}/${checkIn.year}'),
          SizedBox(height: 8.h),
          _Row(label: 'Check-Out', value: '${checkOut.day}/${checkOut.month}/${checkOut.year}'),
          SizedBox(height: 8.h),
          _Row(label: 'Duration', value: '$nights night${nights > 1 ? 's' : ''}'),
        ]),
      );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.grey600, fontSize: 14.sp)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        ],
      );
}
