import 'package:flutter/material.dart';

class ModelExplanationPage extends StatelessWidget {
  const ModelExplanationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('模型說明'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _IntroCard(),
          SizedBox(height: 14),
          _FeatureCard(),
          SizedBox(height: 14),
          _WeightCard(),
          SizedBox(height: 14),
          _FormulaCard(),
          SizedBox(height: 14),
          _CommuteCard(),
          SizedBox(height: 14),
          _DistrictCard(),
          SizedBox(height: 14),
          _ConclusionCard(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.school,
      title: '專題目標',
      children: [
        const Text(
          '本 App 是針對北科學生設計的租屋推薦系統。使用者可以新增多筆房源，系統會根據租金、通勤、地點、坪數、設備、安全性與生活機能等條件，計算每間房源的 CP 值，並推薦最適合的租屋選項。',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 10),
        _Bullet('Feature：房源的各項條件，例如租金、通勤時間、坪數'),
        _Bullet('Weight：不同條件的重要程度，例如成本佔 30%'),
        _Bullet('Prediction：系統預測這間房是否適合北科學生'),
        _Bullet('Recommendation：依照 CP 值排序並給出推薦結果'),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.tune,
      title: '使用的 Features',
      children: [
        _FeatureRow('月租金', '房源本身的租金成本'),
        _FeatureRow('通勤時間', '從房源到北科的單程時間'),
        _FeatureRow('通勤費用', '捷運、公車等交通成本'),
        _FeatureRow('行政區', '以北科學生角度設定區域便利性分數'),
        _FeatureRow('坪數', '居住空間大小'),
        _FeatureRow('設備', '獨立衛浴、傢俱、冷氣、近捷運'),
        _FeatureRow('安全性', '使用者自行評估周邊安全程度'),
        _FeatureRow('生活機能', '飲食、超商、交通、日常機能便利度'),
      ],
    );
  }
}

class _WeightCard extends StatelessWidget {
  const _WeightCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.pie_chart,
      title: 'CP 值權重設定',
      children: [
        const Text(
          '本專題採用自設加權模型，將每個 feature 轉換成 0 到 100 分的子分數，再依照權重加總成最終 CP 值。',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 12),
        _WeightBar(label: '實際總成本分數', weight: 0.30, text: '30%'),
        _WeightBar(label: '通勤分數', weight: 0.25, text: '25%'),
        _WeightBar(label: '行政區便利性分數', weight: 0.15, text: '15%'),
        _WeightBar(label: '空間分數', weight: 0.10, text: '10%'),
        _WeightBar(label: '設備分數', weight: 0.10, text: '10%'),
        _WeightBar(label: '安全與生活機能分數', weight: 0.10, text: '10%'),
      ],
    );
  }
}

class _FormulaCard extends StatelessWidget {
  const _FormulaCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.functions,
      title: 'CP 值計算公式',
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'CP 值 =\n'
            '實際總成本分數 × 0.30\n'
            '+ 通勤分數 × 0.25\n'
            '+ 行政區便利性分數 × 0.15\n'
            '+ 空間分數 × 0.10\n'
            '+ 設備分數 × 0.10\n'
            '+ 安全生活分數 × 0.10',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              height: 1.6,
              color: Color(0xFF0D47A1),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Bullet('成本越低，實際總成本分數越高'),
        _Bullet('通勤時間越短，通勤分數越高'),
        _Bullet('越靠近北科且交通方便的行政區，便利性分數越高'),
        _Bullet('設備越完整，設備分數越高'),
        _Bullet('最後將所有子分數加權，得到最終推薦 CP 值'),
      ],
    );
  }
}

class _CommuteCard extends StatelessWidget {
  const _CommuteCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.directions_transit,
      title: '通勤成本計算',
      children: [
        const Text(
          '租屋不能只看月租金，對學生來說，通勤費與通勤時間也會影響實際負擔。因此本 App 將通勤成本納入房源評分。',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 12),
        _FormulaLine('每日通勤費', '單程交通費 × 2'),
        _FormulaLine('每月通勤費', '單程交通費 × 2 × 22 天'),
        _FormulaLine('每年通勤費', '每月通勤費 × 12'),
        _FormulaLine('每月實際總成本', '月租金 + 每月通勤費'),
        _FormulaLine('每年通勤時數', '單程通勤時間 × 2 × 22 × 12 ÷ 60'),
        const SizedBox(height: 8),
        _Bullet('步行與腳踏車：交通費為 0 元'),
        _Bullet('公車：預設單程 15 元，可手動調整'),
        _Bullet('捷運：預設單程 25 元，可手動調整'),
      ],
    );
  }
}

class _DistrictCard extends StatelessWidget {
  const _DistrictCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.location_city,
      title: '行政區便利性分數',
      children: [
        const Text(
          '行政區便利性分數是本專題自設的假設分數，用來模擬北科學生租屋時對地點的偏好。此分數不是官方資料，也不代表真實房價排名，而是為了展示 feature weighting 的概念。',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 12),
        _DistrictScore('大安區', '95', '距離北科近，忠孝新生、忠孝復興生活機能強'),
        _DistrictScore('中正區', '92', '善導寺、台北車站附近，通勤方便'),
        _DistrictScore('中山區', '88', '松江南京、南京復興交通便利'),
        _DistrictScore('松山區', '82', '捷運可達，但距離略遠'),
        _DistrictScore('三重區', '74', '租金可能較低，台北橋通勤可接受'),
        _DistrictScore('永和區 / 中和區', '72 / 70', '租金較有彈性，但通勤時間增加'),
        _DistrictScore('板橋區 / 新莊區 / 汐止區', '62 / 58 / 52', '距離較遠，適合預算優先者'),
      ],
    );
  }
}

class _ConclusionCard extends StatelessWidget {
  const _ConclusionCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.lightbulb,
      title: '結果解讀',
      children: [
        const Text(
          '本 App 的推薦結果不是單純找最便宜的房子，而是綜合考慮「花費、時間、地點、空間、設備與生活品質」。因此 CP 值最高的房源，代表它在目前設定的權重下，最符合北科學生的整體需求。',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 10),
        _Bullet('強烈推薦：整體條件最佳，適合作為優先選擇'),
        _Bullet('值得考慮：條件不錯，但可能有部分缺點'),
        _Bullet('普通：可列入備選，但不是最佳解'),
        _Bullet('不推薦：成本、通勤或設備條件較不理想'),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFFE3F2FD),
                  child: Icon(icon, color: const Color(0xFF1565C0), size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  final String desc;

  const _FeatureRow(this.label, this.desc);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(desc, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _WeightBar extends StatelessWidget {
  final String label;
  final double weight;
  final String text;

  const _WeightBar({
    required this.label,
    required this.weight,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: weight,
              minHeight: 9,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              text,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaLine extends StatelessWidget {
  final String label;
  final String formula;

  const _FormulaLine(this.label, this.formula);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              formula,
              style: const TextStyle(color: Color(0xFF1565C0)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistrictScore extends StatelessWidget {
  final String district;
  final String score;
  final String reason;

  const _DistrictScore(this.district, this.score, this.reason);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              district,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 42,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              score,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(reason, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}