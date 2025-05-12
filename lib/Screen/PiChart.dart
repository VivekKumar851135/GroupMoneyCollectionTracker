import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PIChartContainer extends StatelessWidget {
  final Map<String, double> monthlyDataWithYear;

  final List<Color> pieChartColors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.yellowAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
    Colors.limeAccent,
    Colors.cyanAccent,
    Colors.indigoAccent,
    Colors.amberAccent,
    Colors.deepOrangeAccent,
    Colors.deepPurpleAccent,
    Colors.lightBlueAccent,
    Colors.lightGreenAccent,
    Colors.brown.shade400,
    Colors.grey.shade600,
    Colors.black,
    Colors.white,
    Colors.blueGrey,
  ];

  Color getColorByIndex(int index) {
    return pieChartColors[index % pieChartColors.length];
  }

  final List<String> months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

  PIChartContainer({super.key, required this.monthlyDataWithYear});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    int month=  DateTime.now().month;
    // Generate Pie Chart Sections and Legend Data
    final List<PieChartSectionData> sections = [];
    final List<Map<String, dynamic>> legendData = [];

    if (monthlyDataWithYear.isNotEmpty) {
      int index = 0;
      monthlyDataWithYear.forEach((user, amount) {
        final color = getColorByIndex(index);
        sections.add(PieChartSectionData(
          value: amount,
          color: color,
          title: amount.toStringAsFixed(1),
        ));
        legendData.add({"name": user, "color": color});
        index++;
      });
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2C2F33).withOpacity(0.9),
            const Color(0xFF1B1E21).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: monthlyDataWithYear.isEmpty
          ? Center(
              child: Text(
                "No data to show",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                 "${months[month-1]} Balance",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: screenWidth * 0.50, // Chart dimensions
                  width: screenHeight * 0.50,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      borderData: FlBorderData(show: false),
                      pieTouchData: PieTouchData(enabled: true),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Legend Section
                Column(
                  children: List.generate(
                    (legendData.length / 2).ceil(),
                    (index) {
                      int leftIndex = index * 2;
                      int rightIndex = leftIndex + 1;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left user
                          if (leftIndex < legendData.length)
                            _buildLegendItem(
                              legendData[leftIndex]['name'],
                              legendData[leftIndex]['color'],
                            ),
                          // Right user (if exists)
                          if (rightIndex < legendData.length)
                            _buildLegendItem(
                              legendData[rightIndex]['name'],
                              legendData[rightIndex]['color'],
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendItem(String name, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}