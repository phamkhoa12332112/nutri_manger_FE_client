import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrients_manager/utils/sizes_manager.dart';

class CalorieStatsChart extends StatelessWidget {
  final List<double> caloriesData;
  final double dailyGoal;
  final DateTime fromDate;
  final DateTime toDate;

  const CalorieStatsChart({
    super.key,
    required this.caloriesData,
    required this.dailyGoal,
    required this.fromDate,
    required this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM');

    final dateLabels = List.generate(caloriesData.length, (index) {
      return dateFormat.format(fromDate.add(Duration(days: index)));
    });

    final maxCalories = caloriesData.reduce(
      (a, b) => a > b ? a : b,
    ); // max của dữ liệu
    final adjustedMaxY =
        (maxCalories > dailyGoal)
            ? maxCalories * 1.1
            : dailyGoal *
                1.2; // hoặc dùng logic riêng nếu muốn “mặc định” khi thấp

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: adjustedMaxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) {
                final rod = group.barRods.first;
                return rod.toY >= dailyGoal
                    ? Colors.green.shade100
                    : Colors.red.shade100;
              },
              fitInsideVertically: true,
              fitInsideHorizontally: true,
              tooltipPadding: EdgeInsets.all(PaddingSizes.p4),
              tooltipMargin: MarginSizes.m8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final isEnough = rod.toY < dailyGoal;
                final isOver = rod.toY > dailyGoal;
                return BarTooltipItem(
                  isEnough
                      ? 'Không đủ'
                      : isOver
                      ? 'Vượt quá'
                      : 'Hoàn hảo',
                  TextStyle(
                    color:
                        isEnough
                            ? Colors.red
                            : isOver
                            ? Colors.orange
                            : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),

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
                reservedSize: 48,
                interval:
                    (adjustedMaxY / 5)
                        .roundToDouble(), // chia thành khoảng 5 dòng
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= dateLabels.length) {
                    final maxCalories =
                        caloriesData.isNotEmpty
                            ? caloriesData.reduce((a, b) => a > b ? a : b)
                            : 0;
                    final adjustedMaxY =
                        (maxCalories > dailyGoal)
                            ? (maxCalories * 1.1)
                            : (dailyGoal * 1.2);

                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dateLabels[index],
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
                  color:
                      caloriesData[index] >= dailyGoal
                          ? Colors.green
                          : Colors.redAccent,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
