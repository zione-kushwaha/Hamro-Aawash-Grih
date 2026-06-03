import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/food_bloc.dart';

class FoodMenuPage extends StatefulWidget {
  const FoodMenuPage({super.key});

  @override
  State<FoodMenuPage> createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<FoodBloc>().add(LoadFoodMenu());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Menu'),
        actions: [
          BlocBuilder<FoodBloc, FoodState>(
            builder: (context, state) {
              final count = state is FoodMenuLoaded ? state.cartCount : 0;
              return Stack(children: [
                IconButton(icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push('/food/cart')),
                if (count > 0)
                  Positioned(right: 8, top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                      child: Text('$count', style: TextStyle(color: Colors.white, fontSize: 10.sp)),
                    ),
                  ),
              ]);
            },
          ),
        ],
      ),
      body: BlocBuilder<FoodBloc, FoodState>(
        builder: (context, state) {
          if (state is FoodLoading) return const AppLoadingIndicator();
          if (state is FoodError) return AppErrorWidget(message: state.message, onRetry: () => context.read<FoodBloc>().add(LoadFoodMenu()));
          if (state is! FoodMenuLoaded) return const SizedBox();

          final filteredItems = _selectedCategoryId == null
              ? state.items
              : state.items.where((i) => i.categoryId == _selectedCategoryId).toList();

          return Column(children: [
            SizedBox(
              height: 50.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                scrollDirection: Axis.horizontal,
                itemCount: state.categories.length + 1,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  if (i == 0) return ChoiceChip(
                    label: const Text('All'), selected: _selectedCategoryId == null,
                    onSelected: (_) => setState(() => _selectedCategoryId = null),
                    selectedColor: AppColors.primaryLight,
                  );
                  final cat = state.categories[i - 1];
                  return ChoiceChip(
                    label: Text(cat.name),
                    selected: _selectedCategoryId == cat.id,
                    onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
                    selectedColor: AppColors.primaryLight,
                  );
                },
              ),
            ),
            Expanded(
              child: filteredItems.isEmpty
                  ? const AppEmptyWidget(message: 'No items available')
                  : GridView.builder(
                      padding: EdgeInsets.all(16.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 0.75,
                        crossAxisSpacing: 12.w, mainAxisSpacing: 12.h,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (_, i) => _FoodItemCard(
                        item: filteredItems[i],
                        cartItem: state.cart.where((c) => c.item.id == filteredItems[i].id).firstOrNull,
                        onAdd: () => context.read<FoodBloc>().add(AddToCart(filteredItems[i])),
                        onRemove: () => context.read<FoodBloc>().add(RemoveFromCart(filteredItems[i].id)),
                      ),
                    ),
            ),
          ]);
        },
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final CartItem? cartItem;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _FoodItemCard({required this.item, this.cartItem, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6.r)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            AppNetworkImage(url: item.imageUrl, height: 110.h, width: double.infinity,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r))),
            Positioned(top: 8, left: 8,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: item.isVeg ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(Icons.circle, size: 8.w, color: Colors.white),
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: Theme.of(context).textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 2.h),
              Text('Rs. ${item.price.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
              SizedBox(height: 6.h),
              cartItem == null
                  ? SizedBox(
                      width: double.infinity, height: 30.h,
                      child: ElevatedButton(onPressed: onAdd, child: Text('Add', style: TextStyle(fontSize: 12.sp))),
                    )
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      IconButton(onPressed: onRemove, icon: const Icon(Icons.remove_circle_outline), iconSize: 20, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      SizedBox(width: 8.w),
                      Text('${cartItem!.quantity}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8.w),
                      IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle_outline, color: AppColors.primary), iconSize: 20, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    ]),
            ]),
          ),
        ]),
      );
}

class FoodCartPage extends StatelessWidget {
  final String userId;
  final String? roomNumber;

  const FoodCartPage({super.key, required this.userId, this.roomNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: BlocConsumer<FoodBloc, FoodState>(
        listener: (context, state) {
          if (state is OrderPlaced) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order placed successfully!'), backgroundColor: AppColors.success),
            );
            context.go('/food');
          }
        },
        builder: (context, state) {
          if (state is! FoodMenuLoaded) return const AppLoadingIndicator();
          if (state.cart.isEmpty) return const AppEmptyWidget(message: 'Your cart is empty', icon: Icons.shopping_cart_outlined);

          return Column(children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.cart.length,
                itemBuilder: (_, i) {
                  final c = state.cart[i];
                  return ListTile(
                    leading: AppNetworkImage(url: c.item.imageUrl, width: 50.w, height: 50.w,
                        borderRadius: BorderRadius.circular(8.r)),
                    title: Text(c.item.name, style: Theme.of(context).textTheme.titleSmall),
                    subtitle: Text('Rs. ${c.item.price.toStringAsFixed(0)} × ${c.quantity}'),
                    trailing: Text('Rs. ${c.subtotal.toStringAsFixed(0)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Rs. ${state.cartTotal.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ]),
                SizedBox(height: 16.h),
                AppButton(
                  label: 'Place Order',
                  onPressed: () => context.read<FoodBloc>().add(PlaceOrder(userId: userId, roomNumber: roomNumber)),
                ),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}
