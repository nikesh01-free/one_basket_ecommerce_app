import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/network/mock_repositories.dart';

final catalogRepositoryProvider = Provider<MockCatalogRepository>((ref) {
  return MockCatalogRepository();
});

final categoriesFutureProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getCategories();
});

final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final priceRangeProvider = StateProvider<double?>((ref) => null); // Max price filter
final sortByProvider = StateProvider<String>((ref) => 'newest'); // 'newest', 'price_asc', 'price_desc'

final productsFutureProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(catalogRepositoryProvider);
  final categoryId = ref.watch(selectedCategoryIdProvider);
  return repository.getProducts(categoryId: categoryId);
});

// Combines local query/filters to filter catalog items dynamically
final filteredProductsFutureProvider = FutureProvider<List<Product>>((ref) async {
  final productsAsyncValue = ref.watch(productsFutureProvider);
  final products = productsAsyncValue.value ?? [];

  final query = ref.watch(searchQueryProvider).toLowerCase();
  final maxPrice = ref.watch(priceRangeProvider);
  final sortBy = ref.watch(sortByProvider);

  List<Product> results = List.from(products);

  // 1. Search Query filter
  if (query.isNotEmpty) {
    results = results.where((p) {
      final nameMatch = p.name.toLowerCase().contains(query);
      final descMatch = p.description?.toLowerCase().contains(query) ?? false;
      return nameMatch || descMatch;
    }).toList();
  }

  // 2. Price filter (filter based on the first variant's price)
  if (maxPrice != null) {
    results = results.where((p) {
      if (p.variants.isEmpty) return false;
      return p.variants.first.price <= maxPrice;
    }).toList();
  }

  // 3. Sort logic
  if (sortBy == 'price_asc') {
    results.sort((a, b) {
      final priceA = a.variants.isNotEmpty ? a.variants.first.price : 0.0;
      final priceB = b.variants.isNotEmpty ? b.variants.first.price : 0.0;
      return priceA.compareTo(priceB);
    });
  } else if (sortBy == 'price_desc') {
    results.sort((a, b) {
      final priceA = a.variants.isNotEmpty ? a.variants.first.price : 0.0;
      final priceB = b.variants.isNotEmpty ? b.variants.first.price : 0.0;
      return priceB.compareTo(priceA);
    });
  } else {
    // default/newest
    // mock list sorting matches default order in MockRepository
  }

  return results;
});
