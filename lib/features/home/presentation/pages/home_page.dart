import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final _pages = const [
    _HomeTab(),
    _RoomsTab(),
    _BookingsTab(),
    _FoodTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel_outlined), activeIcon: Icon(Icons.hotel), label: 'Rooms'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_outlined), activeIcon: Icon(Icons.restaurant), label: 'Food'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200.h,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Hamro Aawash Grihaa'),
            background: Image.network(
              'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
              fit: BoxFit.cover,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push(AppRoutes.notifications),
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => state is Authenticated
                  ? IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => sl<AuthBloc>().add(SignOutRequested()),
                    )
                  : IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: () => context.push(AppRoutes.login),
                    ),
            ),
          ],
        ),
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _WelcomeBanner(),
              SizedBox(height: 24.h),
              _SectionHeader(title: 'Featured Rooms', onSeeAll: () => context.push(AppRoutes.roomList)),
              SizedBox(height: 12.h),
              _FeaturedRoomsPlaceholder(),
              SizedBox(height: 24.h),
              _SectionHeader(title: 'Hotel Facilities'),
              SizedBox(height: 12.h),
              _FacilitiesGrid(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Experience Luxury', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text('Book your perfect stay with us', style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
          SizedBox(height: 16.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () => context.push(AppRoutes.roomList),
            child: const Text('Explore Rooms', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('See All')),
        ],
      );
}

class _FeaturedRoomsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 180.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (_, __) => SizedBox(width: 12.w),
          itemBuilder: (_, i) => _RoomCard(index: i),
        ),
      );
}

class _RoomCard extends StatelessWidget {
  final int index;
  const _RoomCard({required this.index});

  static const _rooms = [
    {'name': 'Deluxe Room', 'price': 'Rs. 5,000/night', 'img': 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400'},
    {'name': 'Suite Room', 'price': 'Rs. 8,000/night', 'img': 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400'},
    {'name': 'Standard Room', 'price': 'Rs. 3,000/night', 'img': 'https://images.unsplash.com/photo-1505693314120-0d443867891c?w=400'},
    {'name': 'Presidential', 'price': 'Rs. 15,000/night', 'img': 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=400'},
  ];

  @override
  Widget build(BuildContext context) => Container(
        width: 160.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Theme.of(context).cardTheme.color,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.r)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Image.network(_rooms[index]['img']!, height: 110.h, width: 160.w, fit: BoxFit.cover),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_rooms[index]['name']!, style: Theme.of(context).textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  Text(_rooms[index]['price']!, style: TextStyle(color: AppColors.primary, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _FacilitiesGrid extends StatelessWidget {
  static const _facilities = [
    {'icon': Icons.wifi, 'label': 'Free WiFi'},
    {'icon': Icons.pool, 'label': 'Swimming Pool'},
    {'icon': Icons.restaurant, 'label': 'Restaurant'},
    {'icon': Icons.fitness_center, 'label': 'Gym'},
    {'icon': Icons.spa, 'label': 'Spa'},
    {'icon': Icons.local_parking, 'label': 'Parking'},
  ];

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: _facilities.length,
        itemBuilder: (_, i) => Container(
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_facilities[i]['icon'] as IconData, color: AppColors.primary, size: 28.w),
              SizedBox(height: 6.h),
              Text(_facilities[i]['label'] as String, style: TextStyle(fontSize: 11.sp), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _RoomsTab extends StatelessWidget {
  const _RoomsTab();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Rooms - Full Implementation Coming')),
      );
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Bookings - Full Implementation Coming')),
      );
}

class _FoodTab extends StatelessWidget {
  const _FoodTab();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Food - Full Implementation Coming')),
      );
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48.r,
                    backgroundImage: state.user.photoUrl != null
                        ? NetworkImage(state.user.photoUrl!)
                        : null,
                    child: state.user.photoUrl == null
                        ? Text(state.user.name[0].toUpperCase(), style: TextStyle(fontSize: 32.sp))
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  Text(state.user.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(state.user.email, style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(height: 32.h),
                  ListTile(
                    leading: const Icon(Icons.book_outlined),
                    title: const Text('My Bookings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.bookingHistory),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap: () => sl<AuthBloc>().add(SignOutRequested()),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please sign in to view your profile'),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => context.push(AppRoutes.login),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
