import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/housing_state.dart';
import 'compare_detail_page.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});
  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final Set<String> _sel = {};

  @override
  Widget build(BuildContext context) {
    final housings = context.watch<HousingState>().housings;
    final sorted = [...housings]..sort((a, b) => b.cpScore.compareTo(a.cpScore));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('房源比較'),
      ),
      body: housings.isEmpty
          ? const Center(child: Text('請先在房源頁新增房源'))
          : Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFFF5F5F5),
                child: Row(children: [
                  const Icon(Icons.info_outline, size: 15, color: Color(0xFF1565C0)),
                  const SizedBox(width: 6),
                  Text('已選 ${_sel.length}/3 間 · 至少選 2 間才能比較',
                      style: const TextStyle(color: Color(0xFF1565C0), fontSize: 13)),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: sorted.length,
                  itemBuilder: (ctx, i) {
                    final h = sorted[i];
                    final sel = _sel.contains(h.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: sel ? const Color(0xFFE3F2FD) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: sel
                            ? const BorderSide(color: Color(0xFF1565C0), width: 2)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => sel
                            ? _sel.remove(h.id)
                            : (_sel.length < 3 ? _sel.add(h.id) : null)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(children: [
                            Checkbox(
                              value: sel,
                              onChanged: (v) => setState(() =>
                                  v == true && _sel.length < 3
                                      ? _sel.add(h.id)
                                      : _sel.remove(h.id)),
                            ),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('${h.city} ${h.district} · ${h.nearbyStation}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                Text(
                                    '租 ${h.rent.toStringAsFixed(0)}元 · 通勤 ${h.monthlyCommuteCost.toStringAsFixed(0)}元/月',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ]),
                            ),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text(h.cpScore.toStringAsFixed(1),
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: h.recommendationColor)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: h.recommendationColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(h.recommendation,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: h.recommendationColor,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ]),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_sel.length >= 2)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: () {
                      final picked = housings.where((h) => _sel.contains(h.id)).toList();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => CompareDetailPage(housings: picked)));
                    },
                    icon: const Icon(Icons.compare_arrows),
                    label: Text('比較選取的 ${_sel.length} 間房源'),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: const Color(0xFF1565C0)),
                  ),
                ),
            ]),
    );
  }
}