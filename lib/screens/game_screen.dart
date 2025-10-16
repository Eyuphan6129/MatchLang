import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_data_provider.dart';
import '../services/sound_manager.dart';
import 'game_settings_screen.dart';
import 'home_screen.dart';
import 'star_screen.dart';

class RankUpDialog extends StatelessWidget {
  const RankUpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataProvider>();
    const starScreenInstance = StarScreen();
    final rankInfo = starScreenInstance.getRankInfo(userData.stars);

    final rankName = rankInfo['name'] as String;
    final rankIcon = rankInfo['icon'] as IconData;
    final rankColor = rankInfo['color'] as Color;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.06),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [rankColor.withAlpha(200), Colors.black.withAlpha(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: rankColor, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(rankIcon, color: Colors.white, size: screenWidth * 0.15),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'RÜTBE ATLADIN!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Yeni rütben:',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.04,
                color: Colors.white70,
              ),
            ),
            Text(
              rankName,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(backgroundColor: rankColor),
              child: Text(
                'Süper!',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelCompleteDialog extends StatelessWidget {
  final int levelCompleted;
  final int coinsEarned;
  final bool starEarned;

  const LevelCompleteDialog({
    super.key,
    required this.levelCompleted,
    required this.coinsEarned,
    required this.starEarned,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.06),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.teal.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.tealAccent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tebrikler!',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              '$levelCompleted. Seviye Tamamlandı',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.045,
                color: Colors.white70,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              child: const Divider(color: Colors.white24),
            ),
            Text(
              'Kazandığın Ödüller',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.04,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/coin.png',
                  width: screenWidth * 0.08,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  '+$coinsEarned',
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.w600,
                    color: Colors.amberAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            if (starEarned)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/star.png',
                    width: screenWidth * 0.08,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    '+1',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w600,
                      color: Colors.yellowAccent,
                    ),
                  ),
                ],
              ),
            SizedBox(height: screenHeight * 0.03),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (starEarned) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const RankUpDialog(),
                  );
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.tealAccent),
              child: Text(
                'Harika!',
                style: GoogleFonts.poppins(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final int level;
  final int wordLevel;
  final Future<void> Function(int nextLevel)? onLevelComplete;

  const GameScreen({
    super.key,
    required this.level,
    required this.wordLevel,
    this.onLevelComplete,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Map<String, String>> allWords = [];
  List<String> englishWords = [];
  List<String> turkishWords = [];
  String? selectedEnglish;
  String? selectedTurkish;
  List<Map<String, String>> matchedPairs = [];
  int lives = 3;

  void _vibrate({bool isError = false}) {
    final userData = context.read<UserDataProvider>();
    if (userData.isVibrationOn) {
      if (isError) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    lives = 3;
    loadWordsFromJson();
  }

  Future<void> loadWordsFromJson() async {
    final String response = await rootBundle.loadString(
      'assets/data/words.json',
    );
    final data = json.decode(response);
    final List<dynamic> wordsList = data['words'];

    final filteredWords = wordsList
        .where((word) => word['level'] == widget.wordLevel)
        .map<Map<String, String>>(
          (e) => {'en': e['en'] as String, 'tr': e['tr'] as String},
        )
        .toList();

    filteredWords.shuffle();

    if (!mounted) return;
    setState(() {
      allWords = filteredWords.take(6).toList();
      englishWords = allWords.map((e) => e['en']!).toList()..shuffle();
      turkishWords = allWords.map((e) => e['tr']!).toList()..shuffle();
      matchedPairs.clear();
      selectedEnglish = null;
      selectedTurkish = null;
    });
  }

  void matchWords() async {
    if (selectedEnglish != null && selectedTurkish != null) {
      final soundManager = context.read<SoundManager>();
      final userData = context.read<UserDataProvider>();

      Map<String, String>? correctPair;
      try {
        correctPair = allWords.firstWhere(
          (pair) => pair['en'] == selectedEnglish,
        );
      } catch (e) {
        correctPair = null;
      }

      if (correctPair != null && correctPair['tr'] == selectedTurkish) {
        soundManager.playSuccessSound();
        _vibrate(isError: false);
        userData.recordAnswer(true);
        setState(() {
          matchedPairs.add(correctPair!);
          selectedEnglish = null;
          selectedTurkish = null;
        });
        if (matchedPairs.length == 6) {
          await showWinDialog();
        }
      } else {
        soundManager.playFailSound();
        _vibrate(isError: true);
        userData.recordAnswer(false);
        setState(() {
          lives--;
          selectedEnglish = null;
          selectedTurkish = null;
        });
        if (lives == 0) {
          await showGameOverDialog();
        }
      }
    }
  }

  Future<void> showWinDialog() async {
    final userData = context.read<UserDataProvider>();
    final bool isActiveLevel = widget.level == userData.currentLevel;
    final int coinsEarned = isActiveLevel ? 20 : 10;
    final bool starEarned = isActiveLevel && ((widget.level) % 10 == 0);
    if (widget.onLevelComplete != null) {
      await widget.onLevelComplete!(widget.level + 1);
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => LevelCompleteDialog(
        levelCompleted: widget.level,
        coinsEarned: coinsEarned,
        starEarned: starEarned,
      ),
    );
  }

  Future<void> showGameOverDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final dialogNavigator = Navigator.of(dialogContext);
        final mainNavigator = Navigator.of(context);

        return AlertDialog(
          title: const Text('Oyun Bitti'),
          content: const Text(
            '3 hakkınızı kullandınız. Devam etmek için 20 coin harcayabilirsiniz.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final userData = context.read<UserDataProvider>();
                await userData.updateHearts(userData.hearts - 1);

                if (!mounted) return;

                dialogNavigator.pop();
                mainNavigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('Çık'),
            ),
            TextButton(
              onPressed: () {
                final userData = context.read<UserDataProvider>();
                if (userData.coins >= 20) {
                  userData.updateCoins(userData.coins - 20);
                  setState(() {
                    lives = 2;
                    dialogNavigator.pop();
                  });
                }
              },
              child: const Text('20 Coin Harca & Devam Et'),
            ),
          ],
        );
      },
    );
  }

  void _shuffleWords() {
    _vibrate();
    setState(() {
      englishWords.shuffle();
      turkishWords.shuffle();
    });
  }

  void _getHint() {
    _vibrate();
    final userData = context.read<UserDataProvider>();
    const int hintCost = 10;

    if (userData.coins < hintCost) {
      return;
    }

    final unmatchedPairs = allWords.where((pair) {
      return !matchedPairs.any(
        (matchedPair) => matchedPair['en'] == pair['en'],
      );
    }).toList();

    if (unmatchedPairs.isEmpty) {
      return;
    }

    userData.updateCoins(userData.coins - hintCost);
    setState(() {
      final pairToReveal = unmatchedPairs.first;
      matchedPairs.add(pairToReveal);
      selectedEnglish = null;
      selectedTurkish = null;
    });

    if (matchedPairs.length == 6) {
      showWinDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, screenWidth),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Row(
                    children: [
                      _buildWordColumn(
                        englishWords,
                        true,
                        screenWidth,
                        screenHeight,
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      _buildWordColumn(
                        turkishWords,
                        false,
                        screenWidth,
                        screenHeight,
                      ),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(screenWidth, screenHeight),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, double screenWidth) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.settings, size: screenWidth * 0.09),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GameSettingsScreen()),
        ),
      ),
      title: Text(
        'Seviye ${widget.level}',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.065,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.05),
          child: Row(
            children: List.generate(
              3,
              (index) => Icon(
                Icons.favorite,
                color: index < lives
                    ? Colors.red.shade400
                    : Colors.white.withAlpha(50),
                size: screenWidth * 0.08,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordColumn(
    List<String> words,
    bool isEnglish,
    double screenWidth,
    double screenHeight,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: words.map((word) {
          final isSelected = isEnglish
              ? selectedEnglish == word
              : selectedTurkish == word;
          final isMatched = matchedPairs.any(
            (pair) => pair['en'] == word || pair['tr'] == word,
          );
          return _buildWordCard(
            word,
            isSelected,
            isMatched,
            isEnglish,
            screenWidth,
            screenHeight,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWordCard(
    String word,
    bool isSelected,
    bool isMatched,
    bool isEnglish,
    double screenWidth,
    double screenHeight,
  ) {
    Color cardColor;
    Color borderColor;

    if (isMatched) {
      cardColor = const Color.fromARGB(255, 109, 255, 114).withAlpha(100);
      borderColor = Colors.green.shade300;
    } else if (isSelected) {
      cardColor = Colors.cyan.withAlpha(100);
      borderColor = Colors.cyanAccent;
    } else {
      cardColor = Colors.white.withAlpha(30);
      borderColor = Colors.white.withAlpha(70);
    }

    return Expanded(
      child: GestureDetector(
        onTap: isMatched
            ? null
            : () {
                setState(() {
                  if (isEnglish) {
                    selectedEnglish = word;
                  } else {
                    selectedTurkish = word;
                  }
                });
                matchWords();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 5,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  word,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        screenHeight * 0.04,
        screenWidth * 0.05,
        screenHeight * 0.035,
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _getHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('İpucu (10 Coin)'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.05),
          Expanded(
            child: FilledButton.icon(
              onPressed: _shuffleWords,
              icon: const Icon(Icons.shuffle),
              label: const Text('Karıştır'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.purple.shade400,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
