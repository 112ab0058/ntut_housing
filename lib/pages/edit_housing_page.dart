import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/housing.dart';
import '../providers/housing_state.dart';
import '../data/location_data.dart';
import '../widgets/common_widgets.dart';

class EditHousingPage extends StatefulWidget {
  final Housing? housing;
  const EditHousingPage({super.key, this.housing});

  @override
  State<EditHousingPage> createState() => _EditHousingPageState();
}

class _EditHousingPageState extends State<EditHousingPage> {
  late TextEditingController _nameCtrl;
  late String _city, _district, _station, _transport;
  late double _commuteMin, _fare, _rent, _size, _age, _floor;
  late bool _bath, _furn, _ac, _mrt;
  late double _safety, _life;

  @override
  void initState() {
    super.initState();
    final h = widget.housing;
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _city = h?.city ?? '台北市';
    _district = h?.district ?? '大安區';
    _station = h?.nearbyStation ?? stationsByDistrict['大安區']![0];
    _transport = h?.transportType ?? '步行';
    _commuteMin = h?.commuteMinutes ?? 10;
    _fare = h?.oneWayFare ?? 0;
    _rent = h?.rent ?? 8000;
    _size = h?.size ?? 6;
    _age = h?.age ?? 15;
    _floor = h?.floor ?? 3;
    _bath = h?.hasPrivateBath ?? false;
    _furn = h?.hasFurniture ?? false;
    _ac = h?.hasAC ?? false;
    _mrt = h?.nearMRT ?? false;
    _safety = h?.safetyScore ?? 70;
    _life = h?.lifeScore ?? 70;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  List<String> get _districts => districtsByCity[_city] ?? [];
  List<String> get _stations => stationsByDistrict[_district] ?? [];

  Housing get _preview => Housing(
        id: widget.housing?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameCtrl.text.isEmpty ? '未命名房源' : _nameCtrl.text,
        city: _city, district: _district, nearbyStation: _station,
        transportType: _transport, commuteMinutes: _commuteMin,
        oneWayFare: _fare, rent: _rent, size: _size, age: _age,
        floor: _floor, hasPrivateBath: _bath, hasFurniture: _furn,
        hasAC: _ac, nearMRT: _mrt, safetyScore: _safety, lifeScore: _life,
      );

  void _onCityChange(String? c) {
    if (c == null) return;
    final d = districtsByCity[c]![0];
    final s = stationsByDistrict[d]![0];
    setState(() { _city = c; _district = d; _station = s; });
  }

  void _onDistrictChange(String? d) {
    if (d == null) return;
    final s = stationsByDistrict[d]![0];
    setState(() { _district = d; _station = s; });
  }

  void _onTransportChange(String t) {
    setState(() {
      _transport = t;
      if (t == '步行' || t == '腳踏車') _fare = 0;
      else if (t == '公車') _fare = 15;
      else _fare = 25;
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = _preview;
    final state = context.read<HousingState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: Text(widget.housing == null ? '新增房源' : '編輯房源'),
        actions: [
          if (widget.housing != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('確認刪除'),
                  content: Text('要刪除「${widget.housing!.name}」嗎？'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        state.removeHousing(widget.housing!.id);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('刪除'),
                    ),
                  ],
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              widget.housing == null
                  ? state.addHousing(_preview)
                  : state.updateHousing(_preview);
              Navigator.pop(context);
            },
            child: const Text('儲存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 即時預覽 ─────────────────────────────────
            Card(
              color: h.recommendationColor.withOpacity(0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('即時 CP 值', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        Text(h.cpScore.toStringAsFixed(1),
                            style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold,
                                color: h.recommendationColor, height: 1.1)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                              color: h.recommendationColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(h.recommendation,
                              style: const TextStyle(color: Colors.white, fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(children: [
                        ScoreBar(label: '成本', value: h.costScore, color: const Color(0xFF1565C0)),
                        ScoreBar(label: '通勤', value: h.commuteScore, color: const Color(0xFF00796B)),
                        ScoreBar(label: '地段', value: h.districtConvenienceScore, color: const Color(0xFF7B1FA2)),
                        ScoreBar(label: '設備', value: h.equipmentScore, color: const Color(0xFFF57F17)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Mini(label: '月總成本', value: '${h.totalMonthlyCost.toStringAsFixed(0)}元'),
                        _Mini(label: '月通勤費', value: '${h.monthlyCommuteCost.toStringAsFixed(0)}元'),
                        _Mini(label: '每坪', value: '${h.pricePerPing.toStringAsFixed(0)}元'),
                        _Mini(label: '年通勤', value: '${h.yearlyCommuteHours.toStringAsFixed(0)}h'),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            // ── 基本資料 ─────────────────────────────────
            _section('基本資料', [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: '房源名稱', border: OutlineInputBorder(),
                    hintText: '例如：忠孝新生套房'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _city,
                    decoration: const InputDecoration(labelText: '縣市', border: OutlineInputBorder()),
                    items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: _onCityChange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _district,
                    decoration: const InputDecoration(labelText: '行政區', border: OutlineInputBorder()),
                    items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: _onDistrictChange,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _stations.contains(_station) ? _station : _stations.first,
                decoration: const InputDecoration(labelText: '附近捷運站', border: OutlineInputBorder()),
                items: _stations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _station = v ?? _station),
              ),
            ]),
            const SizedBox(height: 12),

            // ── 租屋條件 ─────────────────────────────────
            _section('租屋條件', [
              SliderRow(label: '月租金', value: _rent, min: 3000, max: 25000,
                  divisions: 220, valueText: '${_rent.toStringAsFixed(0)}元',
                  onChanged: (v) => setState(() => _rent = v)),
              SliderRow(label: '坪數', value: _size, min: 3, max: 20,
                  divisions: 17, valueText: '${_size.toStringAsFixed(0)}坪',
                  onChanged: (v) => setState(() => _size = v)),
              SliderRow(label: '屋齡', value: _age, min: 1, max: 50,
                  divisions: 49, valueText: '${_age.toStringAsFixed(0)}年',
                  onChanged: (v) => setState(() => _age = v)),
              SliderRow(label: '樓層', value: _floor, min: 1, max: 15,
                  divisions: 14, valueText: '${_floor.toStringAsFixed(0)}樓',
                  onChanged: (v) => setState(() => _floor = v)),
            ]),
            const SizedBox(height: 12),

            // ── 通勤條件 ─────────────────────────────────
            _section('通勤條件', [
              const Text('通勤方式', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 6,
                children: ['步行', '捷運', '公車', '腳踏車'].map((t) {
                  const icons = {
                    '步行': Icons.directions_walk,
                    '捷運': Icons.train,
                    '公車': Icons.directions_bus,
                    '腳踏車': Icons.directions_bike,
                  };
                  final sel = _transport == t;
                  return ChoiceChip(
                    label: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icons[t]!, size: 15, color: sel ? Colors.white : Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text(t, style: TextStyle(color: sel ? Colors.white : Colors.grey[700], fontSize: 13)),
                    ]),
                    selected: sel,
                    selectedColor: const Color(0xFF1565C0),
                    onSelected: (_) => _onTransportChange(t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 6),
              SliderRow(label: '單程通勤時間', value: _commuteMin, min: 1, max: 60,
                  divisions: 59, valueText: '${_commuteMin.toStringAsFixed(0)}分鐘',
                  onChanged: (v) => setState(() => _commuteMin = v)),
              if (_transport == '捷運' || _transport == '公車')
                SliderRow(label: '單程交通費', value: _fare, min: 0, max: 80,
                    divisions: 80, valueText: '${_fare.toStringAsFixed(0)}元',
                    onChanged: (v) => setState(() => _fare = v))
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 16),
                    const SizedBox(width: 6),
                    Text('$_transport 不需要交通費',
                        style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 13)),
                  ]),
                ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Mini(label: '月通勤費', value: '${_preview.monthlyCommuteCost.toStringAsFixed(0)}元'),
                    _Mini(label: '年通勤費', value: '${_preview.yearlyCommuteCost.toStringAsFixed(0)}元'),
                    _Mini(label: '年通勤時數', value: '${_preview.yearlyCommuteHours.toStringAsFixed(0)}h'),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),

            // ── 設備條件 ─────────────────────────────────
            _section('設備條件', [
              _Switch('獨立衛浴', '+35分', _bath, (v) => setState(() => _bath = v)),
              _Switch('附傢俱', '+25分', _furn, (v) => setState(() => _furn = v)),
              _Switch('附冷氣', '+25分', _ac, (v) => setState(() => _ac = v)),
              _Switch('近捷運 (步行5分內)', '+15分', _mrt, (v) => setState(() => _mrt = v)),
            ]),
            const SizedBox(height: 12),

            // ── 生活條件 ─────────────────────────────────
            _section('生活條件', [
              SliderRow(label: '安全性分數', value: _safety, min: 0, max: 100,
                  divisions: 100, valueText: '${_safety.toStringAsFixed(0)}分',
                  onChanged: (v) => setState(() => _safety = v)),
              SliderRow(label: '生活機能分數', value: _life, min: 0, max: 100,
                  divisions: 100, valueText: '${_life.toStringAsFixed(0)}分',
                  onChanged: (v) => setState(() => _life = v)),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            ...children,
          ]),
        ),
      );

  Widget _Switch(String label, String sub, bool val, ValueChanged<bool> cb) =>
      SwitchListTile(
        title: Text(label),
        subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
        value: val,
        onChanged: cb,
        contentPadding: EdgeInsets.zero,
        dense: true,
      );
}

class _Mini extends StatelessWidget {
  final String label, value;
  const _Mini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF1565C0))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ]);
}