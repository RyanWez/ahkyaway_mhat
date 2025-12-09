import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/customer.dart';
import '../../../services/storage_service.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_toast.dart';

/// Shows a bottom sheet dialog for editing an existing customer
void showEditCustomerDialog(
  BuildContext context,
  Customer customer,
  StorageService storage,
) {
  final nameController = TextEditingController(text: customer.name);
  final phoneController = TextEditingController(text: customer.phone);
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
              'customer.edit'.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
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
              controller: phoneController,
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    AppToast.showError(
                      context,
                      'customer.name_required_msg'.tr(),
                    );
                    return;
                  }

                  customer.name = nameController.text.trim();
                  customer.phone = phoneController.text.trim();
                  customer.updatedAt = DateTime.now();

                  storage.updateCustomer(customer);
                  Navigator.pop(context);
                },
                child: Text('actions.save'.tr()),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}
