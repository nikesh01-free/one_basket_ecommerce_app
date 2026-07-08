// User / Profile Model
class UserProfile {
  final String id;
  final String fullName;
  final String? phoneNumber;
  final String role; // 'customer' or 'admin'
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        phoneNumber: json['phone_number'] as String?,
        role: json['role'] as String? ?? 'customer',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'role': role,
        'created_at': createdAt.toIso8601String(),
      };
}

// Category Model
class Category {
  final String id;
  final String name;
  final String slug;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        imageUrl: json['image_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'image_url': imageUrl,
      };
}

// Product Variant Model
class ProductVariant {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String sku;
  final int stockQty;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.sku,
    required this.stockQty,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        sku: json['sku'] as String,
        stockQty: json['stock_qty'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'name': name,
        'price': price,
        'sku': sku,
        'stock_qty': stockQty,
      };
}

// Product Model
class Product {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final bool isActive;
  final List<ProductVariant> variants;
  final String? primaryImageUrl;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.isActive,
    required this.variants,
    this.primaryImageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        categoryId: json['category_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        variants: (json['variants'] as List<dynamic>?)
                ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        primaryImageUrl: json['primary_image_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'is_active': isActive,
        'variants': variants.map((e) => e.toJson()).toList(),
        'primary_image_url': primaryImageUrl,
      };
}

// Address Model
class Address {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String pincode;
  final bool isDefault;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.pincode,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        phoneNumber: json['phone_number'] as String,
        addressLine1: json['address_line1'] as String,
        addressLine2: json['address_line2'] as String?,
        city: json['city'] as String? ?? 'Ahmedabad',
        pincode: json['pincode'] as String,
        isDefault: json['is_default'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'phone_number': phoneNumber,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'pincode': pincode,
        'is_default': isDefault,
      };
}

// Cart Item Model
class CartItem {
  final String id;
  final String userId;
  final Product product;
  final ProductVariant variant;
  final int quantity;

  CartItem({
    required this.id,
    required this.userId,
    required this.product,
    required this.variant,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        variant: ProductVariant.fromJson(json['variant'] as Map<String, dynamic>),
        quantity: json['quantity'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'product': product.toJson(),
        'variant': variant.toJson(),
        'quantity': quantity,
      };
}

// Wishlist Item Model
class WishlistItem {
  final String id;
  final String userId;
  final Product product;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.product,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'product': product.toJson(),
      };
}

// Coupon Model
class Coupon {
  final String id;
  final String code;
  final String discountType; // 'flat' or 'percentage'
  final double value;
  final double minOrderValue;
  final DateTime expiryDate;
  final int maxUsage;
  final int usageCount;
  final bool isActive;

  Coupon({
    required this.id,
    required this.code,
    required this.discountType,
    required this.value,
    required this.minOrderValue,
    required this.expiryDate,
    required this.maxUsage,
    required this.usageCount,
    required this.isActive,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: json['id'] as String,
        code: json['code'] as String,
        discountType: json['discount_type'] as String,
        value: (json['value'] as num).toDouble(),
        minOrderValue: (json['min_order_value'] as num? ?? 0.0).toDouble(),
        expiryDate: DateTime.parse(json['expiry_date'] as String),
        maxUsage: json['max_usage'] as int? ?? 100,
        usageCount: json['usage_count'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'discount_type': discountType,
        'value': value,
        'min_order_value': minOrderValue,
        'expiry_date': expiryDate.toIso8601String(),
        'max_usage': maxUsage,
        'usage_count': usageCount,
        'is_active': isActive,
      };
}

// Order Item Model
class OrderItem {
  final String id;
  final String variantId;
  final String productName;
  final String variantName;
  final int quantity;
  final double priceAtPurchase;

  OrderItem({
    required this.id,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.priceAtPurchase,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] as String,
        variantId: json['variant_id'] as String,
        productName: json['product_name'] as String? ?? 'Product',
        variantName: json['variant_name'] as String? ?? '',
        quantity: json['quantity'] as int,
        priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'variant_id': variantId,
        'product_name': productName,
        'variant_name': variantName,
        'quantity': quantity,
        'price_at_purchase': priceAtPurchase,
      };
}

// Order Model
class OrderModel {
  final String id;
  final String userId;
  final String status; // 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'
  final String paymentMethod; // 'cod', 'stripe'
  final String paymentStatus; // 'unpaid', 'paid', 'refunded'
  final String? stripePaymentIntentId;
  final String? couponId;
  final Map<String, dynamic> shippingAddress;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.stripePaymentIntentId,
    this.couponId,
    required this.shippingAddress,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        status: json['status'] as String,
        paymentMethod: json['payment_method'] as String,
        paymentStatus: json['payment_status'] as String,
        stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
        couponId: json['coupon_id'] as String?,
        shippingAddress: json['shipping_address'] as Map<String, dynamic>,
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        subtotal: (json['subtotal'] as num).toDouble(),
        discount: (json['discount'] as num).toDouble(),
        deliveryFee: (json['delivery_fee'] as num? ?? 30.0).toDouble(),
        total: (json['total'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'status': status,
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'stripe_payment_intent_id': stripePaymentIntentId,
        'coupon_id': couponId,
        'shipping_address': shippingAddress,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'delivery_fee': deliveryFee,
        'total': total,
        'created_at': createdAt.toIso8601String(),
      };
}

// Review Model
class Review {
  final String id;
  final String userId;
  final String userName;
  final String productId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String? ?? 'User',
        productId: json['product_id'] as String,
        rating: json['rating'] as int,
        comment: json['comment'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'product_id': productId,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };
}
