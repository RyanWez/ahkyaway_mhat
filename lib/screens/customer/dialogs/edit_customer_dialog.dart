import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/customer.dart';
import '../../../services/storage_service.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_toast.dart';
import '../../../widgets/optimized_bottom_sheet.dart';

/// Shows a bottom sheet dialog for editing an existing customer with blur effect
/// Optimized: Uses OptimizedBottomSheet for smooth keyboard animation
void showEditCustomerDialog(
  BuildContext context,
  Customer customer,
  StorageService storage,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => EditCustomerSheet(
      customer: customer,
      storage: storage,
    ),
  );
}

class EditCustomerSheet extends StatefulWidget {
  final Customer customer;
  final StorageService storage;

  const EditCustomerSheet({
    super.key,
    required this.customer,
    required this.storage,
  });

  @override
  State<EditCustomerSheet> createState() => _EditCustomerSheetState();
}

class _EditCustomerSheetState extends State<EditCustomerSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phone);
    
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

  void _handleSaveCustomer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppToast.showError(context, 'customer.name_required_msg'.tr());
      return;
    }

    widget.customer.name = name;
    widget.customer.phone = _phoneController.text.trim();
    widget.customer.updatedAt = DateTime.now();

    widget.storage.updateCustomer(widget.customer);
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
                icon: Icons.person_rounded,
                title: 'customer.edit'.tr(),
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
                label: 'actions.save'.tr(),
                onPressed: _handleSaveCustomer,
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
