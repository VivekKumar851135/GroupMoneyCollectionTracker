import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartContainer extends StatelessWidget {
  final List<double> data;

  BarChartContainer({required this.data, required bool isDarkMode});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: true
                  ? [
                      Color(0xFF33373B).withOpacity(0.9),
                      Color(0xFF232529).withOpacity(0.7)
                    ]
                  : [
                      Color(0xFFFFA07A).withOpacity(0.9),
                      Color(0xFFFFC0CB).withOpacity(0.7)
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: data.length * 50.0, // Adjust width based on data length
              height: screenHeight * 1, // Fixed height for the bar chart
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: data.reduce((a, b) => a > b ? a : b) +
                      10, // Dynamically calculate maxY
                  barGroups: data.asMap().entries.map((entry) {
                    int index = entry.key;
                    double value = entry.value;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          color: Colors.blueAccent,
                          width: 30, // Width of each bar
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameSize:
                          40, // Reserve space on the left for four-digit numbers
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Padding(
                            padding: EdgeInsets.only(
                                right: 8), // Optional padding for readability
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 13),
                            ),
                          );
                        },
                        reservedSize:
                            40, // Reserve additional space for large numbers
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '${value.toInt() + 1}',
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
