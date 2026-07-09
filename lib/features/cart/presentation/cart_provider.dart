import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/network/mock_repositories.dart';
import '../../auth/presentation/auth_provider.dart';

final cartRepositoryProvider = Provider<MockCartRepository>((ref) {
  return MockCartRepository();
});

final couponRepositoryProvider = Provider<MockCouponRepository>((ref) {
  return MockCouponRepository();
});

class CartState {
  final List<CartItem> items;
  final Coupon? appliedCoupon;
  final bool isLoading;
  final String? errorMessage;

  CartState({
    required this.items,
    this.appliedCoupon,
    this.isLoading = false,
    this.errorMessage,
  });

  CartState copyWith({
    List<CartItem>? items,
    Coupon? Function()? appliedCoupon, // allows setting to null
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedCoupon: appliedCoupon != null ? appliedCoupon() : this.appliedCoupon,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + (item.variant.price * item.quantity));
  }

  double get discount {
    if (appliedCoupon == null) return 0.0;
    if (appliedCoupon!.discountType == 'flat') {
      return appliedCoupon!.value;
    } else {
      // percentage
      return subtotal * (appliedCoupon!.value / 100.0);
    }
  }

  double get deliveryFee {
    if (items.isEmpty) return 0.0;
    // Flat delivery charge
    return 30.0;
  }

  double get total {
    final computed = subtotal - discount + deliveryFee;
    return computed < 0.0 ? 0.0 : computed;
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final MockCartRepository _cartRepository;
  final MockCouponRepository _couponRepository;
  final Ref _ref;

  CartNotifier(this._cartRepository, this._couponRepository, this._ref)
      : super(CartState(items: [])) {
    _loadCart();
  }

  String get _currentUserId {
    final user = _ref.read(authProvider);
    return user?.id ?? 'guest_user';
  }

  Future<void> _loadCart() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _cartRepository.getCartItems(_currentUserId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to load cart: $e',
      );
    }
  }

  Future<void> addToCart(String variantId, int quantity) async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _cartRepository.addToCart(_currentUserId, variantId, quantity);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to add to cart: $e',
      );
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _cartRepository.updateQuantity(_currentUserId, cartItemId, quantity);
      state = state.copyWith(items: items, isLoading: false);
      
      // Re-validate coupon if order total drops below minOrderValue
      if (state.appliedCoupon != null && state.subtotal < state.appliedCoupon!.minOrderValue) {
        state = state.copyWith(appliedCoupon: () => null);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to update quantity: $e',
      );
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _cartRepository.removeFromCart(_currentUserId, cartItemId);
      state = state.copyWith(items: items, isLoading: false);

      // Re-validate coupon if order total drops below minOrderValue
      if (state.appliedCoupon != null && state.subtotal < state.appliedCoupon!.minOrderValue) {
        state = state.copyWith(appliedCoupon: () => null);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to remove item: $e',
      );
    }
  }

  Future<bool> applyCoupon(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final coupon = await _couponRepository.validateCoupon(code, state.subtotal);
      state = state.copyWith(isLoading: false);
      if (coupon != null) {
        state = state.copyWith(appliedCoupon: () => coupon);
        return true;
      } else {
        state = state.copyWith(
          errorMessage: () => 'Invalid or expired coupon code, or minimum order value not met.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Error validating coupon: $e',
      );
      return false;
    }
  }

  void removeCoupon() {
    state = state.copyWith(appliedCoupon: () => null);
  }

  Future<void> clearCart() async {
    await _cartRepository.clearCart(_currentUserId);
    state = CartState(items: [], appliedCoupon: null);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final cartRepo = ref.watch(cartRepositoryProvider);
  final couponRepo = ref.watch(couponRepositoryProvider);
  return CartNotifier(cartRepo, couponRepo, ref);
});
