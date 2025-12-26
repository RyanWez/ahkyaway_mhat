import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/debt.dart';
import '../../../services/storage_service.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/currency_input_formatter.dart';
import '../../../widgets/app_toast.dart';
import '../../../widgets/optimized_bottom_sheet.dart';

/// Shows a bottom sheet dialog for editing a debt with blur effect
/// Optimized: Uses OptimizedBottomSheet for smooth keyboard animation
void showEditDebtDialog(
  BuildContext context,
  Debt debt,
  StorageService storage,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => EditDebtSheet(
      debt: debt,
      storage: storage,
    ),
  );
}

class EditDebtSheet extends StatefulWidget {
  final Debt debt;
  final StorageService storage;

  const EditDebtSheet({
    super.key,
    required this.debt,
    required this.storage,
  });

  @override
  State<EditDebtSheet> createState() => _EditDebtSheetState();
}

class _EditDebtSheetState extends State<EditDebtSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _principalController;
  late TextEditingController _notesController;
  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  
  late DateTime _debtDate;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    _principalController = TextEditingController(
      text: NumberFormat('#,###', 'en_US').format(widget.debt.principal.toInt()),
    );
    _notesController = TextEditingController(text: widget.debt.notes);
    _debtDate = widget.debt.startDate;
    _dueDate = widget.debt.dueDate;
    
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
    _principalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSaveDebt() {
    final principal = CurrencyInputFormatter.parse(_principalController.text);
    if (principal == null || principal <= 0) {
      AppToast.showError(context, 'debt.amount_required_msg'.tr());
      return;
    }

    if (principal > 99999999) {
      AppToast.showWarning(context, 'messages.max_amount'.tr());
      return;
    }

    widget.debt.principal = principal;
    widget.debt.startDate = _debtDate;
    widget.debt.dueDate = _dueDate;
    widget.debt.notes = _notesController.text.trim();
    widget.debt.updatedAt = DateTime.now();

    widget.storage.updateDebt(widget.debt);
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
        accentColor: AppTheme.warningColor,
        isDark: isDark,
        content: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              SheetHandleBar(accentColor: AppTheme.warningColor),
              const SizedBox(height: 24),
              
              // Header
              SheetHeader(
                icon: Icons.edit_note_rounded,
                title: 'debt.edit'.tr(),
                accentColor: AppTheme.warningColor,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              
              // Amount field
              _buildTextField(
                controller: _principalController,
                label: 'debt.amount_required'.tr(),
                icon: Icons.attach_money_rounded,
                isDark: isDark,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                  CurrencyInputFormatter(),
                ],
              ),
              const SizedBox(height: 16),
              
              // Start Date Picker
              _buildDatePicker(
                label: 'debt.start_date'.tr(),
                date: _debtDate,
                icon: Icons.calendar_today_rounded,
                iconColor: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                isDark: isDark,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _debtDate.isAfter(DateTime.now()) 
                        ? DateTime.now() 
                        : _debtDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _debtDate = picked;
                      if (_dueDate.isBefore(picked)) {
                        _dueDate = DateTime(picked.year, picked.month + 1, 0);
                        AppToast.showInfo(context, 'debt.due_date_adjusted'.tr());
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              
              // Due Date Picker
              _buildDatePicker(
                label: 'debt.due_date'.tr(),
                date: _dueDate,
                icon: Icons.event_rounded,
                iconColor: AppTheme.warningColor,
                isDark: isDark,
                showBadge: false,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: _debtDate,
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Notes field
              _buildTextField(
                controller: _notesController,
                label: 'debt.notes'.tr(),
                icon: Icons.note_rounded,
                isDark: isDark,
                maxLines: 2,
                maxLength: 50,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 28),
              
              // Submit button
              SheetSubmitButton(
                label: 'actions.save'.tr(),
                onPressed: _handleSaveDebt,
                primaryColor: AppTheme.warningColor,
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
    int maxLines = 1,
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
            color: AppTheme.warningColor.withValues(alpha: 0.8),
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
        maxLines: maxLines,
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
    bool showBadge = false,
    String? badgeText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: showBadge 
                ? AppTheme.warningColor.withValues(alpha: 0.3)
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2)),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, y').format(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: showBadge ? FontWeight.w500 : FontWeight.normal,
                      color: showBadge 
                          ? AppTheme.warningColor
                          : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    ),
                  ),
                ],
              ),
            ),
            if (showBadge && badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.warningColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
