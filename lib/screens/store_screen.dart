import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data_provider.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  DateTime? _nextGiftTime;

  @override
  void initState() {
    super.initState();
    _initializeGiftTimer();
  }

  void _initializeGiftTimer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userData = context.read<UserDataProvider>();
      if (userData.dailyGiftTaken && userData.lastDailyGiftTime != null) {
        _nextGiftTime = userData.lastDailyGiftTime!.add(
          const Duration(hours: 24),
        );
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      if (_nextGiftTime != null) {
        final diff = _nextGiftTime!.difference(DateTime.now());
        if (diff.isNegative) {
          setState(() {
            _remainingTime = Duration.zero;
            context.read<UserDataProvider>().updateDailyGiftTaken(false);
            _timer?.cancel();
          });
        } else {
          setState(() {
            _remainingTime = diff;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mağaza'),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 22, 45, 251),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 14, 23, 116),
                  Color.fromARGB(255, 22, 45, 251),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderStats(userData, screenWidth),
                SizedBox(height: screenHeight * 0.05),
                _buildSectionHeader(
                  title: 'GÜNLÜK FIRSAT',
                  screenWidth: screenWidth,
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildDailyGiftCard(userData, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.04),
                _buildSectionHeader(
                  title: 'DESTEK ÜRÜNLERİ',
                  screenWidth: screenWidth,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildStoreItemCard(
                  context: context,
                  title: 'Can Takviyesi',
                  subtitle: 'Oyuna devam etmek için 1 can al.',
                  icon: Icons.favorite,
                  iconBackgroundColor: Colors.red.shade400,
                  buttonText: '20 Coin',
                  onPressed: () => buyHeart(userData),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void buyHeart(UserDataProvider userData) async {
    if (userData.hearts >= 5) {
      _showSnackBar('Can sayınız zaten maksimum!', isError: true);
      return;
    }
    if (userData.coins >= 20) {
      await userData.updateCoins(userData.coins - 20);
      await userData.updateHearts(userData.hearts + 1);
      _showSnackBar('1 can satın alındı!');
    } else {
      _showSnackBar('Yeterli coininiz yok!', isError: true);
    }
  }

  void getDailyGift(UserDataProvider userData) async {
    if (userData.dailyGiftTaken) {
      _showSnackBar('Günlük hediye zaten alındı!', isError: true);
      return;
    }
    await userData.updateCoins(userData.coins + 50);
    await userData.updateDailyGiftTaken(true);
    final now = DateTime.now();
    await userData.updateLastDailyGiftTime(now);
    _nextGiftTime = now.add(const Duration(hours: 24));
    _startTimer();
    _showSnackBar('Günlük 50 coin hediye kazandın!');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }


  Widget _buildSectionHeader({
    required String title,
    required double screenWidth,
  }) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.blue.shade100,
        fontWeight: FontWeight.bold,
        fontSize: screenWidth * 0.045,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildHeaderStats(UserDataProvider userData, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.05,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatIcon(
            Icons.monetization_on,
            userData.coins.toString(),
            Colors.amber,
            screenWidth,
          ),
          _buildStatIcon(
            Icons.favorite,
            userData.hearts.toString(),
            Colors.redAccent,
            screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildStatIcon(
    IconData icon,
    String value,
    Color color,
    double screenWidth,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: screenWidth * 0.08),
        SizedBox(width: screenWidth * 0.02),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.06,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyGiftCard(
    UserDataProvider userData,
    double screenWidth,
    double screenHeight,
  ) {
    bool isGiftTaken = userData.dailyGiftTaken;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      color: isGiftTaken ? Colors.grey.shade800 : const Color(0xFF4CAF50),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Icon(
              isGiftTaken ? Icons.lock_clock : Icons.card_giftcard,
              color: Colors.white,
              size: screenWidth * 0.1,
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              isGiftTaken ? 'HEDİYE ALINDI' : 'GÜNLÜK HEDİYEN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              isGiftTaken
                  ? 'Yeni hediye için kalan süre:'
                  : 'Ücretsiz 50 Coin seni bekliyor!',
              style: TextStyle(
                color: Colors.white.withAlpha(230),
                fontSize: screenWidth * 0.04,
              ),
              textAlign: TextAlign.center,
            ),
            if (isGiftTaken)
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.01),
                child: Text(
                  _remainingTime > Duration.zero
                      ? _formatDuration(_remainingTime)
                      : "Yenileniyor...",
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: isGiftTaken ? null : () => getDailyGift(userData),
              style: ElevatedButton.styleFrom(
                backgroundColor: isGiftTaken
                    ? Colors.grey.shade600
                    : Colors.yellow.shade700,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1,
                  vertical: screenHeight * 0.015,
                ),
              ),
              child: Text(
                isGiftTaken ? 'ALINDI' : 'HEMEN AL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreItemCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBackgroundColor,
    required String buttonText,
    required VoidCallback onPressed,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      color: Colors.white.withAlpha(26), 
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: screenWidth * 0.06),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.003),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.025),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.045,
                  vertical: screenHeight * 0.014,
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
