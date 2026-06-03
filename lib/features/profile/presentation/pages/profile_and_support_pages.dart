import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

// ─── Notification Entity + BLoC ─────────────────────────────
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  const AppNotification({
    required this.id, required this.title, required this.body,
    required this.type, required this.isRead, required this.createdAt,
  });
  @override
  List<Object> get props => [id];
}

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}
class LoadNotifications extends NotificationEvent {
  final String userId;
  const LoadNotifications(this.userId);
  @override
  List<Object> get props => [userId];
}
class MarkNotificationRead extends NotificationEvent {
  final String notificationId;
  const MarkNotificationRead(this.notificationId);
  @override
  List<Object> get props => [notificationId];
}

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}
class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationsLoaded extends NotificationState {
  final List<AppNotification> notifications;
  const NotificationsLoaded(this.notifications);
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  @override
  List<Object> get props => [notifications];
}
class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object> get props => [message];
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseFirestore _firestore;

  NotificationBloc(this._firestore) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
  }

  Future<void> _onLoad(LoadNotifications e, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final snap = await _firestore.collection(AppConstants.notificationsCollection)
          .where('user_id', isEqualTo: e.userId)
          .orderBy('created_at', descending: true).limit(50).get();
      final notifications = snap.docs.map((d) => AppNotification(
        id: d.id, title: d['title'] ?? '', body: d['body'] ?? '',
        type: d['type'] ?? 'general', isRead: d['is_read'] ?? false,
        createdAt: (d['created_at'] as Timestamp).toDate(),
      )).toList();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkRead(MarkNotificationRead e, Emitter<NotificationState> emit) async {
    await _firestore.collection(AppConstants.notificationsCollection)
        .doc(e.notificationId).update({'is_read': true});
    if (state is NotificationsLoaded) {
      final updated = (state as NotificationsLoaded).notifications.map((n) =>
        n.id == e.notificationId ? AppNotification(
          id: n.id, title: n.title, body: n.body, type: n.type,
          isRead: true, createdAt: n.createdAt,
        ) : n,
      ).toList();
      emit(NotificationsLoaded(updated));
    }
  }
}

// ─── Support Ticket Entity + BLoC ───────────────────────────
enum TicketStatus { open, inProgress, resolved }

class SupportTicket extends Equatable {
  final String id;
  final String userId;
  final String subject;
  final String description;
  final TicketStatus status;
  final DateTime createdAt;
  const SupportTicket({
    required this.id, required this.userId, required this.subject,
    required this.description, required this.status, required this.createdAt,
  });
  @override
  List<Object> get props => [id];
}

abstract class SupportEvent extends Equatable {
  const SupportEvent();
  @override
  List<Object?> get props => [];
}
class SubmitTicket extends SupportEvent {
  final String subject;
  final String description;
  const SubmitTicket({required this.subject, required this.description});
  @override
  List<Object> get props => [subject, description];
}
class LoadTickets extends SupportEvent {
  final String userId;
  const LoadTickets(this.userId);
  @override
  List<Object> get props => [userId];
}

abstract class SupportState extends Equatable {
  const SupportState();
  @override
  List<Object?> get props => [];
}
class SupportInitial extends SupportState {}
class SupportLoading extends SupportState {}
class TicketSubmitted extends SupportState {}
class TicketsLoaded extends SupportState {
  final List<SupportTicket> tickets;
  const TicketsLoaded(this.tickets);
  @override
  List<Object> get props => [tickets];
}
class SupportError extends SupportState {
  final String message;
  const SupportError(this.message);
  @override
  List<Object> get props => [message];
}

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SupportBloc(this._firestore, this._auth) : super(SupportInitial()) {
    on<SubmitTicket>(_onSubmit);
    on<LoadTickets>(_onLoad);
  }

  Future<void> _onSubmit(SubmitTicket e, Emitter<SupportState> emit) async {
    emit(SupportLoading());
    try {
      final id = const Uuid().v4();
      await _firestore.collection(AppConstants.supportTicketsCollection).doc(id).set({
        'user_id': _auth.currentUser?.uid, 'subject': e.subject,
        'description': e.description, 'status': 'open', 'created_at': Timestamp.now(),
      });
      emit(TicketSubmitted());
    } catch (e) {
      emit(SupportError(e.toString()));
    }
  }

  Future<void> _onLoad(LoadTickets e, Emitter<SupportState> emit) async {
    emit(SupportLoading());
    try {
      final snap = await _firestore.collection(AppConstants.supportTicketsCollection)
          .where('user_id', isEqualTo: e.userId)
          .orderBy('created_at', descending: true).get();
      final tickets = snap.docs.map((d) => SupportTicket(
        id: d.id, userId: d['user_id'], subject: d['subject'],
        description: d['description'],
        status: TicketStatus.values.firstWhere((s) => s.name == d['status'], orElse: () => TicketStatus.open),
        createdAt: (d['created_at'] as Timestamp).toDate(),
      )).toList();
      emit(TicketsLoaded(tickets));
    } catch (e) {
      emit(SupportError(e.toString()));
    }
  }
}

// ─── Profile Page ────────────────────────────────────────────
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Sign in to view your profile'),
              SizedBox(height: 16.h),
              AppButton(label: 'Sign In', onPressed: () => context.push('/login'), width: 160.w),
            ]));
          }
          final user = state.user;
          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(children: [
              CircleAvatar(
                radius: 50.r,
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                backgroundColor: AppColors.primaryLight,
                child: user.photoUrl == null
                    ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: TextStyle(fontSize: 32.sp, color: Colors.white))
                    : null,
              ),
              SizedBox(height: 12.h),
              Text(user.name, style: Theme.of(context).textTheme.titleLarge),
              Text(user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500)),
              if (!user.emailVerified) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(20.r)),
                  child: Text('Email not verified', style: TextStyle(color: AppColors.warning, fontSize: 12.sp)),
                ),
              ],
              SizedBox(height: 32.h),
              _MenuSection(items: [
                _MenuItem(icon: Icons.book_outlined, label: 'My Bookings', onTap: () => context.push('/booking/history')),
                _MenuItem(icon: Icons.payment_outlined, label: 'Payment History', onTap: () => context.push('/payment/history')),
                _MenuItem(icon: Icons.restaurant_outlined, label: 'Food Orders', onTap: () => context.push('/food/orders')),
                _MenuItem(icon: Icons.room_service_outlined, label: 'Room Service', onTap: () => context.push('/room-service')),
              ]),
              SizedBox(height: 16.h),
              _MenuSection(items: [
                _MenuItem(icon: Icons.support_outlined, label: 'Support', onTap: () => context.push('/support')),
                _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => context.push('/notifications')),
                _MenuItem(icon: Icons.brightness_6_outlined, label: 'Theme', onTap: () => _showThemePicker(context)),
              ]),
              SizedBox(height: 16.h),
              _MenuSection(items: [
                _MenuItem(icon: Icons.logout, label: 'Sign Out', color: AppColors.error,
                    onTap: () => context.read<AuthBloc>().add(SignOutRequested())),
              ]),
            ]),
          );
        },
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ThemeCubit>(),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Choose Theme', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16.h),
            ListTile(leading: const Icon(Icons.light_mode), title: const Text('Light'),
                onTap: () { context.read<ThemeCubit>().setLight(); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.dark_mode), title: const Text('Dark'),
                onTap: () { context.read<ThemeCubit>().setDark(); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.brightness_auto), title: const Text('System'),
                onTap: () { context.read<ThemeCubit>().setSystem(); Navigator.pop(context); }),
          ]),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4.r)],
        ),
        child: Column(
          children: items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(children: [
              ListTile(
                leading: Icon(e.value.icon, color: e.value.color ?? AppColors.primary),
                title: Text(e.value.label, style: TextStyle(color: e.value.color)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
                onTap: e.value.onTap,
              ),
              if (!isLast) const Divider(height: 1, indent: 56),
            ]);
          }).toList(),
        ),
      );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});
}

// ─── Notifications Page ──────────────────────────────────────
class NotificationsPage extends StatelessWidget {
  final String userId;
  const NotificationsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    context.read<NotificationBloc>().add(LoadNotifications(userId));
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) return const AppLoadingIndicator();
          if (state is NotificationError) return AppErrorWidget(message: state.message);
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) return const AppEmptyWidget(message: 'No notifications yet', icon: Icons.notifications_none);
            return ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = state.notifications[i];
                return ListTile(
                  tileColor: n.isRead ? null : AppColors.primaryLight.withValues(alpha: 0.07),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                    child: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                  ),
                  title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => context.read<NotificationBloc>().add(MarkNotificationRead(n.id)),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ─── Support Page ─────────────────────────────────────────────
class SupportPage extends StatefulWidget {
  final String userId;
  const SupportPage({super.key, required this.userId});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SupportBloc>().add(LoadTickets(widget.userId));
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: BlocConsumer<SupportBloc, SupportState>(
        listener: (context, state) {
          if (state is TicketSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket submitted!'), backgroundColor: AppColors.success),
            );
            _subjectController.clear();
            _descController.clear();
            context.read<SupportBloc>().add(LoadTickets(widget.userId));
          }
        },
        builder: (context, state) => SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Submit a Ticket', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16.h),
            Form(
              key: _formKey,
              child: Column(children: [
                AppTextField(label: 'Subject', hint: 'What is your issue?',
                    controller: _subjectController, validator: (v) => v?.isEmpty == true ? 'Required' : null),
                SizedBox(height: 12.h),
                AppTextField(label: 'Description', hint: 'Describe your issue...',
                    controller: _descController, maxLines: 4, validator: (v) => v?.isEmpty == true ? 'Required' : null),
                SizedBox(height: 16.h),
                AppButton(
                  label: 'Submit Ticket',
                  isLoading: state is SupportLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<SupportBloc>().add(SubmitTicket(
                        subject: _subjectController.text.trim(),
                        description: _descController.text.trim(),
                      ));
                    }
                  },
                ),
              ]),
            ),
            SizedBox(height: 32.h),
            Text('My Tickets', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12.h),
            if (state is TicketsLoaded && state.tickets.isEmpty)
              const AppEmptyWidget(message: 'No tickets submitted yet')
            else if (state is TicketsLoaded)
              ...state.tickets.map((t) => _TicketCard(ticket: t)),
          ]),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  const _TicketCard({required this.ticket});

  Color get _color {
    switch (ticket.status) {
      case TicketStatus.open: return AppColors.pending;
      case TicketStatus.inProgress: return AppColors.info;
      case TicketStatus.resolved: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(ticket.subject, style: Theme.of(context).textTheme.titleSmall)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(ticket.status.name.toUpperCase(),
                  style: TextStyle(color: _color, fontSize: 10.sp, fontWeight: FontWeight.bold)),
            ),
          ]),
          SizedBox(height: 6.h),
          Text(ticket.description, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      );
}
