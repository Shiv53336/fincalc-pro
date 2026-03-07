import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Styled text input with rupee prefix
class StyledInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  const StyledInput({Key? key, required this.controller, required this.label, this.hint, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w500),
          hintText: hint,
          prefixText: 'Rs. ',
          prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
      ),
    );
  }
}

/// Deduction input with max limit label
class DeductionInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String maxLabel;
  const DeductionInput({Key? key, required this.controller, required this.label, required this.maxLabel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
            decoration: InputDecoration(
              border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
              labelText: label,
              labelStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
              prefixText: 'Rs. ',
              prefixStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ),
        Text('Max: $maxLabel', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
      ]),
    );
  }
}

/// Slider card with label, value badge, and themed slider
class SliderCard extends StatelessWidget {
  final String label;
  final double value;
  final String displayValue;
  final double min;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;
  const SliderCard({Key? key, required this.label, required this.value, required this.displayValue, required this.min, required this.max, required this.color, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMed)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(displayValue, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color, inactiveTrackColor: AppColors.borderLight,
            thumbColor: color, trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayColor: color.withOpacity(0.15),
          ),
          child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
        ),
      ]),
    );
  }
}

/// Gradient result card used at top of calculator screens
class ResultCard extends StatelessWidget {
  final List<Widget> children;
  const ResultCard({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryLight]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

/// Mini stat label + value (used inside ResultCard)
class MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const MiniStat(this.label, this.value, this.valueColor, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w700)),
    ]);
  }
}

/// Detail row (label + value) used in tax breakdown
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const DetailRow(this.label, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight), overflow: TextOverflow.ellipsis)),
        Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text)),
      ]),
    );
  }
}

/// Action button (Save PDF, Share, etc.)
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const ActionButton({Key? key, required this.icon, required this.label, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent)),
        ]),
      ),
    );
  }
}

/// Segmented tab selector
class SegmentedTab extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const SegmentedTab({Key? key, required this.labels, required this.selectedIndex, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(
        children: labels.asMap().entries.map((entry) {
          bool isSelected = entry.key == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(entry.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textMed)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
