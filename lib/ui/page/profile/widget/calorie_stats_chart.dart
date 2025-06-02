import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CalorieStatsChart extends StatelessWidget {
  final List<double> caloriesData;
  final double dailyGoal;

  const CalorieStatsChart({
    super.key,
    required this.caloriesData,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: dailyGoal * 1.5,
            barTouchData: BarTouchData(enabled: false),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide(color: Colors.black12),
                bottom: BorderSide(color: Colors.black12),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40, // ➜ Đặt đủ để text không bị đè
                  interval: 500,
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[value.toInt()],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(caloriesData.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: caloriesData[index],
                    color: caloriesData[index] >= dailyGoal ? Colors.green : Colors.redAccent,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
          )
      ),
    );
  }
}
