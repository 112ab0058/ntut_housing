import 'package:flutter/material.dart';
import '../data/location_data.dart';

class Housing {
  final String id;
  String name;
  String city;
  String district;
  String nearbyStation;
  String transportType; // 步行 捷運 公車 腳踏車
  double commuteMinutes;
  double oneWayFare;
  double rent;
  double size;
  double age;
  double floor;
  bool hasPrivateBath;
  bool hasFurniture;
  bool hasAC;
  bool nearMRT;
  double safetyScore;
  double lifeScore;

  Housing({
    required this.id,
    required this.name,
    required this.city,
    required this.district,
    required this.nearbyStation,
    required this.transportType,
    required this.commuteMinutes,
    required this.oneWayFare,
    required this.rent,
    required this.size,
    required this.age,
    required this.floor,
    required this.hasPrivateBath,
    required this.hasFurniture,
    required this.hasAC,
    required this.nearMRT,
    required this.safetyScore,
    required this.lifeScore,
  });

  // ── 基本 ──────────────────────────────────────────
  double get pricePerPing => rent / size;

  // ── 通勤成本 ──────────────────────────────────────
  double get dailyCommuteCost => oneWayFare * 2;
  double get monthlyCommuteCost => oneWayFare * 2 * 22;
  double get yearlyCommuteCost => monthlyCommuteCost * 12;
  double get totalMonthlyCost => rent + monthlyCommuteCost;
  double get yearlyCommuteHours => commuteMinutes * 2 * 22 * 12 / 60;

  // ── Feature Scores (0–100) ────────────────────────
  double get costScore =>
      (100 - (totalMonthlyCost - 5000) / 250).clamp(0, 100);

  double get commuteScore =>
      (100 - commuteMinutes * 100 / 60).clamp(0, 100);

  double get districtConvenienceScore =>
      (districtScores[district] ?? 60).toDouble();

  double get spaceScore =>
      ((size - 3) / 17 * 100).clamp(0, 100);

  double get equipmentScore {
    double s = 0;
    if (hasPrivateBath) s += 35;
    if (hasFurniture) s += 25;
    if (hasAC) s += 25;
    if (nearMRT) s += 15;
    return s.clamp(0, 100);
  }

  double get safetyLifeScore =>
      ((safetyScore + lifeScore) / 2).clamp(0, 100);

  // ── CP 值：加權預測 ───────────────────────────────
  // CP = costScore×0.30 + commuteScore×0.25 + districtScore×0.15
  //    + spaceScore×0.10 + equipmentScore×0.10 + safetyLifeScore×0.10
  double get cpScore => (costScore * 0.30 +
          commuteScore * 0.25 +
          districtConvenienceScore * 0.15 +
          spaceScore * 0.10 +
          equipmentScore * 0.10 +
          safetyLifeScore * 0.10)
      .clamp(0, 100);

  // ── 推薦標籤 ──────────────────────────────────────
  String get recommendation {
    if (cpScore >= 75) return '強烈推薦';
    if (cpScore >= 60) return '值得考慮';
    if (cpScore >= 45) return '普通';
    return '不推薦';
  }

  Color get recommendationColor {
    if (cpScore >= 75) return const Color(0xFF2E7D32);
    if (cpScore >= 60) return const Color(0xFF1565C0);
    if (cpScore >= 45) return const Color(0xFFF57F17);
    return Colors.redAccent;
  }

  // ── 優缺點 ────────────────────────────────────────
  List<String> get strengths {
    final s = <String>[];
    if (commuteMinutes <= 12) s.add('近距離通勤');
    if (oneWayFare == 0) s.add('通勤零費用');
    if (oneWayFare > 0 && monthlyCommuteCost < 700) s.add('通勤低成本');
    if (hasPrivateBath) s.add('獨立衛浴');
    if (hasFurniture) s.add('附傢俱');
    if (hasAC) s.add('附冷氣');
    if (nearMRT) s.add('近捷運');
    if (districtConvenienceScore >= 85) s.add('優質地段');
    if (size >= 10) s.add('空間寬敞');
    if (totalMonthlyCost < 10000) s.add('總成本低');
    return s.take(4).toList();
  }

  List<String> get weaknesses {
    final w = <String>[];
    if (commuteMinutes > 25) w.add('通勤較遠');
    if (monthlyCommuteCost > 1200) w.add('交通費高');
    if (!hasPrivateBath) w.add('無獨立衛浴');
    if (!hasAC) w.add('無冷氣');
    if (age > 30) w.add('屋齡較老');
    if (size < 5) w.add('空間較小');
    if (rent > 14000) w.add('租金偏高');
    if (districtConvenienceScore < 65) w.add('地段偏遠');
    return w.take(3).toList();
  }

  // ── 工具 ──────────────────────────────────────────
  IconData get transportIcon {
    switch (transportType) {
      case '捷運':
        return Icons.train;
      case '公車':
        return Icons.directions_bus;
      case '腳踏車':
        return Icons.directions_bike;
      default:
        return Icons.directions_walk;
    }
  }
}