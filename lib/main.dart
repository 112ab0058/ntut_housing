import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/housing_state.dart';
import 'pages/housing_list_page.dart';
import 'pages/compare_page.dart';
import 'pages/commute_page.dart';
import 'pages/model_explanation_page.dart';
void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HousingState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '北科學生租屋推薦',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        ),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();
  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _idx,
        children: const [HousingListPage(), ComparePage(), CommutePage(),ModelExplanationPage(),],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: '房源'),
          NavigationDestination(
              icon: Icon(Icons.compare_outlined),
              selectedIcon: Icon(Icons.compare),
              label: '比較'),
          NavigationDestination(
              icon: Icon(Icons.directions_transit_outlined),
              selectedIcon: Icon(Icons.directions_transit),
              label: '通勤'),
              NavigationDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info),
                  label: '說明'),
        ],
      ),
    );
  }
}