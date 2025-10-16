import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data_provider.dart';
import 'home_screen.dart';

class GameSettingsScreen extends StatelessWidget {
  const GameSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    final double horizontalPadding = screenWidth * 0.04;
    final double topPadding = screenHeight * 0.15;
    final double cardVerticalPadding = screenHeight * 0.01;
    final double cardToButtonSpacing = screenHeight * 0.04;
    final double buttonHeight = screenHeight * 0.06;
    final double listItemFontSize = screenWidth * 0.042;
    final double iconSize = screenWidth * 0.065;

    final userData = context.watch<UserDataProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Oyun Ayarları',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            horizontalPadding,
          ),
          child: Column(
            children: [
              Card(
                elevation: 4,
                color: Colors.white.withAlpha(25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: cardVerticalPadding),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          userData.isSoundOn
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: Colors.white,
                          size: iconSize,
                        ),
                        title: Text(
                          'Ses Efektleri',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: listItemFontSize,
                          ),
                        ),
                        trailing: Switch(
                          value: userData.isSoundOn,
                          onChanged: (value) {
                            userData.updateSoundSetting(value);
                          },
                          activeColor: Colors.tealAccent,
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.vibration,
                          color: Colors.white,
                          size: iconSize,
                        ),
                        title: Text(
                          'Titreşim',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: listItemFontSize,
                          ),
                        ),
                        trailing: Switch(
                          value: userData.isVibrationOn,
                          onChanged: (value) {
                            userData.updateVibrationSetting(value);
                          },
                          activeColor: Colors.tealAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: cardToButtonSpacing),
              ElevatedButton.icon(
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                label: const Text(
                  'Oyundan Çık',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  minimumSize: Size.fromHeight(buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  bool? confirmExit = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Emin misin?'),
                      content: const Text(
                        'Devam edersen 1 kalp kaybedeceksin!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('Devam Et'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text(
                            'Çık',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (!context.mounted) return;

                  if (confirmExit == true) {
                    await userData.updateHearts(userData.hearts - 1);

                    if (!context.mounted) return;

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
