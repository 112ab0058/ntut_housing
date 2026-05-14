import 'package:flutter/material.dart';
import 'dart:math';
import '../models/housing.dart';
import '../widgets/common_widgets.dart';

class CompareDetailPage extends StatelessWidget {
  final List<Housing> housings;
  const CompareDetailPage({super.key, required this.housings});

  @override
  Widget build(BuildContext context) {
    final best = housings.reduce((a, b) => a.cpScore > b.cpScore ? a : b);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('詳細比較'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ① 最佳推薦卡
            _BestCard(h: best),
            const SizedBox(height: 16),

            // ② 各房源分析
            const Text('各房源分析',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...housings.map((h) => _HousingCard(h: h, isBest: h.id == best.id)),
            const SizedBox(height: 8),

            // ③ 進階指標比較
            _AdvancedTable(housings: housings),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// ① 最佳推薦卡
// ──────────────────────────────────────────────────────
class _BestCard extends StatelessWidget {
  final Housing h;
  const _BestCard({required this.h});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.3),
              blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 20),
          const SizedBox(width: 6),
          const Text('最佳推薦選擇', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        Text(h.name,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(spacing: 10, children: [
          _WhiteTag(Icons.location_on, '${h.city} ${h.district}'),
          _WhiteTag(Icons.train, h.nearbyStation),
          _WhiteTag(h.transportIcon, '${h.transportType} ${h.commuteMinutes.toStringAsFixed(0)}分鐘'),
        ]),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CP 值', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text(h.cpScore.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 52,
                    fontWeight: FontWeight.bold, height: 1.0)),
          ]),
          const SizedBox(width: 20),
          Expanded(
            child: Column(children: [
              _WRow('月租金', '${h.rent.toStringAsFixed(0)} 元'),
              _WRow('月通勤費', '${h.monthlyCommuteCost.toStringAsFixed(0)} 元'),
              _WRow('月總成本', '${h.totalMonthlyCost.toStringAsFixed(0)} 元', bold: true),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('推薦理由',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6, runSpacing: 4,
              children: h.strengths.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12)),
              )).toList(),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _WhiteTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _WhiteTag(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: Colors.white70),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]);
}

class _WRow extends StatelessWidget {
  final String l, v;
  final bool bold;
  const _WRow(this.l, this.v, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(v,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: bold ? 14 : 12,
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      );
}

// ──────────────────────────────────────────────────────
// ② 各房源分析卡
// ──────────────────────────────────────────────────────
class _HousingCard extends StatelessWidget {
  final Housing h;
  final bool isBest;
  const _HousingCard({required this.h, required this.isBest});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isBest
            ? const BorderSide(color: Color(0xFF1565C0), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 標題
          Row(children: [
            if (isBest) ...[
              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(h.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${h.city} ${h.district} · ${h.nearbyStation}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(h.cpScore.toStringAsFixed(1),
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                      color: h.recommendationColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: h.recommendationColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(h.recommendation,
                    style: const TextStyle(color: Colors.white, fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ]),
          ]),
          const Divider(height: 16),

          // 通勤資訊
          Wrap(spacing: 14, children: [
            _InfoItem(h.transportIcon, '${h.transportType} ${h.commuteMinutes.toStringAsFixed(0)}分'),
            if (h.oneWayFare > 0) _InfoItem(Icons.payment, '單程${h.oneWayFare.toStringAsFixed(0)}元'),
            _InfoItem(Icons.access_time, '年通勤${h.yearlyCommuteHours.toStringAsFixed(0)}h'),
          ]),
          const SizedBox(height: 10),

          // 成本格
          Row(children: [
            _CostBox('月租金', h.rent.toStringAsFixed(0), '元'),
            const SizedBox(width: 6),
            _CostBox('月通勤費', h.monthlyCommuteCost.toStringAsFixed(0), '元'),
            const SizedBox(width: 6),
            _CostBox('月總成本', h.totalMonthlyCost.toStringAsFixed(0), '元', hi: true),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _CostBox('坪數', h.size.toStringAsFixed(0), '坪'),
            const SizedBox(width: 6),
            _CostBox('每坪租金', h.pricePerPing.toStringAsFixed(0), '元/坪'),
            const SizedBox(width: 6),
            _CostBox('屋齡', h.age.toStringAsFixed(0), '年'),
          ]),
          const SizedBox(height: 10),

          // 分數條
          ScoreBar(label: '成本', value: h.costScore, color: const Color(0xFF1565C0)),
          ScoreBar(label: '通勤', value: h.commuteScore, color: const Color(0xFF00796B)),
          ScoreBar(label: '地段', value: h.districtConvenienceScore, color: const Color(0xFF7B1FA2)),
          ScoreBar(label: '設備', value: h.equipmentScore, color: const Color(0xFFF57F17)),
          const SizedBox(height: 6),

          // 優缺點
          if (h.strengths.isNotEmpty) ...[
            const Text('優點', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32))),
            const SizedBox(height: 4),
            Wrap(children: h.strengths.map((s) => TagChip(
                text: s,
                color: const Color(0xFFE8F5E9),
                textColor: const Color(0xFF2E7D32))).toList()),
          ],
          if (h.weaknesses.isNotEmpty) ...[
            const SizedBox(height: 6),
            const Text('缺點', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                color: Color(0xFFC62828))),
            const SizedBox(height: 4),
            Wrap(children: h.weaknesses.map((s) => TagChip(
                text: s,
                color: const Color(0xFFFFEBEE),
                textColor: const Color(0xFFC62828))).toList()),
          ],
        ]),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: Colors.grey[600]),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ]);
}

class _CostBox extends StatelessWidget {
  final String label, value, unit;
  final bool hi;
  const _CostBox(this.label, this.value, this.unit, {this.hi = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
              color: hi ? const Color(0xFFE3F2FD) : Colors.grey[50],
              borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text(value,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                    color: hi ? const Color(0xFF1565C0) : Colors.black87)),
            Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ]),
        ),
      );
}

// ──────────────────────────────────────────────────────
// ③ 進階指標比較
// ──────────────────────────────────────────────────────
class _AdvancedTable extends StatelessWidget {
  final List<Housing> housings;
  const _AdvancedTable({required this.housings});

  @override
  Widget build(BuildContext context) {
    // 權重說明資料
    final weights = [
      ['實際總成本分數', '30%'],
      ['通勤分數', '25%'],
      ['行政區便利性分數', '15%'],
      ['空間分數', '10%'],
      ['設備分數', '10%'],
      ['安全生活分數', '10%'],
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('進階指標比較',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          // 欄標題
          Row(children: [
            const SizedBox(width: 88),
            ...housings.map((h) => Expanded(
                child: Text(h.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
          ]),
          const Divider(height: 14),
          _CmpRow('CP 值', housings, (h) => h.cpScore, true, fmt: 'n1'),
          _CmpRow('月租金', housings, (h) => h.rent, false, fmt: 'currency'),
          _CmpRow('月通勤費', housings, (h) => h.monthlyCommuteCost, false, fmt: 'currency'),
          _CmpRow('月總成本', housings, (h) => h.totalMonthlyCost, false, fmt: 'currency'),
          _CmpRow('坪數', housings, (h) => h.size, true, fmt: 'ping'),
          _CmpRow('每坪租金', housings, (h) => h.pricePerPing, false, fmt: 'currency'),
          _CmpRow('通勤時間', housings, (h) => h.commuteMinutes, false, fmt: 'min'),
          _CmpRow('年通勤時數', housings, (h) => h.yearlyCommuteHours, false, fmt: 'hour'),
          _CmpRow('地段分數', housings, (h) => h.districtConvenienceScore, true, fmt: 'score'),
          _CmpRow('安全生活', housings, (h) => h.safetyLifeScore, true, fmt: 'score'),
          _CmpRow('設備分數', housings, (h) => h.equipmentScore, true, fmt: 'score'),
          const SizedBox(height: 14),

          // 權重說明
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('CP值權重說明 (Feature Weighting)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              ...weights.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(children: [
                      const Icon(Icons.circle, size: 6, color: Color(0xFF1565C0)),
                      const SizedBox(width: 7),
                      Expanded(child: Text(w[0], style: const TextStyle(fontSize: 11))),
                      Text(w[1],
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0))),
                    ]),
                  )),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _CmpRow extends StatelessWidget {
  final String label;
  final List<Housing> housings;
  final double Function(Housing) getValue;
  final bool higherBetter;
  final String fmt;

  const _CmpRow(this.label, this.housings, this.getValue, this.higherBetter,
      {required this.fmt});

  @override
  Widget build(BuildContext context) {
    final vals = housings.map(getValue).toList();
    final best = higherBetter ? vals.reduce(max) : vals.reduce(min);

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(children: [
        SizedBox(width: 88, child: Text(label, style: const TextStyle(fontSize: 11))),
        ...housings.map((h) {
          final v = getValue(h);
          final isBest = v == best;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: isBest ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(6),
                border: isBest ? Border.all(color: const Color(0xFF2E7D32)) : null,
              ),
              child: Text(_format(v), textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                      color: isBest ? const Color(0xFF2E7D32) : Colors.black87)),
            ),
          );
        }),
      ]),
    );
  }

  String _format(double v) {
    switch (fmt) {
      case 'n1': return v.toStringAsFixed(1);
      case 'currency': return '${v.toStringAsFixed(0)}元';
      case 'ping': return '${v.toStringAsFixed(0)}坪';
      case 'min': return '${v.toStringAsFixed(0)}分';
      case 'hour': return '${v.toStringAsFixed(0)}h';
      case 'score': return v.toStringAsFixed(0);
      default: return v.toStringAsFixed(0);
    }
  }
}