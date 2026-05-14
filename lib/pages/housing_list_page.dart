import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/housing.dart';
import '../providers/housing_state.dart';
import '../widgets/common_widgets.dart';
import 'edit_housing_page.dart';

class HousingListPage extends StatelessWidget {
  const HousingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sorted = [...context.watch<HousingState>().housings]
      ..sort((a, b) => b.cpScore.compareTo(a.cpScore));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('北科學生租屋推薦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('依 CP 值加權排名', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: sorted.isEmpty
          ? const Center(child: Text('還沒有房源，點右下角 + 新增'))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: sorted.length,
              itemBuilder: (ctx, i) =>
                  _HousingCard(housing: sorted[i], rank: i + 1),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const EditHousingPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HousingCard extends StatelessWidget {
  final Housing housing;
  final int rank;
  const _HousingCard({required this.housing, required this.rank});

  @override
  Widget build(BuildContext context) {
    final h = housing;
    final rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFB0BEC5)
            : rank == 3
                ? const Color(0xFFBF8970)
                : const Color(0xFFE3F2FD);
    final rankTextColor = rank <= 3 ? Colors.white : const Color(0xFF1565C0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => EditHousingPage(housing: h))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 標題列 ──────────────────────────
              Row(children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
                  child: Center(child: Text('$rank',
                      style: TextStyle(fontWeight: FontWeight.bold, color: rankTextColor, fontSize: 13))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(h.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                      Text(' ${h.city} ${h.district}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      const SizedBox(width: 6),
                      Icon(Icons.train, size: 12, color: Colors.grey[500]),
                      Text(' ${h.nearbyStation}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ]),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: h.recommendationColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(h.recommendation,
                      style: TextStyle(
                          color: h.recommendationColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
              ]),
              const SizedBox(height: 10),

              // ── 成本列 ──────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  _CostItem(label: '月租金', value: h.rent.toStringAsFixed(0), unit: '元'),
                  _Divider(),
                  _CostItem(label: '月通勤費', value: h.monthlyCommuteCost.toStringAsFixed(0), unit: '元'),
                  _Divider(),
                  _CostItem(
                      label: '月總成本',
                      value: h.totalMonthlyCost.toStringAsFixed(0),
                      unit: '元',
                      highlight: true),
                ]),
              ),
              const SizedBox(height: 8),

              // ── 交通 + 坪數 ──────────────────────
              Row(children: [
                Icon(h.transportIcon, size: 13, color: Colors.grey[600]),
                Text(' ${h.transportType} ${h.commuteMinutes.toStringAsFixed(0)}分鐘',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(width: 10),
                Icon(Icons.square_foot, size: 13, color: Colors.grey[600]),
                Text(
                    ' ${h.size.toStringAsFixed(0)}坪 · ${h.pricePerPing.toStringAsFixed(0)}元/坪',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ]),
              const SizedBox(height: 8),

              // ── CP 值條 ──────────────────────────
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('CP 值',
                        style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                    const SizedBox(height: 3),
                    LinearProgressIndicator(
                      value: h.cpScore / 100,
                      backgroundColor: Colors.grey[200],
                      color: h.recommendationColor,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ]),
                ),
                const SizedBox(width: 10),
                Text(h.cpScore.toStringAsFixed(1),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: h.recommendationColor)),
              ]),

              // ── 優點標籤 ─────────────────────────
              if (h.strengths.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(children: h.strengths.map((s) => TagChip(text: s)).toList()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CostItem extends StatelessWidget {
  final String label, value, unit;
  final bool highlight;
  const _CostItem(
      {required this.label, required this.value, required this.unit, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: highlight ? const Color(0xFF1565C0) : Colors.black87)),
        Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ]),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: Colors.grey[300]);
}