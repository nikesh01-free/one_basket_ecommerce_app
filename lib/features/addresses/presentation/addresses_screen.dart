import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'address_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/text_fields.dart';

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _pincodeController = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _line1Error;
  String? _pincodeError;
  bool _isAdding = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final line1 = _line1Controller.text.trim();
    final pincode = _pincodeController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required.');
      isValid = false;
    } else {
      setState(() => _nameError = null);
    }

    if (phone.isEmpty) {
      setState(() => _phoneError = 'Phone number is required.');
      isValid = false;
    } else {
      setState(() => _phoneError = null);
    }

    if (line1.isEmpty) {
      setState(() => _line1Error = 'Address line 1 is required.');
      isValid = false;
    } else {
      setState(() => _line1Error = null);
    }

    if (pincode.isEmpty) {
      setState(() => _pincodeError = 'Pincode is required.');
      isValid = false;
    } else if (pincode.length != 6 || int.tryParse(pincode) == null) {
      setState(() => _pincodeError = 'Enter a valid 6-digit pincode.');
      isValid = false;
    } else if (!pincode.startsWith('38')) {
      setState(() => _pincodeError = 'We only deliver to Ahmedabad (pincodes starting with 38).');
      isValid = false;
    } else {
      setState(() => _pincodeError = null);
    }

    return isValid;
  }

  Future<void> _handleSave() async {
    if (!_validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(addressProvider.notifier).addAddress(
            name: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            addressLine1: _line1Controller.text.trim(),
            addressLine2: _line2Controller.text.trim(),
            pincode: _pincodeController.text.trim(),
            isDefault: ref.read(addressProvider).isEmpty, // Set as default if first address
          );

      setState(() {
        _isSaving = false;
        _isAdding = false;
      });

      _nameController.clear();
      _phoneController.clear();
      _line1Controller.clear();
      _line2Controller.clear();
      _pincodeController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final addresses = ref.watch(addressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Delivery Addresses'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: OBSpacing.space4, vertical: OBSpacing.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isAdding) ...[
              // Add New Address Form
              Text(
                'Add New Address',
                style: OBTypography.subtitle.copyWith(
                  color: isDark ? Colors.white : OBColors.neutral800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: OBSpacing.space3),
              OBTextField(
                label: 'Receiver Name',
                hintText: 'e.g. Priya Sharma',
                controller: _nameController,
                errorText: _nameError,
                isEnabled: !_isSaving,
              ),
              const SizedBox(height: OBSpacing.space2),
              OBTextField(
                label: 'Phone Number',
                hintText: 'e.g. +91 99887 76655',
                controller: _phoneController,
                errorText: _phoneError,
                keyboardType: TextInputType.phone,
                isEnabled: !_isSaving,
              ),
              const SizedBox(height: OBSpacing.space2),
              OBTextField(
                label: 'Address Line 1',
                hintText: 'e.g. Apartment, house number, street name',
                controller: _line1Controller,
                errorText: _line1Error,
                isEnabled: !_isSaving,
              ),
              const SizedBox(height: OBSpacing.space2),
              OBTextField(
                label: 'Address Line 2 (Optional)',
                hintText: 'e.g. Landmark, locality',
                controller: _line2Controller,
                isEnabled: !_isSaving,
              ),
              const SizedBox(height: OBSpacing.space2),
              OBTextField(
                label: 'Pincode (Ahmedabad Whitelisted)',
                hintText: 'e.g. 380015',
                controller: _pincodeController,
                errorText: _pincodeError,
                keyboardType: TextInputType.number,
                isEnabled: !_isSaving,
              ),
              const SizedBox(height: OBSpacing.space4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => setState(() => _isAdding = false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: OBSpacing.space3),
                  Expanded(
                    child: OBButton(
                      text: 'Save Address',
                      onPressed: _isSaving ? null : _handleSave,
                      isLoading: _isSaving,
                    ),
                  ),
                ],
              ),
              const Divider(height: OBSpacing.space8),
            ],

            // Saved Addresses list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Addresses',
                  style: OBTypography.subtitle.copyWith(
                    color: isDark ? Colors.white : OBColors.neutral800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isAdding)
                  OBButton(
                    text: 'Add New',
                    size: OBButtonSize.small,
                    onPressed: () => setState(() => _isAdding = true),
                  ),
              ],
            ),
            const SizedBox(height: OBSpacing.space3),
            addresses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(OBSpacing.space6),
                      child: Text(
                        'No saved delivery locations. Add an address to enable checkout.',
                        style: OBTypography.body.copyWith(color: OBColors.neutral500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final addr = addresses[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: OBSpacing.space3),
                        padding: const EdgeInsets.all(OBSpacing.space3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2722) : OBColors.neutral100,
                          borderRadius: OBRadius.md,
                          boxShadow: OBShadows.neomorphic(level: 1, isDarkMode: isDark),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.home_outlined, color: OBColors.primary500),
                            const SizedBox(width: OBSpacing.space3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        addr.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      if (addr.isDefault) ...[
                                        const SizedBox(width: 8.0),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                          decoration: BoxDecoration(
                                            color: OBColors.successBg,
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: const Text(
                                            'DEFAULT',
                                            style: TextStyle(color: OBColors.success, fontSize: 8.0, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '${addr.addressLine1}, ${addr.addressLine2 ?? ""}\n${addr.city} - ${addr.pincode}',
                                    style: OBTypography.body.copyWith(color: OBColors.neutral600),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Phone: ${addr.phoneNumber}',
                                    style: OBTypography.caption.copyWith(color: OBColors.neutral500),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: OBColors.error, size: 20.0),
                              onPressed: () {
                                ref.read(addressProvider.notifier).deleteAddress(addr.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
