import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/room_entity.dart';
import '../bloc/room_bloc.dart';
import '../widgets/room_card.dart';
import '../widgets/room_filter_sheet.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  final _scrollController = ScrollController();
  RoomType? _selectedType;
  double? _maxPrice;
  int? _capacity;

  @override
  void initState() {
    super.initState();
    context.read<RoomBloc>().add(const LoadRooms());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<RoomBloc>().add(LoadMoreRooms());
    }
  }

  void _openFilter() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => RoomFilterSheet(
        selectedType: _selectedType,
        maxPrice: _maxPrice,
        capacity: _capacity,
        onApply: (type, price, cap) {
          setState(() {
            _selectedType = type;
            _maxPrice = price;
            _capacity = cap;
          });
          context.read<RoomBloc>().add(LoadRooms(type: type, maxPrice: price, capacity: cap));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Rooms'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _openFilter),
        ],
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) return const AppLoadingIndicator();
          if (state is RoomError) return AppErrorWidget(message: state.message, onRetry: () => context.read<RoomBloc>().add(const LoadRooms()));
          if (state is RoomsLoaded) {
            if (state.rooms.isEmpty) return const AppEmptyWidget(message: 'No rooms available', icon: Icons.hotel_outlined);
            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: state.rooms.length + (state.hasMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == state.rooms.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: RoomCard(
                    room: state.rooms[i],
                    onTap: () => context.push('/rooms/${state.rooms[i].id}'),
                  ),
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
