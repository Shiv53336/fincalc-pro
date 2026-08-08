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

/// Slider card with label, value badge, and themed slider.
/// Tap the value badge to type an exact value.
class SliderCard extends StatefulWidget {
  final String label;
  final double value;
  final String? displayValue;
  final String Function(double)? format;
  final int? divisions;
  final double min;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;
  const SliderCard({Key? key, required this.label, required this.value, this.displayValue, this.format, this.divisions, required this.min, required this.max, required this.color, required this.onChanged}) : super(key: key);

  @override
  State<SliderCard> createState() => _SliderCardState();
}

class _SliderCardState extends State<SliderCard> {
  String get _displayText => widget.displayValue ?? widget.format?.call(widget.value) ?? widget.value.toStringAsFixed(1);

  void _showEditDialog(BuildContext context) {
    final ctrl = TextEditingController(text: widget.value.toStringAsFixed(widget.value == widget.value.roundToDouble() ? 0 : 1));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter value (${widget.min.toStringAsFixed(0)} – ${widget.max.toStringAsFixed(0)})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text.replaceAll(',', ''));
              if (v != null) widget.onChanged(v.clamp(widget.min, widget.max));
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMed)),
          GestureDetector(
            onTap: () => _showEditDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_displayText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.color)),
                const SizedBox(width: 4),
                Icon(Icons.edit, size: 11, color: widget.color.withOpacity(0.6)),
              ]),
            ),
          ),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.color, inactiveTrackColor: AppColors.borderLight,
            thumbColor: widget.color, trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayColor: widget.color.withOpacity(0.15),
          ),
          child: Slider(value: widget.value.clamp(widget.min, widget.max), min: widget.min, max: widget.max, divisions: widget.divisions, onChanged: widget.onChanged),
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
  final bool isBold;
  final Color? valueColor;
  const DetailRow({Key? key, required this.label, required this.value, this.isBold = false, this.valueColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight), overflow: TextOverflow.ellipsis)),
        Text(value, style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600, color: valueColor ?? AppColors.text)),
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
