import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_data_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final correctAnswers = userData.todaysCorrectAnswers;
    final incorrectAnswers = userData.todaysIncorrectAnswers;
    final totalAnswers = correctAnswers + incorrectAnswers;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'İstatistiklerim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade800, Colors.cyan.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bugünkü Performansın',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.06,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  SizedBox(
                    height: screenWidth * 0.5,
                    width: screenWidth * 0.5,
                    child: totalAnswers == 0
                        ? _buildEmptyChart(screenWidth)
                        : _buildPieChart(
                            correctAnswers,
                            incorrectAnswers,
                            screenWidth,
                          ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  _buildStatRow(
                    Colors.green,
                    'Doğru Cevap',
                    correctAnswers,
                    screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildStatRow(
                    Colors.red,
                    'Yanlış Cevap',
                    incorrectAnswers,
                    screenWidth,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(int correct, int incorrect, double screenWidth) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.green.shade400,
            value: correct.toDouble(),
            title: '$correct',
            radius: screenWidth * 0.2,
            titleStyle: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.red.shade400,
            value: incorrect.toDouble(),
            title: '$incorrect',
            radius: screenWidth * 0.2,
            titleStyle: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: screenWidth * 0.1,
      ),
    );
  }

  Widget _buildEmptyChart(double screenWidth) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.grey.shade700,
            value: 1,
            title: '?',
            radius: screenWidth * 0.2,
            titleStyle: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        sectionsSpace: 0,
        centerSpaceRadius: screenWidth * 0.1,
      ),
    );
  }

  Widget _buildStatRow(
    Color color,
    String label,
    int value,
    double screenWidth,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: screenWidth * 0.04,
          height: screenWidth * 0.04,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: screenWidth * 0.03),
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.045,
            color: Colors.white70,
          ),
        ),
        const Spacer(),
        Text(
          '$value',
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.05,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
