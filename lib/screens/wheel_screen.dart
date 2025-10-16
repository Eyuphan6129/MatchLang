import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../models/user_data_provider.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  final StreamController<int> _controller = StreamController<int>.broadcast();
  late final ConfettiController _confettiController;
  bool _isSpinning = false;

  final List<String> items = [
    "20 Coin",
    "100 Coin",
    "40 Coin",
    "PAS",
    "60 Coin",
    "80 Coin",
  ];

  final List<Color> _wheelColors = [
    Colors.blue.shade400,
    Colors.amber.shade600,
    Colors.pink.shade400,
    Colors.grey.shade600,
    Colors.teal.shade400,
    Colors.orange.shade600,
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  void _spinWheel() async {
    if (_isSpinning) return;

    final userData = context.read<UserDataProvider>();
    final now = DateTime.now();

    if (userData.lastWheelSpinTime != null &&
        now.difference(userData.lastWheelSpinTime!).inHours < 24) {
      final nextTime = userData.lastWheelSpinTime!.add(const Duration(days: 1));
      final remaining = nextTime.difference(now);
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Çarkı tekrar çevirmek için $hours saat $minutes dakika beklemelisin.",
          ),
        ),
      );
      return;
    }

    setState(() => _isSpinning = true);

    final randomIndex = Random().nextInt(items.length);
    _controller.add(randomIndex);

    Future.delayed(const Duration(seconds: 5), () async {
      final rewardString = items[randomIndex];

      if (rewardString != "PAS") {
        final coinValue =
            int.tryParse(rewardString.replaceAll(' Coin', '')) ?? 0;
        if (coinValue > 0) {
          await userData.updateCoins(userData.coins + coinValue);
          _confettiController.play();
        }
        _showRewardDialog(rewardString, coinValue);
      } else {
        _showRewardDialog(rewardString, 0);
      }
      await userData.updateLastWheelSpinTime(DateTime.now());

      setState(() => _isSpinning = false);
    });
  }

  void _showRewardDialog(String rewardText, int coinValue) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF2c2c4a),
        title: Center(
          child: Text(
            coinValue > 0 ? "Tebrikler!" : "Üzgünüz",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        content: Text(
          coinValue > 0
              ? "Kazandığın ödül: $rewardText"
              : "Bu sefer kazanamadın, tekrar dene!",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Tamam",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final wheelSize = min(screenWidth * 0.8, screenHeight * 0.45);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              "Şans Çarkı",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.orange,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange, Colors.grey],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      "Her gün ücretsiz çevir ve kazan!",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    SizedBox(
                      height: wheelSize,
                      width: wheelSize,
                      child: FortuneWheel(
                        selected: _controller.stream,
                        animateFirst: false,
                        physics: CircularPanPhysics(
                          duration: const Duration(seconds: 5),
                          curve: Curves.decelerate,
                        ),
                        indicators: const [
                          FortuneIndicator(
                            alignment: Alignment.topCenter,
                            child: TriangleIndicator(
                              color: Colors.amber,
                              width: 15,
                              height: 20,
                              elevation: 8,
                            ),
                          ),
                        ],
                        items: [
                          for (var i = 0; i < items.length; i++)
                            FortuneItem(
                              child: Text(
                                items[i],
                                style: GoogleFonts.poppins(
                                  fontSize: wheelSize * 0.06,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: FortuneItemStyle(
                                color: _wheelColors[i],
                                borderColor: Colors.black,
                                borderWidth: 2,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    ElevatedButton.icon(
                      onPressed: () {
                        final userData = context.read<UserDataProvider>();
                        final now = DateTime.now();
                        if (userData.lastWheelSpinTime == null ||
                            now
                                    .difference(userData.lastWheelSpinTime!)
                                    .inHours >=
                                24) {
                          _spinWheel();
                        }
                      },
                      icon: const Icon(
                        Icons.casino_outlined,
                        color: Colors.black87,
                      ),
                      label: Consumer<UserDataProvider>(
                        builder: (context, userData, child) {
                          final now = DateTime.now();
                          if (userData.lastWheelSpinTime != null &&
                              now
                                      .difference(userData.lastWheelSpinTime!)
                                      .inHours <
                                  24) {
                            final nextTime = userData.lastWheelSpinTime!.add(
                              const Duration(days: 1),
                            );
                            final remaining = nextTime.difference(now);
                            final hours = remaining.inHours;
                            final minutes = remaining.inMinutes % 60;
                            return Text(
                              "Tekrar $hours saat $minutes dakika sonra",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Text(
                              _isSpinning ? "Dönüyor..." : "ÇEVİR",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1,
                              ),
                            );
                          }
                        },
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        disabledBackgroundColor: Colors.grey.shade400,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.12,
                          vertical: screenHeight * 0.018,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
          emissionFrequency: 0.05,
          numberOfParticles: 20,
        ),
      ],
    );
  }
}
