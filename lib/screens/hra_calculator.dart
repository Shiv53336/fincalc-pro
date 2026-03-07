import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';
import '../widgets/shared_widgets.dart';

class HraCalculatorScreen extends StatefulWidget {
  const HraCalculatorScreen({Key? key}) : super(key: key);
  @override
  State<HraCalculatorScreen> createState() => _HraCalculatorScreenState();
}

class _HraCalculatorScreenState extends State<HraCalculatorScreen> {
  final _basicCtrl = TextEditingController();
  final _hraCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  bool _isMetro = true, _done = false;
  double _exempt = 0, _taxable = 0;

  void _calc() {
    double b = double.tryParse(_basicCtrl.text.replaceAll(',', '')) ?? 0;
    double h = double.tryParse(_hraCtrl.text.replaceAll(',', '')) ?? 0;
    double r = double.tryParse(_rentCtrl.text.replaceAll(',', '')) ?? 0;
    _exempt = max(0, [h, r - 0.10 * b, (_isMetro ? 0.50 : 0.40) * b].reduce(min));
    _taxable = max(h - _exempt, 0);
    setState(() => _done = true);
  }

  @override
  void dispose() { _basicCtrl.dispose(); _hraCtrl.dispose(); _rentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HRA Calculator')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        StyledInput(controller: _basicCtrl, label: 'Basic Salary (Annual)'),
        StyledInput(controller: _hraCtrl, label: 'HRA Received (Annual)'),
        StyledInput(controller: _rentCtrl, label: 'Rent Paid (Annual)'),
        const SizedBox(height: 12),
        SegmentedTab(labels: const ['Metro (50%)', 'Non-Metro (40%)'], selectedIndex: _isMetro ? 0 : 1,
            onChanged: (i) => setState(() => _isMetro = i == 0)),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calc, child: const Text('Calculate HRA →'))),
        const SizedBox(height: 20),
        if (_done) ResultCard(children: [
          Text('HRA Exempt', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          Text(formatRupee(_exempt), style: const TextStyle(color: Color(0xFF48BB78), fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Taxable HRA: ${formatRupee(_taxable)}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
        ]),
      ])),
    );
  }
}
