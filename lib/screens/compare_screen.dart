import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/scenario_storage.dart';
import '../services/premium_manager.dart';

class CompareScenariosScreen extends StatefulWidget {
  const CompareScenariosScreen({Key? key}) : super(key: key);

  @override
  State<CompareScenariosScreen> createState() => _CompareScenariosScreenState();
}

class _CompareScenariosScreenState extends State<CompareScenariosScreen> {
  List<ScenarioData> _scenarios = [];
  ScenarioData? _scenarioA;
  ScenarioData? _scenarioB;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ScenarioStorage.loadAll();
    setState(() { _scenarios = list; _loading = false; });
  }

  Future<void> _delete(String id) async {
    await ScenarioStorage.delete(id);
    await _load();
    if (_scenarioA?.id == id) setState(() => _scenarioA = null);
    if (_scenarioB?.id == id) setState(() => _scenarioB = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Save & Compare')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _scenarios.isEmpty
              ? _EmptyState()
              : Column(children: [
                  // Selector row
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Select two scenarios to compare', style: TextStyle(fontSize: 13, color: AppColors.textMed)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _ScenarioPicker(
                          label: 'Scenario A',
                          color: AppColors.accent,
                          selected: _scenarioA,
                          scenarios: _scenarios,
                          exclude: _scenarioB?.id,
                          onSelect: (s) => setState(() => _scenarioA = s),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _ScenarioPicker(
                          label: 'Scenario B',
                          color: AppColors.success,
                          selected: _scenarioB,
                          scenarios: _scenarios,
                          exclude: _scenarioA?.id,
                          onSelect: (s) => setState(() => _scenarioB = s),
                        )),
                      ]),
                    ]),
                  ),

                  // Comparison view
                  if (_scenarioA != null && _scenarioB != null)
                    Expanded(child: _ComparisonView(a: _scenarioA!, b: _scenarioB!))
                  else
                    Expanded(child: _SavedList(scenarios: _scenarios, onDelete: _delete)),
                ]),
    );
  }
}

class _ScenarioPicker extends StatelessWidget {
  final String label;
  final Color color;
  final ScenarioData? selected;
  final List<ScenarioData> scenarios;
  final String? exclude;
  final ValueChanged<ScenarioData?> onSelect;

  const _ScenarioPicker({
    required this.label, required this.color, required this.selected,
    required this.scenarios, required this.exclude, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected != null ? color.withOpacity(0.08) : AppColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected != null ? color : AppColors.border, width: selected != null ? 1.5 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 4),
          Text(
            selected?.name ?? 'Tap to select',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected != null ? AppColors.text : AppColors.textLight),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (selected != null)
            Text(selected!.calculator, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ]),
      ),
    );
  }

  void _pick(BuildContext context) {
    final available = scenarios.where((s) => s.id != exclude).toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Select $label', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),
        if (available.isEmpty)
          const Padding(padding: EdgeInsets.all(20), child: Text('No other saved scenarios.'))
        else
          ...available.map((s) => ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.assessment_rounded, color: color, size: 20),
            ),
            title: Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(s.calculator),
            onTap: () { Navigator.pop(context); onSelect(s); },
          )),
        const SizedBox(height: 16),
      ]),
    );
  }
}

class _ComparisonView extends StatelessWidget {
  final ScenarioData a;
  final ScenarioData b;
  const _ComparisonView({required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    // Collect all unique keys from both
    final allKeys = {...a.results.keys, ...b.results.keys}.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Header
        Row(children: [
          const Expanded(flex: 3, child: SizedBox()),
          Expanded(flex: 3, child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              const Text('A', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accent)),
              Text(a.name, style: const TextStyle(fontSize: 11, color: AppColors.textMed), textAlign: TextAlign.center, maxLines: 2),
            ]),
          )),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              const Text('B', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success)),
              Text(b.name, style: const TextStyle(fontSize: 11, color: AppColors.textMed), textAlign: TextAlign.center, maxLines: 2),
            ]),
          )),
        ]),
        const SizedBox(height: 12),

        // Rows
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(children: allKeys.asMap().entries.map((e) {
            final key = e.value;
            final even = e.key % 2 == 0;
            final valA = a.results[key] ?? '—';
            final valB = b.results[key] ?? '—';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: even ? AppColors.bg : Colors.white,
              child: Row(children: [
                Expanded(flex: 3, child: Text(key, style: const TextStyle(fontSize: 12, color: AppColors.textMed))),
                Expanded(flex: 3, child: Text(valA, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent), textAlign: TextAlign.center)),
                const SizedBox(width: 8),
                Expanded(flex: 3, child: Text(valB, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success), textAlign: TextAlign.center)),
              ]),
            );
          }).toList()),
        ),
      ]),
    );
  }
}

class _SavedList extends StatelessWidget {
  final List<ScenarioData> scenarios;
  final Future<void> Function(String) onDelete;
  const _SavedList({required this.scenarios, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: scenarios.length,
      itemBuilder: (_, i) {
        final s = scenarios[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(children: [
            Container(width: 42, height: 42,
              decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.assessment_rounded, color: AppColors.accent, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
              Text(s.calculator, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              Text('Saved ${_formatDate(s.savedAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            ])),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textLight),
              onPressed: () => onDelete(s.id),
            ),
          ]),
        );
      },
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.bookmark_border_rounded, size: 64, color: AppColors.textLight),
        const SizedBox(height: 16),
        const Text('No saved scenarios yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 8),
        const Text('Save any calculation result using the\nbookmark button on calculator screens.', style: TextStyle(fontSize: 13, color: AppColors.textMed), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        if (!PremiumManager.isPremium)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(12)),
            child: const Text('Free users can save 1 scenario. Upgrade for unlimited.', style: TextStyle(fontSize: 12, color: AppColors.text), textAlign: TextAlign.center),
          ),
      ]),
    );
  }
}
