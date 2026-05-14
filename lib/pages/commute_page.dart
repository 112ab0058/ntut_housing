import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class CommutePage extends StatefulWidget {
  const CommutePage({super.key});
  @override
  State<CommutePage> createState() => _CommutePageState();
}

class _CommutePageState extends State<CommutePage> {
  double _rent = 8000;
  double _min = 15;
  String _transport = '捷運';
  double _fare = 25;

  double get _monthlyComm => _fare * 2 * 22;
  double get _yearlyComm => _monthlyComm * 12;
  double get _total => _rent + _monthlyComm;
  double get _yearlyHours => _min * 2 * 22 * 12 / 60;

  void _setTransport(String t) => setState(() {
        _transport = t;
        if (t == '步行' || t == '腳踏車') _fare = 0;
        else if (t == '公車') _fare = 15;
        else _fare = 25;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('通勤成本計算'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // 摘要卡
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('每月總花費', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text('${_total.toStringAsFixed(0)} 元',
                  style: const TextStyle(color: Colors.white, fontSize: 42,
                      fontWeight: FontWeight.bold, height: 1.1)),
              const SizedBox(height: 14),
              Row(children: [
                _Stat('通勤費/月', '${_monthlyComm.toStringAsFixed(0)}元'),
                const SizedBox(width: 8),
                _Stat('通勤費/年', '${_yearlyComm.toStringAsFixed(0)}元'),
                const SizedBox(width: 8),
                _Stat('年通勤時數', '${_yearlyHours.toStringAsFixed(0)}小時'),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('設定條件',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 14),
                SliderRow(label: '月租金', value: _rent, min: 3000, max: 25000,
                    divisions: 220, valueText: '${_rent.toStringAsFixed(0)}元',
                    onChanged: (v) => setState(() => _rent = v)),
                SliderRow(label: '單程通勤時間', value: _min, min: 1, max: 60,
                    divisions: 59, valueText: '${_min.toStringAsFixed(0)}分鐘',
                    onChanged: (v) => setState(() => _min = v)),
                const SizedBox(height: 8),
                const Text('通勤方式',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 6,
                  children: ['步行', '腳踏車', '公車', '捷運'].map((t) {
                    const icons = {
                      '步行': Icons.directions_walk,
                      '腳踏車': Icons.directions_bike,
                      '公車': Icons.directions_bus,
                      '捷運': Icons.train,
                    };
                    final sel = _transport == t;
                    return ChoiceChip(
                      label: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(icons[t]!, size: 15,
                            color: sel ? Colors.white : Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(t,
                            style: TextStyle(
                                color: sel ? Colors.white : Colors.grey[700],
                                fontSize: 13)),
                      ]),
                      selected: sel,
                      selectedColor: const Color(0xFF1565C0),
                      onSelected: (_) => _setTransport(t),
                    );
                  }).toList(),
                ),
                if (_transport == '捷運' || _transport == '公車') ...[
                  const SizedBox(height: 10),
                  SliderRow(label: '單程交通費', value: _fare, min: 0, max: 80,
                      divisions: 80, valueText: '${_fare.toStringAsFixed(0)}元',
                      onChanged: (v) => setState(() => _fare = v)),
                ] else ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 16),
                    const SizedBox(width: 6),
                    Text('$_transport 不需要交通費',
                        style: const TextStyle(color: Color(0xFF2E7D32))),
                  ]),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 14),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('通勤分析',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                _Row('每日通勤時間', '${(_min * 2).toStringAsFixed(0)} 分鐘'),
                _Row('每月通勤時間', '${(_min * 2 * 22).toStringAsFixed(0)} 分鐘'),
                _Row('每年通勤時數', '${_yearlyHours.toStringAsFixed(1)} 小時'),
                _Row('每日通勤費', '${(_fare * 2).toStringAsFixed(0)} 元'),
                _Row('每月通勤費', '${_monthlyComm.toStringAsFixed(0)} 元'),
                _Row('每年通勤費', '${_yearlyComm.toStringAsFixed(0)} 元'),
                const Divider(height: 16),
                _Row('租金 + 通勤費 / 月', '${_total.toStringAsFixed(0)} 元', hi: true),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String l, v;
  const _Stat(this.l, this.v);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            Text(l, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            const SizedBox(height: 2),
            Text(v,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ),
      );
}

class _Row extends StatelessWidget {
  final String l, v;
  final bool hi;
  const _Row(this.l, this.v, {this.hi = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(child: Text(l,
              style: TextStyle(fontWeight: hi ? FontWeight.bold : FontWeight.normal))),
          Text(v,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hi ? const Color(0xFF1565C0) : Colors.black87)),
        ]),
      );
}