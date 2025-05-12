import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartCard extends StatefulWidget {
  final bool isDarkMode;
  final double currentBalance;
  final Map<String, Map<String, double>> monthlyDataWithYear;

  const BarChartCard({
    required this.isDarkMode,
    required this.currentBalance,
    required this.monthlyDataWithYear, // Initialize this in constructor
  });

  @override
  _BarChartCardState createState() => _BarChartCardState();
}

class _BarChartCardState extends State<BarChartCard> {
  List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  int selectedYear = DateTime.now().year; // Year filter

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Create bar groups for each month from Jan to Dec
    List<BarChartGroupData> barGroups = List.generate(12, (index) {
      String monthKey = (index + 1).toString(); // Month key is "1" for January, "2" for February, etc.
      double value = 0;

      // Check if the selected year has data for the month
      if (widget.monthlyDataWithYear.containsKey(selectedYear.toString())) {
        final monthlyData = widget.monthlyDataWithYear[selectedYear.toString()]!;
        if (monthlyData.containsKey(monthKey)) {
          value = monthlyData[monthKey]!;
        }
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: value, color: Colors.blueAccent),
        ],
      );
    });

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isDarkMode
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildYearSelector(),
          Row(children: [
            Column(
              children: [
                Text("Current Balance",
                    style: TextStyle(color: Colors.white, fontSize: screenWidth*0.037)),
                SizedBox(height: 10),
                Text("₹ ${widget.currentBalance}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth*0.038,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(width: 30),
            Column(
              children: [
                Text("${monthNames[DateTime.now().month - 1]}. balance",
                    style: TextStyle(color: Colors.white, fontSize: screenWidth*0.037)),
                SizedBox(height: 10),
                Text("₹ ${widget.monthlyDataWithYear[DateTime.now().year.toString()]?[DateTime.now().month.toString()] ?? 0}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth*0.038,
                        fontWeight: FontWeight.bold)),
              ],
            )
          ]),
          SizedBox(height: 10),
          Container(
            height: screenHeight * 0.25,
            width: screenWidth * 0.7,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                  width: screenWidth, // Adjust width based on data
                  height: screenHeight * 1, // Adjust height based on data
                  child: BarChart(
                    BarChartData(
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Text(
                                  '${(value.toInt() / 1000).toStringAsFixed(1)}k',
                                  style: TextStyle(fontSize: 13),
                                ),
                              );
                            },
                            reservedSize: 40, // Reserve additional space for large numbers
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                monthNames[value.toInt()],
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    final currentYear = DateTime.now().year;
    return DropdownButton<int>(
      value: selectedYear,
      onChanged: (newYear) {
        if (newYear != null) {
          setState(() {
            selectedYear = newYear;
          });
        }
      },
      items: List.generate(5, (index) {
        int year = currentYear - index;
        return DropdownMenuItem(
          value: year,
          child: Text(year.toString()),
        );
      }),
    );
  }
}