import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/customer.dart';
import '../../../services/storage_service.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_toast.dart';

/// Shows a bottom sheet dialog for adding a new customer
void showAddCustomerDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AddCustomerSheet(),
  );
}

class AddCustomerSheet extends StatefulWidget {
  const AddCustomerSheet({super.key});

  @override
  State<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<AddCustomerSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleAddCustomer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppToast.showError(context, 'customer.name_required_msg'.tr());
      return;
    }

    final storage = Provider.of<StorageService>(context, listen: false);

    // Check for duplicate customer name
    final existingCustomer = storage.customers.any(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
    );
    if (existingCustomer) {
      AppToast.showWarning(context, 'customer.duplicate'.tr());
      return;
    }

    final now = DateTime.now();
    final customer = Customer(
      id: const Uuid().v4(),
      name: name,
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    storage.addCustomer(customer);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(
          context,
        ).viewInsets.bottom, // Handle keyboard padding
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'customer.add'.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'customer.name_required'.tr(),
                prefixIcon: const Icon(Icons.person_rounded),
                counterText: '',
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 32,
              inputFormatters: [LengthLimitingTextInputFormatter(32)],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'customer.phone'.tr(),
                prefixIcon: const Icon(Icons.phone_rounded),
                counterText: '',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 11,
              inputFormatters: [
                LengthLimitingTextInputFormatter(11),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'customer.address'.tr(),
                prefixIcon: const Icon(Icons.location_on_rounded),
                counterText: '',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 50,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'customer.notes'.tr(),
                prefixIcon: const Icon(Icons.note_rounded),
              ),
              maxLines: 2,
              maxLength: 50,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleAddCustomer,
                child: Text('customer.add'.tr()),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
