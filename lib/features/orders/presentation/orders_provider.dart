import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/network/mock_repositories.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../cart/presentation/cart_provider.dart';

final orderRepositoryProvider = Provider<MockOrderRepository>((ref) {
  return MockOrderRepository();
});

class OrdersNotifier extends StateNotifier<List<OrderModel>> {
  final MockOrderRepository _repository;
  final Ref _ref;

  OrdersNotifier(this._repository, this._ref) : super([]) {
    _loadOrders();
  }

  String get _currentUserId {
    final user = _ref.read(authProvider);
    return user?.id ?? 'guest_user';
  }

  Future<void> _loadOrders() async {
    try {
      final list = await _repository.getOrders(_currentUserId);
      state = list;
    } catch (_) {}
  }

  Future<OrderModel> placeOrder({
    required Address address,
    required String paymentMethod, // 'cod' or 'stripe'
  }) async {
    final cartState = _ref.read(cartProvider);
    final user = _ref.read(authProvider);

    if (user == null) {
      throw Exception('User must be logged in to place an order.');
    }

    if (cartState.items.isEmpty) {
      throw Exception('Cannot place order with an empty cart.');
    }

    try {
      final newOrder = await _repository.placeOrder(
        userId: user.id,
        cartItems: cartState.items,
        address: address,
        paymentMethod: paymentMethod,
        subtotal: cartState.subtotal,
        discount: cartState.discount,
        deliveryFee: cartState.deliveryFee,
        total: cartState.total,
        couponId: cartState.appliedCoupon?.id,
      );

      // Clear Cart on successful order placement
      await _ref.read(cartProvider.notifier).clearCart();
      await _loadOrders();
      return newOrder;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _repository.cancelOrder(orderId);
      await _loadOrders();
    } catch (e) {
      rethrow;
    }
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderModel>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrdersNotifier(repository, ref);
});
