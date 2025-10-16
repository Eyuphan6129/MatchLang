import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_data_provider.dart';

class StarScreen extends StatelessWidget {
  const StarScreen({super.key});

  Map<String, dynamic> getRankInfo(int stars) {
    switch (stars) {
      case 0:
        return {
          'name': 'Acemi',
          'icon': Icons.child_care,
          'color': Colors.grey.shade600,
        };
      case 1:
        return {
          'name': 'Çırak',
          'icon': Icons.construction,
          'color': Colors.brown.shade500,
        };
      case 2:
        return {
          'name': 'Kalfa',
          'icon': Icons.engineering,
          'color': Colors.blueGrey.shade500,
        };
      case 3:
        return {
          'name': 'Usta',
          'icon': Icons.school,
          'color': Colors.blue.shade800,
        };
      case 4:
        return {
          'name': 'Bilge',
          'icon': Icons.auto_stories,
          'color': Colors.deepPurple.shade600,
        };
      case 5:
        return {
          'name': 'Kaşif',
          'icon': Icons.explore,
          'color': Colors.teal.shade700,
        };
      case 6:
        return {
          'name': 'Fatih',
          'icon': Icons.flag,
          'color': Colors.red.shade800,
        };
      case 7:
        return {
          'name': 'Şampiyon',
          'icon': Icons.emoji_events,
          'color': Colors.amber.shade700,
        };
      case 8:
        return {
          'name': 'Üstat',
          'icon': Icons.star_half,
          'color': const Color(0xFFC0C0C0),
        };
      case 9:
        return {
          'name': 'Lord',
          'icon': Icons.security,
          'color': Colors.indigo.shade800,
        };
      case 10:
        return {
          'name': 'Efsane',
          'icon': Icons.workspace_premium,
          'color': const Color(0xFF212121),
        };
      default:
        return {
          'name': 'Efsane',
          'icon': Icons.workspace_premium,
          'color': const Color(0xFF212121),
        };
    }
  }

  Widget _buildStarRating(int starCount, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(10, (index) {
        return Icon(
          index < starCount ? Icons.star_rounded : Icons.star_border_rounded,
          color: index < starCount
              ? Colors.amber.shade600
              : Colors.grey.shade300,
          size: screenWidth * 0.065,
        );
      }),
    );
  }

  Widget _buildNextRankInfo(int currentStars, double screenWidth) {
    if (currentStars >= 10) {
      return Text(
        'Tüm rütbelere ulaştın. Sen bir Efsanesin!',
        style: GoogleFonts.poppins(
          fontSize: screenWidth * 0.04,
          color: Colors.grey.shade700,
        ),
        textAlign: TextAlign.center,
      );
    }
    final nextRankInfo = getRankInfo(currentStars + 1);
    final nextRankName = nextRankInfo['name'];
    return Text(
      'Sonraki Rütbe: $nextRankName (${currentStars + 1} Yıldız)',
      style: GoogleFonts.poppins(
        fontSize: screenWidth * 0.04,
        color: Colors.grey.shade700,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataProvider>();
    final rankInfo = getRankInfo(userData.stars);
    final rankName = rankInfo['name'] as String;
    final rankIcon = rankInfo['icon'] as IconData;
    final rankColor = rankInfo['color'] as Color;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Rütbeler',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 252, 170, 48),
              const Color.fromARGB(255, 254, 175, 175),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.07),
            child: Card(
              elevation: 8,
              shadowColor: Colors.grey.withAlpha(77),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.06),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.05,
                  horizontal: screenWidth * 0.04,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(rankIcon, color: rankColor, size: screenWidth * 0.2),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      rankName,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.09,
                        fontWeight: FontWeight.bold,
                        color: rankColor,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Toplam ${userData.stars} yıldıza ulaştın.',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.043,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildStarRating(userData.stars, screenWidth),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.04,
                      ),
                      child: const Divider(color: Colors.black12),
                    ),
                    _buildNextRankInfo(userData.stars, screenWidth),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
