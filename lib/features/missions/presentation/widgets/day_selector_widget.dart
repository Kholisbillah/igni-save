import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme_colors.dart';

class DaySelectorWidget extends StatelessWidget {
  final List<int> selectedDays; // 0=Sunday, 1=Monday, ..., 6=Saturday
  final ValueChanged<List<int>> onDaysChanged;

  const DaySelectorWidget({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

  static const List<String> _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List.generate(7, (index) {
        final isSelected = selectedDays.contains(index);
        return GestureDetector(
          onTap: () => _toggleDay(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppThemeColors.primary
                  : AppThemeColors.surface, // Changed to surface
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppThemeColors.primary
                    : AppThemeColors.borderLight, // Added border for unselected
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppThemeColors.primary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                _dayLabels[index],
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppThemeColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _toggleDay(int day) {
    final newDays = List<int>.from(selectedDays);
    if (newDays.contains(day)) {
      newDays.remove(day);
    } else {
      newDays.add(day);
    }
    newDays.sort();
    onDaysChanged(newDays);
  }
}
