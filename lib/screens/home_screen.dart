import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'game_screen.dart';
import 'settings_screen.dart';
import 'store_screen.dart';
import 'stats_screen.dart';
import 'wheel_screen.dart';
import 'heart_screen.dart';
import 'star_screen.dart';

import '../models/user_data_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _heartTimer;
  final int heartIntervalMinutes = 10;
  bool _isInitialScrollPerformed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupHeartTimer();
    });
  }

  @override
  void dispose() {
    _heartTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupHeartTimer() {
    final userData = context.read<UserDataProvider>();
    if (userData.lastHeartTime == null) {
      userData.updateLastHeartTime(DateTime.now());
    }
    _heartTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateHeartStatus();
    });
  }

  void _updateHeartStatus() {
    if (!mounted) return;
    final userData = context.read<UserDataProvider>();
    if (userData.lastHeartTime == null || userData.hearts >= 5) {
      return;
    }
    final now = DateTime.now();
    final diff = now.difference(userData.lastHeartTime!);
    int minutesPassed = diff.inMinutes;
    int heartsToAdd = minutesPassed ~/ heartIntervalMinutes;
    if (heartsToAdd > 0) {
      final newHearts = (userData.hearts + heartsToAdd).clamp(0, 5);
      final newTime = userData.lastHeartTime!.add(
        Duration(minutes: heartsToAdd * heartIntervalMinutes),
      );
      userData.updateHeartsAndLastTime(newHearts, newTime);
    }
  }

  int getWordLevel(int level) {
    if (level <= 10) return 1;
    if (level <= 20) return 2;
    if (level <= 30) return 3;
    if (level <= 40) return 5;
    if (level <= 50) return 6;
    if (level <= 60) return 7;
    if (level <= 70) return 8;
    if (level <= 80) return 9;
    if (level <= 90) return 10;
    if (level <= 100) return 11;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double topSectionHeight = screenHeight * 0.16;

    return Consumer<UserDataProvider>(
      builder: (context, userData, child) {
        if (userData.userId != null && !_isInitialScrollPerformed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              final double itemHeight = (screenWidth * 0.26) + 36;

              final double viewportHeight =
                  _scrollController.position.viewportDimension;
              double centerOffset = (userData.currentLevel + 1) * itemHeight;
              centerOffset =
                  centerOffset - (viewportHeight / 2) + (itemHeight / 2);

              final double maxScroll =
                  _scrollController.position.maxScrollExtent;
              final double finalOffset = centerOffset.clamp(0.0, maxScroll);
              _scrollController.jumpTo(finalOffset);
              _isInitialScrollPerformed = true;
            }
          });
        }
        return Scaffold(
          body: SafeArea(
            top: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: topSectionHeight),
                  child: Center(
                    child: SizedBox(
                      width: screenWidth * 0.3,
                      child: NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowIndicator();
                          return true;
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 100, top: 20),
                          reverse: true,
                          itemCount: 100,
                          itemBuilder: (context, index) {
                            final level = index + 1;
                            final isActive = level == userData.currentLevel;
                            final isPlayable = level <= userData.currentLevel;
                            final isPreview =
                                level > userData.currentLevel &&
                                level <= userData.currentLevel + 3;
                            final isBossLevel = level % 10 == 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: GestureDetector(
                                onTap: isPlayable
                                    ? () {
                                        if (userData.hearts <= 0) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Canınız bitti. Lütfen mağazadan can satın alın.',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => GameScreen(
                                              level: level,
                                              wordLevel: getWordLevel(level),
                                              onLevelComplete:
                                                  (nextLevel) async {
                                                    if (isActive &&
                                                        nextLevel >
                                                            userData
                                                                .currentLevel) {
                                                      await userData
                                                          .updateCurrentLevel(
                                                            nextLevel,
                                                          );
                                                    }
                                                    final coinsToAdd = isActive
                                                        ? 20
                                                        : 10;
                                                    await userData.updateCoins(
                                                      userData.coins +
                                                          coinsToAdd,
                                                    );
                                                  },
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Container(
                                  width: screenWidth * 0.22,
                                  height: screenWidth * 0.26,
                                  decoration: BoxDecoration(
                                    color: isBossLevel
                                        ? Colors.red.shade500
                                        : (isActive
                                              ? Colors.green
                                              : (isPlayable
                                                    ? Colors.blue
                                                    : (isPreview
                                                          ? Colors.grey.shade600
                                                          : Colors
                                                                .grey
                                                                .shade800))),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(50),
                                        blurRadius: 4,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: (isPlayable || isPreview)
                                        ? Text(
                                            '$level',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.08,
                                              fontWeight: FontWeight.bold,
                                              color: isBossLevel
                                                  ? Colors.white
                                                  : Colors.white.withAlpha(
                                                      (isPlayable ? 255 : 153),
                                                    ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.lock,
                                            color: Colors.white.withAlpha(178),
                                            size: screenWidth * 0.08,
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: topSectionHeight - 1,
                  left: 0,
                  right: 0,
                  child: Container(height: 2),
                ),
                Positioned(
                  top: screenHeight * 0.05,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.015,
                    ),
                    child: buildTopButtonsRow(
                      user,
                      context,
                      screenWidth,
                      userData,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.26,
                  right: screenWidth * 0.03,
                  child: Column(
                    children: [
                      buildSideButton(
                        context,
                        screenWidth,
                        imagePath: 'assets/images/store.png',
                        label: 'Mağaza',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StoreScreen(),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      buildSideButton(
                        context,
                        screenWidth,
                        imagePath: 'assets/images/stats.png',
                        label: 'İstatistik',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StatsScreen(),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      buildSideButton(
                        context,
                        screenWidth,
                        imagePath: 'assets/images/spin.png',
                        label: 'Çark Çevir',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WheelScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTopButtonsRow(
    User? user,
    BuildContext context,
    double screenWidth,
    UserDataProvider userData,
  ) {
    final List<Map<String, dynamic>> buttonData = [
      {
        "icon": "assets/images/coin.png",
        "value": userData.coins,
        "route": "store",
      },
      {
        "icon": "assets/images/heart.png",
        "value": userData.hearts,
        "route": "heart",
      },
      {
        "icon": "assets/images/star.png",
        "value": userData.stars,
        "route": "star",
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...buttonData.map((data) {
          final bool isCoinButton = data["route"] == "store";
          final double buttonWidth = isCoinButton
              ? screenWidth * 0.28
              : screenWidth * 0.20;
          final double iconSize = isCoinButton ? 32 : 28;

          Border? buttonBorder;
          if (data["route"] == "store") {
            buttonBorder = Border.all(color: Colors.amber.shade600, width: 2.5);
          } else if (data["route"] == "heart") {
            buttonBorder = Border.all(color: Colors.red.shade400, width: 2.5);
          } else if (data["route"] == "star") {
            buttonBorder = Border.all(
              color: Colors.yellow.shade700,
              width: 2.5,
            );
          }

          return GestureDetector(
            onTap: () {
              if (data["route"] == "store") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StoreScreen()),
                );
              } else if (data["route"] == "heart") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HeartScreen()),
                );
              } else if (data["route"] == "star") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StarScreen()),
                );
              }
            },
            child: Container(
              width: buttonWidth,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: buttonBorder,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(data["icon"], width: iconSize, height: iconSize),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Center(
                      child: Text(
                        data["value"].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );

            if (result == true && mounted && _scrollController.hasClients) {
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.blue.shade400, width: 2.5),
            ),
            child: ClipOval(
              child: userData.avatarPath != null
                  ? Image.asset(
                      userData.avatarPath!,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    )
                  : (user != null && user.photoURL != null
                        ? Image.network(user.photoURL!, fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              user?.displayName
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  '?',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.orange,
                              ),
                            ),
                          )),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSideButton(
    BuildContext context,
    double screenWidth, {
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    final double buttonSize = screenWidth * 0.17;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
