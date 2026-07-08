import 'dart:async';
import '../models/models.dart';

// Simulated delay helper
Future<void> simulatedDelay() async {
  await Future.delayed(const Duration(milliseconds: 800));
}

// ----------------------------------------------------
// Mock Data Storage
// ----------------------------------------------------

final List<Category> mockCategories = [
  Category(id: 'cat_1', name: 'Groceries & Staples', slug: 'groceries-staples', imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=80'),
  Category(id: 'cat_2', name: 'Dairy & Bakery', slug: 'dairy-bakery', imageUrl: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?auto=format&fit=crop&w=400&q=80'),
  Category(id: 'cat_3', name: 'Snacks & Beverages', slug: 'snacks-beverages', imageUrl: 'https://images.unsplash.com/photo-1599490659213-e2b9527b0876?auto=format&fit=crop&w=400&q=80'),
  Category(id: 'cat_4', name: 'Household & Personal Care', slug: 'household-care', imageUrl: 'https://images.unsplash.com/photo-1583947215259-38e31be8751f?auto=format&fit=crop&w=400&q=80'),
];

final List<Product> mockProducts = [
  Product(
    id: 'prod_1',
    categoryId: 'cat_1',
    name: 'Aashirvaad Svasti Pure Cow Ghee',
    description: 'Aashirvaad Svasti Pure Cow Ghee is made with a special Slo-Cook process that enhances its natural aroma, granular texture, and rich taste.',
    isActive: true,
    primaryImageUrl: 'https://images.unsplash.com/photo-1589733966041-b16279699047?auto=format&fit=crop&w=400&q=80',
    variants: [
      ProductVariant(id: 'v_1_1', productId: 'prod_1', name: '500ml', price: 340.0, sku: 'GHEE-500ML', stockQty: 15),
      ProductVariant(id: 'v_1_2', productId: 'prod_1', name: '1L', price: 670.0, sku: 'GHEE-1L', stockQty: 25),
    ],
  ),
  Product(
    id: 'prod_2',
    categoryId: 'cat_1',
    name: 'Fortune Biryani Special Basmati Rice',
    description: 'Fortune Biryani Special Basmati Rice has extra-long grains that do not stick together, making your biryani look and taste premium.',
    isActive: true,
    primaryImageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=400&q=80',
    variants: [
      ProductVariant(id: 'v_2_1', productId: 'prod_2', name: '1kg', price: 130.0, sku: 'RICE-1KG', stockQty: 40),
      ProductVariant(id: 'v_2_2', productId: 'prod_2', name: '5kg', price: 620.0, sku: 'RICE-5KG', stockQty: 0), // Out of stock
    ],
  ),
  Product(
    id: 'prod_3',
    categoryId: 'cat_2',
    name: 'Amul Gold Fresh Milk',
    description: 'Amul Gold is pasteurized milk that meets standard hygiene requirements, packed with essential vitamins and calcium.',
    isActive: true,
    primaryImageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
    variants: [
      ProductVariant(id: 'v_3_1', productId: 'prod_3', name: '500ml', price: 33.0, sku: 'MILK-500ML', stockQty: 50),
      ProductVariant(id: 'v_3_2', productId: 'prod_3', name: '1L', price: 66.0, sku: 'MILK-1L', stockQty: 30),
    ],
  ),
  Product(
    id: 'prod_4',
    categoryId: 'cat_3',
    name: 'Tata Tea Premium',
    description: 'Tata Tea Premium is India\'s No.1 branded tea, sourced from the finest tea leaves in Assam to give you a strong, refreshing cup.',
    isActive: true,
    primaryImageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=400&q=80',
    variants: [
      ProductVariant(id: 'v_4_1', productId: 'prod_4', name: '250g', price: 110.0, sku: 'TEA-250G', stockQty: 35),
      ProductVariant(id: 'v_4_2', productId: 'prod_4', name: '1kg', price: 420.0, sku: 'TEA-1KG', stockQty: 20),
    ],
  ),
  Product(
    id: 'prod_5',
    categoryId: 'cat_4',
    name: 'Surf Excel Easy Wash Detergent Powder',
    description: 'Surf Excel Easy Wash removes tough stains easily without hurting hands, keeping your clothes bright and fresh.',
    isActive: true,
    primaryImageUrl: 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?auto=format&fit=crop&w=400&q=80',
    variants: [
      ProductVariant(id: 'v_5_1', productId: 'prod_5', name: '1kg', price: 140.0, sku: 'SURF-1KG', stockQty: 18),
    ],
  ),
];

final List<Coupon> mockCoupons = [
  Coupon(
    id: 'c_1',
    code: 'WELCOME50',
    discountType: 'flat',
    value: 50.0,
    minOrderValue: 200.0,
    expiryDate: DateTime.now().add(const Duration(days: 30)),
    maxUsage: 100,
    usageCount: 5,
    isActive: true,
  ),
  Coupon(
    id: 'c_2',
    code: 'AHMEDABAD10',
    discountType: 'percentage',
    value: 10.0,
    minOrderValue: 500.0,
    expiryDate: DateTime.now().add(const Duration(days: 15)),
    maxUsage: 500,
    usageCount: 120,
    isActive: true,
  ),
];

// ----------------------------------------------------
// Mock Repositories
// ----------------------------------------------------

class MockAuthRepository {
  UserProfile? _currentUser;

  Future<UserProfile?> getCurrentUser() async {
    await simulatedDelay();
    return _currentUser;
  }

  Future<UserProfile> login(String email, String password) async {
    await simulatedDelay();
    if (email == 'admin@onebasket.in') {
      _currentUser = UserProfile(
        id: 'user_admin',
        fullName: 'Raj Patel (Admin)',
        phoneNumber: '+919876543210',
        role: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      );
    } else {
      _currentUser = UserProfile(
        id: 'user_customer_1',
        fullName: 'Priya Sharma',
        phoneNumber: '+919988776655',
        role: 'customer',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      );
    }
    return _currentUser!;
  }

  Future<UserProfile> register(String fullName, String email, String password) async {
    await simulatedDelay();
    _currentUser = UserProfile(
      id: 'user_customer_new',
      fullName: fullName,
      phoneNumber: '',
      role: 'customer',
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  Future<void> changePassword(String newPassword) async {
    await simulatedDelay();
  }

  Future<void> logout() async {
    await simulatedDelay();
    _currentUser = null;
  }
}

class MockCatalogRepository {
  Future<List<Category>> getCategories() async {
    await simulatedDelay();
    return mockCategories;
  }

  Future<List<Product>> getProducts({String? categoryId}) async {
    await simulatedDelay();
    if (categoryId != null) {
      return mockProducts.where((p) => p.categoryId == categoryId).toList();
    }
    return mockProducts;
  }

  Future<List<Product>> searchProducts(String query) async {
    await simulatedDelay();
    final lower = query.toLowerCase();
    return mockProducts
        .where((p) =>
            p.name.toLowerCase().contains(lower) ||
            (p.description?.toLowerCase().contains(lower) ?? false))
        .toList();
  }

  Future<Product?> getProductById(String id) async {
    await simulatedDelay();
    return mockProducts.firstWhere((p) => p.id == id);
  }
}

class MockCartRepository {
  final List<CartItem> _cartItems = [];

  Future<List<CartItem>> getCartItems(String userId) async {
    await simulatedDelay();
    return List.unmodifiable(_cartItems);
  }

  Future<List<CartItem>> addToCart(String userId, String variantId, int quantity) async {
    await simulatedDelay();
    // Locate the product and variant
    Product? targetProduct;
    ProductVariant? targetVariant;

    for (var prod in mockProducts) {
      for (var v in prod.variants) {
        if (v.id == variantId) {
          targetProduct = prod;
          targetVariant = v;
          break;
        }
      }
    }

    if (targetProduct != null && targetVariant != null) {
      final index = _cartItems.indexWhere((item) => item.variant.id == variantId);
      if (index >= 0) {
        final existing = _cartItems[index];
        final newQty = existing.quantity + quantity;
        if (newQty <= targetVariant.stockQty) {
          _cartItems[index] = CartItem(
            id: existing.id,
            userId: userId,
            product: targetProduct,
            variant: targetVariant,
            quantity: newQty,
          );
        }
      } else {
        if (quantity <= targetVariant.stockQty) {
          _cartItems.add(
            CartItem(
              id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
              userId: userId,
              product: targetProduct,
              variant: targetVariant,
              quantity: quantity,
            ),
          );
        }
      }
    }
    return List.unmodifiable(_cartItems);
  }

  Future<List<CartItem>> updateQuantity(String userId, String cartItemId, int quantity) async {
    await simulatedDelay();
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      final item = _cartItems[index];
      if (quantity <= item.variant.stockQty) {
        _cartItems[index] = CartItem(
          id: item.id,
          userId: userId,
          product: item.product,
          variant: item.variant,
          quantity: quantity,
        );
      }
    }
    return List.unmodifiable(_cartItems);
  }

  Future<List<CartItem>> removeFromCart(String userId, String cartItemId) async {
    await simulatedDelay();
    _cartItems.removeWhere((item) => item.id == cartItemId);
    return List.unmodifiable(_cartItems);
  }

  Future<void> clearCart(String userId) async {
    await simulatedDelay();
    _cartItems.clear();
  }
}

class MockWishlistRepository {
  final List<WishlistItem> _wishlistItems = [];

  Future<List<WishlistItem>> getWishlistItems(String userId) async {
    await simulatedDelay();
    return List.unmodifiable(_wishlistItems);
  }

  Future<List<WishlistItem>> toggleWishlist(String userId, String productId) async {
    await simulatedDelay();
    final index = _wishlistItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _wishlistItems.removeAt(index);
    } else {
      final product = mockProducts.firstWhere((p) => p.id == productId);
      _wishlistItems.add(
        WishlistItem(
          id: 'wl_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          product: product,
        ),
      );
    }
    return List.unmodifiable(_wishlistItems);
  }
}

class MockAddressRepository {
  final List<Address> _addresses = [
    Address(
      id: 'addr_1',
      userId: 'user_customer_1',
      name: 'Priya Sharma',
      phoneNumber: '+919988776655',
      addressLine1: '402, Shivalik High Street',
      addressLine2: 'Vastrapur',
      city: 'Ahmedabad',
      pincode: '380015',
      isDefault: true,
    ),
    Address(
      id: 'addr_2',
      userId: 'user_customer_1',
      name: 'Priya Sharma (Office)',
      phoneNumber: '+919988776655',
      addressLine1: 'B-Block, Commerce House 5',
      addressLine2: 'Prahlad Nagar',
      city: 'Ahmedabad',
      pincode: '380051',
      isDefault: false,
    ),
  ];

  Future<List<Address>> getAddresses(String userId) async {
    await simulatedDelay();
    return _addresses.where((a) => a.userId == userId).toList();
  }

  Future<Address> addAddress(Address address) async {
    await simulatedDelay();
    final newAddress = Address(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      userId: address.userId,
      name: address.name,
      phoneNumber: address.phoneNumber,
      addressLine1: address.addressLine1,
      addressLine2: address.addressLine2,
      city: address.city,
      pincode: address.pincode,
      isDefault: address.isDefault,
    );

    if (address.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        if (_addresses[i].userId == address.userId) {
          _addresses[i] = _addresses[i]._copyWith(isDefault: false);
        }
      }
    }
    _addresses.add(newAddress);
    return newAddress;
  }

  Future<void> deleteAddress(String addressId) async {
    await simulatedDelay();
    _addresses.removeWhere((a) => a.id == addressId);
  }
}

extension on Address {
  Address _copyWith({bool? isDefault}) {
    return Address(
      id: id,
      userId: userId,
      name: name,
      phoneNumber: phoneNumber,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      pincode: pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class MockOrderRepository {
  final List<OrderModel> _orders = [];

  Future<List<OrderModel>> getOrders(String userId) async {
    await simulatedDelay();
    return _orders.where((o) => o.userId == userId).toList();
  }

  Future<OrderModel> placeOrder({
    required String userId,
    required List<CartItem> cartItems,
    required Address address,
    required String paymentMethod,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
    String? couponId,
  }) async {
    await simulatedDelay();
    final newOrder = OrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      status: 'pending',
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'cod' ? 'unpaid' : 'paid',
      couponId: couponId,
      shippingAddress: address.toJson(),
      items: cartItems
          .map((c) => OrderItem(
                id: 'oi_${c.id}',
                variantId: c.variant.id,
                productName: c.product.name,
                variantName: c.variant.name,
                quantity: c.quantity,
                priceAtPurchase: c.variant.price,
              ))
          .toList(),
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
      createdAt: DateTime.now(),
    );
    _orders.add(newOrder);
    return newOrder;
  }

  Future<OrderModel?> getOrderDetails(String orderId) async {
    await simulatedDelay();
    return _orders.firstWhere((o) => o.id == orderId);
  }

  Future<OrderModel> cancelOrder(String orderId) async {
    await simulatedDelay();
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final oldOrder = _orders[index];
      if (oldOrder.status == 'pending' || oldOrder.status == 'confirmed') {
        final newOrder = OrderModel(
          id: oldOrder.id,
          userId: oldOrder.userId,
          status: 'cancelled',
          paymentMethod: oldOrder.paymentMethod,
          paymentStatus: oldOrder.paymentStatus,
          stripePaymentIntentId: oldOrder.stripePaymentIntentId,
          couponId: oldOrder.couponId,
          shippingAddress: oldOrder.shippingAddress,
          items: oldOrder.items,
          subtotal: oldOrder.subtotal,
          discount: oldOrder.discount,
          deliveryFee: oldOrder.deliveryFee,
          total: oldOrder.total,
          createdAt: oldOrder.createdAt,
        );
        _orders[index] = newOrder;
        return newOrder;
      }
    }
    throw Exception('Order cannot be cancelled in its current state');
  }

  // Admin access
  Future<List<OrderModel>> getAllOrders() async {
    await simulatedDelay();
    return List.unmodifiable(_orders);
  }

  Future<OrderModel> updateOrderStatus(String orderId, String newStatus) async {
    await simulatedDelay();
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final old = _orders[index];
      final updated = OrderModel(
        id: old.id,
        userId: old.userId,
        status: newStatus,
        paymentMethod: old.paymentMethod,
        paymentStatus: newStatus == 'delivered' && old.paymentMethod == 'cod' ? 'paid' : old.paymentStatus,
        stripePaymentIntentId: old.stripePaymentIntentId,
        couponId: old.couponId,
        shippingAddress: old.shippingAddress,
        items: old.items,
        subtotal: old.subtotal,
        discount: old.discount,
        deliveryFee: old.deliveryFee,
        total: old.total,
        createdAt: old.createdAt,
      );
      _orders[index] = updated;
      return updated;
    }
    throw Exception('Order not found');
  }
}

class MockCouponRepository {
  Future<Coupon?> validateCoupon(String code, double orderValue) async {
    await simulatedDelay();
    final index = mockCoupons.indexWhere((c) => c.code.toUpperCase() == code.toUpperCase());
    if (index >= 0) {
      final coupon = mockCoupons[index];
      if (coupon.isActive &&
          coupon.expiryDate.isAfter(DateTime.now()) &&
          orderValue >= coupon.minOrderValue &&
          coupon.usageCount < coupon.maxUsage) {
        return coupon;
      }
    }
    return null;
  }
}
