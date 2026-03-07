import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';

class GstCalculatorScreen extends StatefulWidget {
  const GstCalculatorScreen({Key? key}) : super(key: key);
  @override
  State<GstCalculatorScreen> createState() => _GstCalculatorScreenState();
}

class _GstCalculatorScreenState extends State<GstCalculatorScreen> {
  final _amountCtrl = TextEditingController(text: '10000');
  int _rateIndex = 2; // 0=5%, 1=12%, 2=18%, 3=28%
  int _type = 0; // 0 = Exclusive (add GST), 1 = Inclusive (extract GST)
  int _supplyType = 0; // 0 = Intra-state (CGST+SGST), 1 = Inter-state (IGST)

  final List<double> _rates = [5, 12, 18, 28];

  double get _amount => double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
  double get _gstRate => _rates[_rateIndex];

  double get _baseAmount {
    if (_type == 0) return _amount; // Exclusive: amount is base
    return _amount / (1 + _gstRate / 100); // Inclusive: extract base
  }

  double get _gstAmount => _baseAmount * _gstRate / 100;
  double get _totalAmount => _baseAmount + _gstAmount;
  double get _cgst => _supplyType == 0 ? _gstAmount / 2 : 0;
  double get _sgst => _supplyType == 0 ? _gstAmount / 2 : 0;
  double get _igst => _supplyType == 1 ? _gstAmount : 0;

  @override
  void dispose() { _amountCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GST Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Type toggle
          SegmentedTab(labels: const ['Exclusive (+ GST)', 'Inclusive (has GST)'],
              selectedIndex: _type, onChanged: (i) => setState(() => _type = i)),
          const SizedBox(height: 12),

          // Amount
          StyledInput(controller: _amountCtrl, label: _type == 0 ? 'Amount (before GST)' : 'Amount (with GST)',
              onChanged: (_) => setState(() {})),

          // GST Rate
          const Text('GST Rate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 8),
          Row(children: List.generate(4, (i) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _rateIndex = i),
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _rateIndex == i ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _rateIndex == i ? AppColors.primary : AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text('${_rates[i].round()}%',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: _rateIndex == i ? Colors.white : AppColors.textMed)),
              ),
            ),
          ))),
          const SizedBox(height: 12),

          // Supply type
          SegmentedTab(labels: const ['Intra-State (CGST+SGST)', 'Inter-State (IGST)'],
              selectedIndex: _supplyType, onChanged: (i) => setState(() => _supplyType = i)),
          const SizedBox(height: 20),

          // Result
          if (_amount > 0) ...[
            ResultCard(children: [
              Text('Total Amount', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 4),
              Text(formatRupee(_totalAmount), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('GST: ${formatRupee(_gstAmount)} (${_gstRate.round()}%)',
                  style: const TextStyle(color: Color(0xFFFC8181), fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 16),

            // Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 12),
                _GstRow('Base Amount', formatRupee(_baseAmount)),
                if (_supplyType == 0) ...[
                  _GstRow('CGST (${(_gstRate / 2).toStringAsFixed(1)}%)', formatRupee(_cgst)),
                  _GstRow('SGST (${(_gstRate / 2).toStringAsFixed(1)}%)', formatRupee(_sgst)),
                ] else
                  _GstRow('IGST (${_gstRate.round()}%)', formatRupee(_igst)),
                const Divider(height: 16),
                _GstRow('Total', formatRupee(_totalAmount), bold: true),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

class _GstRow extends StatelessWidget {
  final String label, value; final bool bold;
  const _GstRow(this.label, this.value, {this.bold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 13, color: bold ? AppColors.text : AppColors.textMed, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: bold ? AppColors.success : AppColors.text)),
      ]),
    );
  }
}
