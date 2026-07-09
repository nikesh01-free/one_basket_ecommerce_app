import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/network/mock_repositories.dart';
import '../../auth/presentation/auth_provider.dart';

final addressRepositoryProvider = Provider<MockAddressRepository>((ref) {
  return MockAddressRepository();
});

class AddressNotifier extends StateNotifier<List<Address>> {
  final MockAddressRepository _repository;
  final Ref _ref;

  AddressNotifier(this._repository, this._ref) : super([]) {
    _loadAddresses();
  }

  String get _currentUserId {
    final user = _ref.read(authProvider);
    return user?.id ?? 'guest_user';
  }

  Future<void> _loadAddresses() async {
    try {
      final list = await _repository.getAddresses(_currentUserId);
      state = list;
    } catch (_) {}
  }

  Future<void> addAddress({
    required String name,
    required String phoneNumber,
    required String addressLine1,
    String? addressLine2,
    required String pincode,
    bool isDefault = false,
  }) async {
    // Hyperlocal restriction check: Pincode whitelist (must start with 380 for Ahmedabad region check)
    // Whitelsit check logic
    final bool isValidAhmedabad = pincode.startsWith('38');
    if (!isValidAhmedabad) {
      throw Exception('We only deliver to Ahmedabad (pincodes starting with 38).');
    }

    final newAddr = Address(
      id: '',
      userId: _currentUserId,
      name: name,
      phoneNumber: phoneNumber,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: 'Ahmedabad',
      pincode: pincode,
      isDefault: isDefault,
    );

    try {
      await _repository.addAddress(newAddr);
      await _loadAddresses();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _repository.deleteAddress(addressId);
      await _loadAddresses();
    } catch (_) {}
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, List<Address>>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return AddressNotifier(repository, ref);
});
