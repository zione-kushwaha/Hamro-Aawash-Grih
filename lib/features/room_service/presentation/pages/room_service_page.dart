import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';

enum RoomServiceType { cleaning, laundry, maintenance, extraTowels, drinkingWater }
enum RoomServiceStatus { pending, accepted, inProgress, completed }

class RoomServiceRequest extends Equatable {
  final String id;
  final String userId;
  final String roomNumber;
  final RoomServiceType type;
  final RoomServiceStatus status;
  final String? notes;
  final DateTime createdAt;
  const RoomServiceRequest({
    required this.id, required this.userId, required this.roomNumber,
    required this.type, required this.status, this.notes, required this.createdAt,
  });
  @override
  List<Object?> get props => [id];
}

// BLoC
abstract class RoomServiceEvent extends Equatable {
  const RoomServiceEvent();
  @override
  List<Object?> get props => [];
}
class SubmitServiceRequest extends RoomServiceEvent {
  final RoomServiceType type;
  final String roomNumber;
  final String? notes;
  const SubmitServiceRequest({required this.type, required this.roomNumber, this.notes});
  @override
  List<Object?> get props => [type, roomNumber];
}
class LoadServiceRequests extends RoomServiceEvent {
  final String userId;
  const LoadServiceRequests(this.userId);
  @override
  List<Object> get props => [userId];
}

abstract class RoomServiceState extends Equatable {
  const RoomServiceState();
  @override
  List<Object?> get props => [];
}
class RoomServiceInitial extends RoomServiceState {}
class RoomServiceLoading extends RoomServiceState {}
class RoomServiceSubmitted extends RoomServiceState {}
class RoomServiceRequestsLoaded extends RoomServiceState {
  final List<RoomServiceRequest> requests;
  const RoomServiceRequestsLoaded(this.requests);
  @override
  List<Object> get props => [requests];
}
class RoomServiceError extends RoomServiceState {
  final String message;
  const RoomServiceError(this.message);
  @override
  List<Object> get props => [message];
}

class RoomServiceBloc extends Bloc<RoomServiceEvent, RoomServiceState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RoomServiceBloc(this._firestore, this._auth) : super(RoomServiceInitial()) {
    on<SubmitServiceRequest>(_onSubmit);
    on<LoadServiceRequests>(_onLoad);
  }

  Future<void> _onSubmit(SubmitServiceRequest e, Emitter<RoomServiceState> emit) async {
    emit(RoomServiceLoading());
    try {
      final id = const Uuid().v4();
      await _firestore.collection(AppConstants.roomServiceCollection).doc(id).set({
        'user_id': _auth.currentUser?.uid, 'room_number': e.roomNumber,
        'type': e.type.name, 'status': 'pending',
        'notes': e.notes, 'created_at': Timestamp.now(),
      });
      emit(RoomServiceSubmitted());
    } catch (e) {
      emit(RoomServiceError(e.toString()));
    }
  }

  Future<void> _onLoad(LoadServiceRequests e, Emitter<RoomServiceState> emit) async {
    emit(RoomServiceLoading());
    try {
      final snap = await _firestore.collection(AppConstants.roomServiceCollection)
          .where('user_id', isEqualTo: e.userId)
          .orderBy('created_at', descending: true).get();
      final requests = snap.docs.map((d) => RoomServiceRequest(
        id: d.id, userId: d['user_id'], roomNumber: d['room_number'],
        type: RoomServiceType.values.firstWhere((t) => t.name == d['type'], orElse: () => RoomServiceType.cleaning),
        status: RoomServiceStatus.values.firstWhere((s) => s.name == d['status'], orElse: () => RoomServiceStatus.pending),
        notes: d['notes'], createdAt: (d['created_at'] as Timestamp).toDate(),
      )).toList();
      emit(RoomServiceRequestsLoaded(requests));
    } catch (e) {
      emit(RoomServiceError(e.toString()));
    }
  }
}

// Page
class RoomServicePage extends StatefulWidget {
  final String userId;
  final String roomNumber;
  const RoomServicePage({super.key, required this.userId, required this.roomNumber});

  @override
  State<RoomServicePage> createState() => _RoomServicePageState();
}

class _RoomServicePageState extends State<RoomServicePage> {
  RoomServiceType? _selected;
  final _notesController = TextEditingController();

  static const _serviceInfo = {
    RoomServiceType.cleaning: {'label': 'Room Cleaning', 'icon': Icons.cleaning_services},
    RoomServiceType.laundry: {'label': 'Laundry', 'icon': Icons.local_laundry_service},
    RoomServiceType.maintenance: {'label': 'Maintenance', 'icon': Icons.build_outlined},
    RoomServiceType.extraTowels: {'label': 'Extra Towels', 'icon': Icons.dry_cleaning},
    RoomServiceType.drinkingWater: {'label': 'Drinking Water', 'icon': Icons.water_drop_outlined},
  };

  @override
  void initState() {
    super.initState();
    context.read<RoomServiceBloc>().add(LoadServiceRequests(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Service')),
      body: BlocConsumer<RoomServiceBloc, RoomServiceState>(
        listener: (context, state) {
          if (state is RoomServiceSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Request submitted!'), backgroundColor: AppColors.success),
            );
            setState(() => _selected = null);
            context.read<RoomServiceBloc>().add(LoadServiceRequests(widget.userId));
          }
        },
        builder: (context, state) => SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Request a Service', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1,
              children: RoomServiceType.values.map((t) {
                final info = _serviceInfo[t]!;
                final isSelected = _selected == t;
                return GestureDetector(
                  onTap: () => setState(() => _selected = t),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.2) : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey200),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(info['icon'] as IconData, color: isSelected ? AppColors.primary : AppColors.grey500),
                      SizedBox(height: 4.h),
                      Text(info['label'] as String,
                          style: TextStyle(fontSize: 10.sp, color: isSelected ? AppColors.primary : AppColors.grey600),
                          textAlign: TextAlign.center),
                    ]),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
            AppTextField(label: 'Notes (Optional)', hint: 'Any additional details...', controller: _notesController, maxLines: 2),
            SizedBox(height: 16.h),
            AppButton(
              label: 'Submit Request',
              isLoading: state is RoomServiceLoading,
              onPressed: _selected == null ? null : () {
                context.read<RoomServiceBloc>().add(SubmitServiceRequest(
                  type: _selected!, roomNumber: widget.roomNumber, notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                ));
              },
            ),
            SizedBox(height: 24.h),
            Text('Past Requests', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12.h),
            if (state is RoomServiceRequestsLoaded && state.requests.isEmpty)
              const AppEmptyWidget(message: 'No service requests yet')
            else if (state is RoomServiceRequestsLoaded)
              ...state.requests.map((r) => _RequestTile(request: r)),
          ]),
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final RoomServiceRequest request;
  const _RequestTile({required this.request});

  Color get _color {
    switch (request.status) {
      case RoomServiceStatus.pending: return AppColors.pending;
      case RoomServiceStatus.accepted: return AppColors.info;
      case RoomServiceStatus.inProgress: return AppColors.primaryLight;
      case RoomServiceStatus.completed: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(request.type.name, style: Theme.of(context).textTheme.titleSmall),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(request.status.name.toUpperCase(),
                style: TextStyle(color: _color, fontSize: 10.sp, fontWeight: FontWeight.bold)),
          ),
        ]),
      );
}
