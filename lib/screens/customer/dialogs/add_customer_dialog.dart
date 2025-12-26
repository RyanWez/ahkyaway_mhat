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
import '../../../widgets/optimized_bottom_sheet.dart';

/// Shows a bottom sheet dialog for adding a new customer with blur effect
/// Optimized: Uses OptimizedBottomSheet for smooth keyboard animation
void showAddCustomerDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => const AddCustomerSheet(),
  );
}

class AddCustomerSheet extends StatefulWidget {
  const AddCustomerSheet({super.key});

  @override
  State<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<AddCustomerSheet>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
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
      address: '',
      notes: '',
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

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: child,
        );
      },
      child: OptimizedBottomSheet(
        accentColor: AppTheme.primaryDark,
        isDark: isDark,
        content: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              SheetHandleBar(accentColor: AppTheme.primaryDark),
              const SizedBox(height: 24),
              
              // Header
              SheetHeader(
                icon: Icons.person_add_rounded,
                title: 'customer.add'.tr(),
                accentColor: AppTheme.primaryDark,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              
              // Name field
              _buildTextField(
                controller: _nameController,
                label: 'customer.name_required'.tr(),
                icon: Icons.person_rounded,
                isDark: isDark,
                maxLength: 32,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              // Phone field
              _buildTextField(
                controller: _phoneController,
                label: 'customer.phone'.tr(),
                icon: Icons.phone_rounded,
                isDark: isDark,
                maxLength: 11,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 28),
              
              // Submit button
              SheetSubmitButton(
                label: 'customer.add'.tr(),
                onPressed: _handleAddCustomer,
                primaryColor: AppTheme.primaryDark,
                secondaryColor: const Color(0xFF8B83FF),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            icon,
            color: AppTheme.primaryDark.withValues(alpha: 0.8),
          ),
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        textCapitalization: textCapitalization,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: [
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ...?inputFormatters,
        ],
      ),
    );
  }
}
