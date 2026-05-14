import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HousingState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '北科租屋分析',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        ),
        home: const MainPage(),
      ),
    );
  }
}

class Housing {
  final String id;
  String name;
  double rent;
  double size;
  double age;
  double walkMinutes;
  double floor;
  bool hasPrivateBath;
  bool hasFurniture;
  bool hasAC;
  bool nearMRT;

  Housing({
    required this.id,
    required this.name,
    required this.rent,
    required this.size,
    required this.age,
    required this.walkMinutes,
    required this.floor,
    required this.hasPrivateBath,
    required this.hasFurniture,
    required this.hasAC,
    required this.nearMRT,
  });

  double get pricePerPing => rent / size;

  double get cpScore {
    double score = 100;
    score -= (rent - 5000) / 500;
    score += (size - 5) * 2;
    score -= age * 0.5;
    score -= walkMinutes * 1.5;
    score += floor * 0.3;
    if (hasPrivateBath) score += 10;
    if (hasFurniture) score += 8;
    if (hasAC) score += 6;
    if (nearMRT) score += 12;
    return score.clamp(0, 100);
  }

  String get recommendation {
    if (cpScore >= 75) return '強烈推薦';
    if (cpScore >= 55) return '值得考慮';
    if (cpScore >= 35) return '普通';
    return '不推薦';
  }

  Color get recommendationColor {
    if (cpScore >= 75) return const Color(0xFF2E7D32);
    if (cpScore >= 55) return const Color(0xFF1565C0);
    if (cpScore >= 35) return const Color(0xFFF57F17);
    return Colors.redAccent;
  }

  double get comfortScore {
    double s = 50;
    if (hasPrivateBath) s += 20;
    if (hasFurniture) s += 15;
    if (hasAC) s += 15;
    return s.clamp(0, 100);
  }

  double get locationScore {
    double s = 100 - walkMinutes * 2.5;
    if (nearMRT) s += 20;
    return s.clamp(0, 100);
  }

  double get valueScore {
    double s = 100 - (pricePerPing - 800) / 20;
    return s.clamp(0, 100);
  }
}

class HousingState extends ChangeNotifier {
  final List<Housing> _housings = [
    Housing(
      id: '1',
      name: '松山區套房',
      rent: 10000,
      size: 8,
      age: 15,
      walkMinutes: 10,
      floor: 3,
      hasPrivateBath: true,
      hasFurniture: true,
      hasAC: true,
      nearMRT: true,
    ),
    Housing(
      id: '2',
      name: '大安區雅房',
      rent: 7500,
      size: 5,
      age: 25,
      walkMinutes: 20,
      floor: 2,
      hasPrivateBath: false,
      hasFurniture: true,
      hasAC: false,
      nearMRT: false,
    ),
  ];

  List<Housing> get housings => List.unmodifiable(_housings);

  void addHousing(Housing h) {
    _housings.add(h);
    notifyListeners();
  }

  void updateHousing(Housing h) {
    final i = _housings.indexWhere((x) => x.id == h.id);
    if (i != -1) {
      _housings[i] = h;
      notifyListeners();
    }
  }

  void removeHousing(String id) {
    _housings.removeWhere((x) => x.id == id);
    notifyListeners();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HousingListPage(),
    ComparePage(),
    CommutePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '房源'),
          NavigationDestination(icon: Icon(Icons.compare), label: '比較'),
          NavigationDestination(icon: Icon(Icons.directions_transit), label: '通勤'),
        ],
      ),
    );
  }
}

class HousingListPage extends StatelessWidget {
  const HousingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HousingState>();
    final housings = state.housings;
    final sorted = [...housings]..sort((a, b) => b.cpScore.compareTo(a.cpScore));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('北科租屋分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {},
          ),
        ],
      ),
      body: housings.isEmpty
          ? const Center(child: Text('還沒有房源，點右下角 + 新增'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, i) {
                final h = sorted[i];
                return _HousingCard(housing: h, rank: i + 1);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditHousingPage()),
          );
        },
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditHousingPage(housing: h)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: rank == 1
                          ? const Color(0xFFFFD700)
                          : rank == 2
                              ? const Color(0xFFB0BEC5)
                              : rank == 3
                                  ? const Color(0xFFBF8970)
                                  : const Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rank <= 3 ? Colors.white : const Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      h.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: h.recommendationColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      h.recommendation,
                      style: TextStyle(color: h.recommendationColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoTag(icon: Icons.attach_money, text: '${h.rent.toStringAsFixed(0)}元'),
                  _InfoTag(icon: Icons.square_foot, text: '${h.size.toStringAsFixed(0)}坪'),
                  _InfoTag(icon: Icons.directions_walk, text: '${h.walkMinutes.toStringAsFixed(0)}分鐘'),
                  if (h.nearMRT) _InfoTag(icon: Icons.train, text: '近捷運'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CP值', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: h.cpScore / 100,
                          backgroundColor: Colors.grey[200],
                          color: h.recommendationColor,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    h.cpScore.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: h.recommendationColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('每坪 ${h.pricePerPing.toStringAsFixed(0)}元', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const Spacer(),
                  if (h.hasPrivateBath) const _Chip(text: '獨衛'),
                  if (h.hasFurniture) const _Chip(text: '有傢俱'),
                  if (h.hasAC) const _Chip(text: '有冷氣'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 2),
          Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF1565C0))),
    );
  }
}

class EditHousingPage extends StatefulWidget {
  final Housing? housing;
  const EditHousingPage({super.key, this.housing});

  @override
  State<EditHousingPage> createState() => _EditHousingPageState();
}

class _EditHousingPageState extends State<EditHousingPage> {
  late TextEditingController _nameController;
  late double _rent;
  late double _size;
  late double _age;
  late double _walkMinutes;
  late double _floor;
  late bool _hasPrivateBath;
  late bool _hasFurniture;
  late bool _hasAC;
  late bool _nearMRT;

  @override
  void initState() {
    super.initState();
    final h = widget.housing;
    _nameController = TextEditingController(text: h?.name ?? '');
    _rent = h?.rent ?? 8000;
    _size = h?.size ?? 6;
    _age = h?.age ?? 15;
    _walkMinutes = h?.walkMinutes ?? 10;
    _floor = h?.floor ?? 3;
    _hasPrivateBath = h?.hasPrivateBath ?? false;
    _hasFurniture = h?.hasFurniture ?? false;
    _hasAC = h?.hasAC ?? false;
    _nearMRT = h?.nearMRT ?? false;
  }

  Housing get _currentHousing => Housing(
        id: widget.housing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.isEmpty ? '未命名房源' : _nameController.text,
        rent: _rent,
        size: _size,
        age: _age,
        walkMinutes: _walkMinutes,
        floor: _floor,
        hasPrivateBath: _hasPrivateBath,
        hasFurniture: _hasFurniture,
        hasAC: _hasAC,
        nearMRT: _nearMRT,
      );

  @override
  Widget build(BuildContext context) {
    final h = _currentHousing;
    final state = context.read<HousingState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: Text(widget.housing == null ? '新增房源' : '編輯房源'),
        actions: [
          if (widget.housing != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                state.removeHousing(widget.housing!.id);
                Navigator.pop(context);
              },
            ),
          TextButton(
            onPressed: () {
              if (widget.housing == null) {
                state.addHousing(_currentHousing);
              } else {
                state.updateHousing(_currentHousing);
              }
              Navigator.pop(context);
            },
            child: const Text('儲存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: h.recommendationColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('即時 CP 值', style: TextStyle(color: Colors.grey[600])),
                          Text(
                            h.cpScore.toStringAsFixed(1),
                            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: h.recommendationColor),
                          ),
                          Text(h.recommendation, style: TextStyle(color: h.recommendationColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('每坪 ${h.pricePerPing.toStringAsFixed(0)}元', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('舒適度 ${h.comfortScore.toStringAsFixed(0)}分'),
                        Text('位置 ${h.locationScore.toStringAsFixed(0)}分'),
                        Text('價值 ${h.valueScore.toStringAsFixed(0)}分'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('房源名稱', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: '例如：忠孝復興套房',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('基本條件', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _SliderRow(
                      label: '月租金',
                      value: _rent,
                      min: 3000,
                      max: 25000,
                      divisions: 220,
                      valueText: '${_rent.toStringAsFixed(0)}元',
                      onChanged: (v) => setState(() => _rent = v),
                    ),
                    _SliderRow(
                      label: '坪數',
                      value: _size,
                      min: 3,
                      max: 20,
                      divisions: 17,
                      valueText: '${_size.toStringAsFixed(0)}坪',
                      onChanged: (v) => setState(() => _size = v),
                    ),
                    _SliderRow(
                      label: '屋齡',
                      value: _age,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      valueText: '${_age.toStringAsFixed(0)}年',
                      onChanged: (v) => setState(() => _age = v),
                    ),
                    _SliderRow(
                      label: '距北科步行',
                      value: _walkMinutes,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      valueText: '${_walkMinutes.toStringAsFixed(0)}分鐘',
                      onChanged: (v) => setState(() => _walkMinutes = v),
                    ),
                    _SliderRow(
                      label: '樓層',
                      value: _floor,
                      min: 1,
                      max: 15,
                      divisions: 14,
                      valueText: '${_floor.toStringAsFixed(0)}樓',
                      onChanged: (v) => setState(() => _floor = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('設備條件', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SwitchListTile(
                      title: const Text('獨立衛浴'),
                      value: _hasPrivateBath,
                      onChanged: (v) => setState(() => _hasPrivateBath = v),
                    ),
                    SwitchListTile(
                      title: const Text('附傢俱'),
                      value: _hasFurniture,
                      onChanged: (v) => setState(() => _hasFurniture = v),
                    ),
                    SwitchListTile(
                      title: const Text('附冷氣'),
                      value: _hasAC,
                      onChanged: (v) => setState(() => _hasAC = v),
                    ),
                    SwitchListTile(
                      title: const Text('近捷運（步行5分鐘內）'),
                      value: _nearMRT,
                      onChanged: (v) => setState(() => _nearMRT = v),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueText;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text(valueText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(value: value, min: min, max: max, divisions: divisions, label: valueText, onChanged: onChanged),
        ],
      ),
    );
  }
}

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});
  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final housings = context.watch<HousingState>().housings;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('房源比較'),
      ),
      body: housings.isEmpty
          ? const Center(child: Text('請先在房源頁新增房源'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: const Text('選擇最多3間房源進行比較', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: housings.length,
                    itemBuilder: (context, i) {
                      final h = housings[i];
                      final selected = _selected.contains(h.id);
                      return Card(
                        color: selected ? const Color(0xFFE3F2FD) : null,
                        child: CheckboxListTile(
                          title: Text(h.name),
                          subtitle: Text('CP值 ${h.cpScore.toStringAsFixed(1)} ・ ${h.rent.toStringAsFixed(0)}元'),
                          value: selected,
                          onChanged: (v) {
                            setState(() {
                              if (v == true && _selected.length < 3) {
                                _selected.add(h.id);
                              } else {
                                _selected.remove(h.id);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (_selected.length >= 2)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton.icon(
                      onPressed: () {
                        final selected = housings.where((h) => _selected.contains(h.id)).toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CompareDetailPage(housings: selected)),
                        );
                      },
                      icon: const Icon(Icons.compare_arrows),
                      label: Text('比較 ${_selected.length} 間房源'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    ),
                  ),
              ],
            ),
    );
  }
}

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color(0xFF1565C0),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('推薦選擇', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(best.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('CP值 ${best.cpScore.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('各項比較', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _CompareRow(label: 'CP值', housings: housings, getValue: (h) => h.cpScore, higherBetter: true),
                    _CompareRow(label: '月租金', housings: housings, getValue: (h) => h.rent, higherBetter: false),
                    _CompareRow(label: '坪數', housings: housings, getValue: (h) => h.size, higherBetter: true),
                    _CompareRow(label: '每坪租金', housings: housings, getValue: (h) => h.pricePerPing, higherBetter: false),
                    _CompareRow(label: '距北科(分鐘)', housings: housings, getValue: (h) => h.walkMinutes, higherBetter: false),
                    _CompareRow(label: '舒適度', housings: housings, getValue: (h) => h.comfortScore, higherBetter: true),
                    _CompareRow(label: '位置分數', housings: housings, getValue: (h) => h.locationScore, higherBetter: true),
                    _CompareRow(label: '價值分數', housings: housings, getValue: (h) => h.valueScore, higherBetter: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('設備比較', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const SizedBox(width: 80),
                        ...housings.map((h) => Expanded(
                              child: Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
                            )),
                      ],
                    ),
                    const Divider(),
                    _EquipRow(label: '獨立衛浴', housings: housings, getValue: (h) => h.hasPrivateBath),
                    _EquipRow(label: '附傢俱', housings: housings, getValue: (h) => h.hasFurniture),
                    _EquipRow(label: '附冷氣', housings: housings, getValue: (h) => h.hasAC),
                    _EquipRow(label: '近捷運', housings: housings, getValue: (h) => h.nearMRT),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final List<Housing> housings;
  final double Function(Housing) getValue;
  final bool higherBetter;

  const _CompareRow({required this.label, required this.housings, required this.getValue, required this.higherBetter});

  @override
  Widget build(BuildContext context) {
    final values = housings.map(getValue).toList();
    final best = higherBetter ? values.reduce(max) : values.reduce(min);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
          ...housings.asMap().entries.map((e) {
            final v = getValue(e.value);
            final isBest = v == best;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isBest ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: isBest ? Border.all(color: const Color(0xFF2E7D32)) : null,
                ),
                child: Text(
                  v.toStringAsFixed(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                    color: isBest ? const Color(0xFF2E7D32) : Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EquipRow extends StatelessWidget {
  final String label;
  final List<Housing> housings;
  final bool Function(Housing) getValue;

  const _EquipRow({required this.label, required this.housings, required this.getValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
          ...housings.map((h) => Expanded(
                child: Icon(
                  getValue(h) ? Icons.check_circle : Icons.cancel,
                  color: getValue(h) ? const Color(0xFF2E7D32) : Colors.grey[400],
                  size: 20,
                ),
              )),
        ],
      ),
    );
  }
}

class CommutePage extends StatefulWidget {
  const CommutePage({super.key});
  @override
  State<CommutePage> createState() => _CommutePageState();
}

class _CommutePageState extends State<CommutePage> {
  double _walkMinutes = 10;
  double _monthlyRent = 8000;
  String _transport = '步行';
  double _mrtFare = 25;

  double get _dailyCommuteCost {
    if (_transport == '步行') return 0;
    if (_transport == '捷運') return _mrtFare * 2;
    return 30 * 2;
  }

  double get _monthlyCommuteCost => _dailyCommuteCost * 22;
  double get _totalMonthlyCost => _monthlyRent + _monthlyCommuteCost;
  double get _yearlyCommuteCost => _monthlyCommuteCost * 12;
  double get _monthlyCommuteMinutes => _walkMinutes * 2 * 22;
  double get _yearlyCommuteHours => _monthlyCommuteMinutes * 12 / 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('通勤成本計算'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color(0xFF1565C0),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('每月總花費', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '${_totalMonthlyCost.toStringAsFixed(0)}元',
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _StatCard(label: '通勤費/月', value: '${_monthlyCommuteCost.toStringAsFixed(0)}元')),
                        const SizedBox(width: 8),
                        Expanded(child: _StatCard(label: '通勤費/年', value: '${_yearlyCommuteCost.toStringAsFixed(0)}元')),
                        const SizedBox(width: 8),
                        Expanded(child: _StatCard(label: '通勤時數/年', value: '${_yearlyCommuteHours.toStringAsFixed(0)}小時')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('設定條件', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _SliderRow(
                      label: '距北科步行時間',
                      value: _walkMinutes,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      valueText: '${_walkMinutes.toStringAsFixed(0)}分鐘',
                      onChanged: (v) => setState(() => _walkMinutes = v),
                    ),
                    _SliderRow(
                      label: '月租金',
                      value: _monthlyRent,
                      min: 3000,
                      max: 25000,
                      divisions: 220,
                      valueText: '${_monthlyRent.toStringAsFixed(0)}元',
                      onChanged: (v) => setState(() => _monthlyRent = v),
                    ),
                    const SizedBox(height: 8),
                    const Text('交通方式', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: '步行', label: Text('步行'), icon: Icon(Icons.directions_walk)),
                        ButtonSegment(value: '捷運', label: Text('捷運'), icon: Icon(Icons.train)),
                        ButtonSegment(value: '公車', label: Text('公車'), icon: Icon(Icons.directions_bus)),
                      ],
                      selected: {_transport},
                      onSelectionChanged: (s) => setState(() => _transport = s.first),
                    ),
                    if (_transport == '捷運') ...[
                      const SizedBox(height: 16),
                      _SliderRow(
                        label: '單程捷運票價',
                        value: _mrtFare,
                        min: 20,
                        max: 65,
                        divisions: 45,
                        valueText: '${_mrtFare.toStringAsFixed(0)}元',
                        onChanged: (v) => setState(() => _mrtFare = v),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('通勤分析', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _AnalysisRow(
                      label: '每日通勤時間',
                      value: '${(_walkMinutes * 2).toStringAsFixed(0)}分鐘',
                    ),
                    _AnalysisRow(
                      label: '每月通勤時間',
                      value: '${_monthlyCommuteMinutes.toStringAsFixed(0)}分鐘',
                    ),
                    _AnalysisRow(
                      label: '每年通勤時間',
                      value: '${_yearlyCommuteHours.toStringAsFixed(1)}小時',
                    ),
                    _AnalysisRow(
                      label: '每月通勤費用',
                      value: '${_monthlyCommuteCost.toStringAsFixed(0)}元',
                    ),
                    _AnalysisRow(
                      label: '租金＋通勤總計',
                      value: '${_totalMonthlyCost.toStringAsFixed(0)}元/月',
                      highlight: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _AnalysisRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: highlight ? FontWeight.bold : FontWeight.normal))),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: highlight ? const Color(0xFF1565C0) : Colors.black87)),
        ],
      ),
    );
  }
}
