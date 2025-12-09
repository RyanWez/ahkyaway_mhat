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

/// Shows a bottom sheet dialog for editing a debt
void showEditDebtDialog(
  BuildContext context,
  Debt debt,
  StorageService storage,
) {
  final principalController = TextEditingController(
    text: NumberFormat('#,###', 'en_US').format(debt.principal.toInt()),
  );
  final notesController = TextEditingController(text: debt.notes);
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;

  DateTime debtDate = debt.startDate;
  DateTime dueDate = debt.dueDate;

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
                'debt.edit'.tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: principalController,
                decoration: InputDecoration(
                  labelText: 'debt.amount_required'.tr(),
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
              // Start Date Picker
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: debtDate.isAfter(DateTime.now()) 
                        ? DateTime.now() 
                        : debtDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(), // Only allow today and past dates
                  );
                  if (picked != null) {
                    setState(() {
                      debtDate = picked;
                      // Auto-adjust due date if it's now before the new start date
                      if (dueDate.isBefore(picked)) {
                        // Set due date to end of month of the new start date
                        dueDate = DateTime(picked.year, picked.month + 1, 0);
                        AppToast.showInfo(
                          context,
                          'debt.due_date_adjusted'.tr(),
                        );
                      }
                    });
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
                            'debt.start_date'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, y').format(debtDate),
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
              const SizedBox(height: 12),
              // Due Date Picker
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: debtDate,
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => dueDate = picked);
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
                    border: Border.all(
                      color: AppTheme.warningColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        color: AppTheme.warningColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'debt.due_date'.tr(),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              DateFormat('MMM d, y').format(dueDate),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.warningColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'debt.notes'.tr(),
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
                  onPressed: () {
                    final principal = CurrencyInputFormatter.parse(
                      principalController.text,
                    );
                    if (principal == null || principal <= 0) {
                      AppToast.showError(
                        context,
                        'debt.amount_required_msg'.tr(),
                      );
                      return;
                    }

                    if (principal > 99999999) {
                      AppToast.showWarning(context, 'messages.max_amount'.tr());
                      return;
                    }

                    debt.principal = principal;
                    debt.startDate = debtDate;
                    debt.dueDate = dueDate;
                    debt.notes = notesController.text.trim();
                    debt.updatedAt = DateTime.now();

                    storage.updateDebt(debt);
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
    ),
  );
}
