import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../bloc/payment_bloc.dart';

class PaymentPage extends StatefulWidget {
  final String bookingId;
  const PaymentPage({super.key, required this.bookingId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double _amount = 0;

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(LoadBookingById(widget.bookingId));
  }

  Future<void> _launchEsewa(String paymentId, double amount) async {
    // eSewa payment parameters
    final params = {
      'amt': amount.toInt().toString(),
      'psc': '0', 'pdc': '0',
      'txAmt': '0',
      'tAmt': amount.toInt().toString(),
      'pid': paymentId,
      'scd': AppConstants.esewaMerchantId,
      'su': 'hamroaawashgrihaa://payment/success',
      'fu': 'hamroaawashgrihaa://payment/failed',
    };

    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final url = Uri.parse('${AppConstants.esewaTestUrl}?$query');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch eSewa. Please install eSewa app.'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentInitiated) {
            _launchEsewa(state.payment.id, state.payment.amount);
          }
          if (state is PaymentSuccess) {
            context.go('/payment/success');
          }
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, paymentState) {
          return BlocBuilder<BookingBloc, BookingState>(
            builder: (context, bookingState) {
              if (bookingState is BookingLoading) return const AppLoadingIndicator();
              if (bookingState is! BookingDetailLoaded) return const AppLoadingIndicator();

              final booking = bookingState.booking;
              _amount = booking.totalAmount;

              return Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(children: [
                        const Icon(Icons.payment, size: 48, color: AppColors.primary),
                        SizedBox(height: 12.h),
                        Text('Total Amount', style: TextStyle(color: AppColors.grey600, fontSize: 14.sp)),
                        SizedBox(height: 4.h),
                        Text(
                          'Rs. ${booking.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        SizedBox(height: 8.h),
                        Text('${booking.roomTypeName} · ${booking.nights} nights',
                            style: TextStyle(color: AppColors.grey500, fontSize: 13.sp)),
                      ]),
                    ),
                    SizedBox(height: 32.h),
                    Text('Pay with eSewa', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF60BB46),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text('eSewa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text('Pay securely via eSewa digital wallet',
                              style: TextStyle(fontSize: 13.sp)),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey400),
                      ]),
                    ),
                    const Spacer(),
                    AppButton(
                      label: 'Pay with eSewa',
                      isLoading: paymentState is PaymentLoading,
                      onPressed: () {
                        context.read<PaymentBloc>().add(InitiatePaymentRequested(
                          bookingId: booking.id, amount: booking.totalAmount,
                        ));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle, size: 100.w, color: AppColors.success),
              SizedBox(height: 24.h),
              Text('Payment Successful!', style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 8.h),
              Text('Your booking has been confirmed.', style: TextStyle(color: AppColors.grey600)),
              SizedBox(height: 32.h),
              AppButton(label: 'Go Home', onPressed: () => context.go('/home')),
              SizedBox(height: 12.h),
              AppButton(label: 'View Bookings', outlined: true, onPressed: () => context.go('/booking/history')),
            ]),
          ),
        ),
      );
}
