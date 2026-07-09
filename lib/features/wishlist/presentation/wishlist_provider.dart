import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/network/mock_repositories.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../cart/presentation/cart_provider.dart';

final wishlistRepositoryProvider = Provider<MockWishlistRepository>((ref) {
  return MockWishlistRepository();
});

class WishlistNotifier extends StateNotifier<List<WishlistItem>> {
  final MockWishlistRepository _repository;
  final Ref _ref;

  WishlistNotifier(this._repository, this._ref) : super([]) {
    _loadWishlist();
  }

  String get _currentUserId {
    final user = _ref.read(authProvider);
    return user?.id ?? 'guest_user';
  }

  Future<void> _loadWishlist() async {
    try {
      final items = await _repository.getWishlistItems(_currentUserId);
      state = items;
    } catch (_) {}
  }

  Future<void> toggleWishlist(String productId) async {
    try {
      final items = await _repository.toggleWishlist(_currentUserId, productId);
      state = items;
    } catch (_) {}
  }

  bool isWishlisted(String productId) {
    return state.any((item) => item.product.id == productId);
  }

  Future<void> moveToCart(WishlistItem item, String variantId) async {
    // 1. Add to cart
    await _ref.read(cartProvider.notifier).addToCart(variantId, 1);
    // 2. Remove from wishlist
    await toggleWishlist(item.product.id);
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<WishlistItem>>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return WishlistNotifier(repository, ref);
});
