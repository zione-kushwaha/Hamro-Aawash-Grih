import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_widgets.dart';

// ─── Entities ───────────────────────────────────────────────
enum OrderStatus { pending, preparing, ready, delivered }

class FoodCategory extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  const FoodCategory({required this.id, required this.name, required this.imageUrl});
  @override
  List<Object> get props => [id];
}

class FoodItem extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isAvailable;
  final bool isVeg;
  const FoodItem({
    required this.id, required this.categoryId, required this.name,
    required this.description, required this.price, required this.imageUrl,
    required this.isAvailable, required this.isVeg,
  });
  @override
  List<Object> get props => [id];
}

class CartItem extends Equatable {
  final FoodItem item;
  final int quantity;
  const CartItem({required this.item, required this.quantity});
  double get subtotal => item.price * quantity;
  @override
  List<Object> get props => [item, quantity];
}

class FoodOrder extends Equatable {
  final String id;
  final String userId;
  final String? roomNumber;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  const FoodOrder({
    required this.id, required this.userId, this.roomNumber,
    required this.items, required this.totalAmount,
    required this.status, required this.createdAt,
  });
  @override
  List<Object?> get props => [id];
}

// ─── BLoC ────────────────────────────────────────────────────
abstract class FoodEvent extends Equatable {
  const FoodEvent();
  @override
  List<Object?> get props => [];
}

class LoadFoodMenu extends FoodEvent {}
class AddToCart extends FoodEvent {
  final FoodItem item;
  const AddToCart(this.item);
  @override
  List<Object> get props => [item];
}
class RemoveFromCart extends FoodEvent {
  final String itemId;
  const RemoveFromCart(this.itemId);
  @override
  List<Object> get props => [itemId];
}
class PlaceOrder extends FoodEvent {
  final String userId;
  final String? roomNumber;
  const PlaceOrder({required this.userId, this.roomNumber});
  @override
  List<Object?> get props => [userId, roomNumber];
}
class LoadOrders extends FoodEvent {
  final String userId;
  const LoadOrders(this.userId);
  @override
  List<Object> get props => [userId];
}
class ClearCart extends FoodEvent {}

abstract class FoodState extends Equatable {
  const FoodState();
  @override
  List<Object?> get props => [];
}

class FoodInitial extends FoodState {}
class FoodLoading extends FoodState {}
class FoodMenuLoaded extends FoodState {
  final List<FoodCategory> categories;
  final List<FoodItem> items;
  final List<CartItem> cart;
  const FoodMenuLoaded({required this.categories, required this.items, required this.cart});
  double get cartTotal => cart.fold(0, (sum, i) => sum + i.subtotal);
  int get cartCount => cart.fold(0, (sum, i) => sum + i.quantity);
  @override
  List<Object> get props => [categories, items, cart];
}
class OrderPlaced extends FoodState {
  final FoodOrder order;
  const OrderPlaced(this.order);
  @override
  List<Object> get props => [order];
}
class OrdersLoaded extends FoodState {
  final List<FoodOrder> orders;
  const OrdersLoaded(this.orders);
  @override
  List<Object> get props => [orders];
}
class FoodError extends FoodState {
  final String message;
  const FoodError(this.message);
  @override
  List<Object> get props => [message];
}

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final FirebaseFirestore _firestore;
  List<FoodCategory> _categories = [];
  List<FoodItem> _items = [];
  List<CartItem> _cart = [];

  FoodBloc(this._firestore) : super(FoodInitial()) {
    on<LoadFoodMenu>(_onLoadMenu);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<PlaceOrder>(_onPlaceOrder);
    on<LoadOrders>(_onLoadOrders);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onLoadMenu(LoadFoodMenu e, Emitter<FoodState> emit) async {
    emit(FoodLoading());
    try {
      final catSnap = await _firestore.collection(AppConstants.foodCategoriesCollection).get();
      final itemSnap = await _firestore.collection(AppConstants.foodItemsCollection)
          .where('is_available', isEqualTo: true).get();

      _categories = catSnap.docs.map((d) => FoodCategory(
        id: d.id, name: d['name'] ?? '', imageUrl: d['image_url'] ?? AppConstants.foodPlaceholder,
      )).toList();

      _items = itemSnap.docs.map((d) => FoodItem(
        id: d.id, categoryId: d['category_id'] ?? '', name: d['name'] ?? '',
        description: d['description'] ?? '', price: (d['price'] ?? 0).toDouble(),
        imageUrl: d['image_url'] ?? AppConstants.foodPlaceholder,
        isAvailable: d['is_available'] ?? true, isVeg: d['is_veg'] ?? false,
      )).toList();

      emit(FoodMenuLoaded(categories: _categories, items: _items, cart: _cart));
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  void _onAddToCart(AddToCart e, Emitter<FoodState> emit) {
    final idx = _cart.indexWhere((c) => c.item.id == e.item.id);
    if (idx >= 0) {
      _cart = List.from(_cart)..[idx] = CartItem(item: e.item, quantity: _cart[idx].quantity + 1);
    } else {
      _cart = [..._cart, CartItem(item: e.item, quantity: 1)];
    }
    emit(FoodMenuLoaded(categories: _categories, items: _items, cart: _cart));
  }

  void _onRemoveFromCart(RemoveFromCart e, Emitter<FoodState> emit) {
    final idx = _cart.indexWhere((c) => c.item.id == e.itemId);
    if (idx >= 0) {
      if (_cart[idx].quantity > 1) {
        _cart = List.from(_cart)..[idx] = CartItem(item: _cart[idx].item, quantity: _cart[idx].quantity - 1);
      } else {
        _cart = List.from(_cart)..removeAt(idx);
      }
    }
    emit(FoodMenuLoaded(categories: _categories, items: _items, cart: _cart));
  }

  Future<void> _onPlaceOrder(PlaceOrder e, Emitter<FoodState> emit) async {
    if (_cart.isEmpty) { emit(const FoodError('Cart is empty')); return; }
    emit(FoodLoading());
    try {
      final orderId = const Uuid().v4();
      final total = _cart.fold(0.0, (s, i) => s + i.subtotal);
      final orderData = {
        'user_id': e.userId, 'room_number': e.roomNumber,
        'total_amount': total, 'status': 'pending',
        'created_at': Timestamp.now(),
        'items': _cart.map((c) => {
          'food_item_id': c.item.id, 'name': c.item.name,
          'price': c.item.price, 'quantity': c.quantity,
        }).toList(),
      };
      await _firestore.collection(AppConstants.ordersCollection).doc(orderId).set(orderData);
      final order = FoodOrder(
        id: orderId, userId: e.userId, roomNumber: e.roomNumber,
        items: _cart, totalAmount: total,
        status: OrderStatus.pending, createdAt: DateTime.now(),
      );
      _cart = [];
      emit(OrderPlaced(order));
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  Future<void> _onLoadOrders(LoadOrders e, Emitter<FoodState> emit) async {
    emit(FoodLoading());
    try {
      final snap = await _firestore.collection(AppConstants.ordersCollection)
          .where('user_id', isEqualTo: e.userId)
          .orderBy('created_at', descending: true).get();
      final orders = snap.docs.map((d) {
        final data = d.data();
        return FoodOrder(
          id: d.id, userId: data['user_id'],
          roomNumber: data['room_number'], items: [],
          totalAmount: (data['total_amount'] ?? 0).toDouble(),
          status: OrderStatus.values.firstWhere((s) => s.name == data['status'], orElse: () => OrderStatus.pending),
          createdAt: (data['created_at'] as Timestamp).toDate(),
        );
      }).toList();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  void _onClearCart(ClearCart e, Emitter<FoodState> emit) {
    _cart = [];
    emit(FoodMenuLoaded(categories: _categories, items: _items, cart: _cart));
  }
}
