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

/// Shows a bottom sheet dialog for adding a payment
void showAddPaymentDialog(
  BuildContext context,
  StorageService storage,
  Debt debt,
  String debtId,
  double remaining,
) {
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;
  final currencyFormat = NumberFormat.currency(
    symbol: 'MMK ',
    decimalDigits: 0,
  );

  DateTime paymentDate = DateTime.now();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
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
                'payment.add'.tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${'debt.remaining'.tr()}: ${currencyFormat.format(remaining)}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'payment.amount_required'.tr(),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                  CurrencyInputFormatter(),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: paymentDate,
                    firstDate: debt.startDate,
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => paymentDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'payment.date'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, y').format(paymentDate),
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'payment.notes'.tr(),
                  prefixIcon: const Icon(Icons.note_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 50,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = CurrencyInputFormatter.parse(
                      amountController.text,
                    );
                    if (amount == null || amount <= 0) {
                      AppToast.showError(
                        context,
                        'payment.amount_required_msg'.tr(),
                      );
                      return;
                    }

                    if (amount > remaining) {
                      AppToast.showWarning(
                        context,
                        'payment.exceed_warning'.tr(),
                      );
                      return;
                    }

                    final now = DateTime.now();
                    final payment = Payment(
                      id: const Uuid().v4(),
                      loanId: debtId,
                      amount: amount,
                      paymentDate: paymentDate,
                      notes: notesController.text.trim(),
                      createdAt: now,
                    );

                    // Get total paid BEFORE adding new payment to avoid double counting
                    final currentTotalPaid = storage.getTotalPaidForDebt(
                      debtId,
                    );

                    storage.addPayment(payment);

                    // Auto-complete debt if fully paid (remaining balance is exactly 0)
                    final newTotalPaid = currentTotalPaid + amount;
                    if (newTotalPaid >= debt.totalAmount) {
                      debt.status = DebtStatus.completed;
                      debt.updatedAt = DateTime.now();
                      storage.updateDebt(debt);
                    }

                    Navigator.pop(context);
                  },
                  child: Text('payment.add'.tr()),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
}
