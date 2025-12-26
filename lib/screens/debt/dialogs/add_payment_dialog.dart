import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/debt.dart';
import '../../../models/payment.dart';
import '../../../services/storage_service.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/currency_input_formatter.dart';
import '../../../widgets/app_toast.dart';
import '../../../widgets/optimized_bottom_sheet.dart';

/// Shows a bottom sheet dialog for adding a payment
/// Optimized: Uses OptimizedBottomSheet for smooth keyboard animation
void showAddPaymentDialog(
  BuildContext context,
  StorageService storage,
  Debt debt,
  String debtId,
  double remaining,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => AddPaymentSheet(
      storage: storage,
      debt: debt,
      debtId: debtId,
      remaining: remaining,
    ),
  );
}

class AddPaymentSheet extends StatefulWidget {
  final StorageService storage;
  final Debt debt;
  final String debtId;
  final double remaining;

  const AddPaymentSheet({
    super.key,
    required this.storage,
    required this.debt,
    required this.debtId,
    required this.remaining,
  });

  @override
  State<AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<AddPaymentSheet>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  
  DateTime _paymentDate = DateTime.now();

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
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleAddPayment() {
    final amount = CurrencyInputFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      AppToast.showError(context, 'payment.amount_required_msg'.tr());
      return;
    }

    if (amount > widget.remaining) {
      AppToast.showWarning(context, 'payment.exceed_warning'.tr());
      return;
    }

    final now = DateTime.now();
    final payment = Payment(
      id: const Uuid().v4(),
      loanId: widget.debtId,
      amount: amount,
      paymentDate: _paymentDate,
      notes: _notesController.text.trim(),
      createdAt: now,
    );

    // Get total paid BEFORE adding new payment
    final currentTotalPaid = widget.storage.getTotalPaidForDebt(widget.debtId);
    widget.storage.addPayment(payment);

    // Auto-complete debt if fully paid
    final newTotalPaid = currentTotalPaid + amount;
    if (newTotalPaid >= widget.debt.totalAmount) {
      widget.debt.status = DebtStatus.completed;
      widget.debt.updatedAt = DateTime.now();
      widget.storage.updateDebt(widget.debt);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final currencyFormat = NumberFormat.currency(symbol: 'MMK ', decimalDigits: 0);

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: child,
        );
      },
      child: OptimizedBottomSheet(
        accentColor: AppTheme.successColor,
        isDark: isDark,
        content: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              SheetHandleBar(accentColor: AppTheme.successColor),
              const SizedBox(height: 24),
              
              // Header with remaining amount
              SheetHeader(
                icon: Icons.payments_rounded,
                title: 'payment.add'.tr(),
                accentColor: AppTheme.successColor,
                isDark: isDark,
                subtitle: Text(
                  '${'debt.remaining'.tr()}: ${currencyFormat.format(widget.remaining)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Amount field
              _buildTextField(
                controller: _amountController,
                label: 'payment.amount_required'.tr(),
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
              
              // Payment Date Picker
              _buildDatePicker(
                label: 'payment.date'.tr(),
                date: _paymentDate,
                icon: Icons.calendar_today_rounded,
                isDark: isDark,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate,
                    firstDate: widget.debt.startDate,
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _paymentDate = picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Notes field
              _buildTextField(
                controller: _notesController,
                label: 'payment.notes'.tr(),
                icon: Icons.note_rounded,
                isDark: isDark,
                maxLength: 50,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 28),
              
              // Submit button
              SheetSubmitButton(
                label: 'payment.add'.tr(),
                onPressed: _handleAddPayment,
                primaryColor: AppTheme.successColor,
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
            color: AppTheme.successColor.withValues(alpha: 0.8),
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
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
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
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            const SizedBox(width: 12),
            Column(
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
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
