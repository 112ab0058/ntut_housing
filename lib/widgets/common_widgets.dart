import 'package:flutter/material.dart';

class SliderRow extends StatelessWidget {
  final String label;
  final double value, min, max;
  final int divisions;
  final String valueText;
  final ValueChanged<double> onChanged;

  const SliderRow({
    super.key,
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          Row(children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            Text(valueText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
          Slider(
            value: value, min: min, max: max,
            divisions: divisions, label: valueText,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;

  const TagChip({super.key, required this.text, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor ?? const Color(0xFF1565C0),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const ScoreBar({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(width: 36, child: Text(label, style: const TextStyle(fontSize: 11))),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 7,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 30,
          child: Text(value.toStringAsFixed(0),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ),
      ]),
    );
  }
}