import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_data_provider.dart';
import 'avatar_selection_screen.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;
    await context.read<UserDataProvider>().signOutAndReload();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _resetProgress(BuildContext context) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("İlerlemeyi Sıfırla"),
        content: const Text(
          "Tüm ilerlemeniz (seviye, coin, can vb.) kalıcı olarak silinecek. Emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Sıfırla"),
          ),
        ],
      ),
    );

    if (shouldReset != true || !context.mounted) return;

    await context.read<UserDataProvider>().resetProgress();
    if (!context.mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.04,
            kToolbarHeight + screenHeight * 0.05,
            screenWidth * 0.04,
            screenWidth * 0.04,
          ),
          children: [
            _buildSectionHeader('Hesap', screenWidth),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: _buildAccountSection(
                context,
                userData,
                screenWidth,
                screenHeight,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildSectionHeader('Oyun Ayarları', screenWidth),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: userData.isSoundOn
                        ? Icons.volume_up
                        : Icons.volume_off,
                    title: 'Ses Efektleri',
                    trailing: Switch(
                      value: userData.isSoundOn,
                      onChanged: (value) => userData.updateSoundSetting(value),
                      activeColor: Colors.teal,
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: screenWidth * 0.04,
                    endIndent: screenWidth * 0.04,
                  ),
                  _buildSettingsTile(
                    icon: Icons.vibration,
                    title: 'Titreşim',
                    trailing: Switch(
                      value: userData.isVibrationOn,
                      onChanged: (value) =>
                          userData.updateVibrationSetting(value),
                      activeColor: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildSectionHeader('Diğer', screenWidth),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.restore,
                    title: 'İlerlemeyi Sıfırla',
                    onTap: () => _resetProgress(context),
                  ),
                  if (userData.userId != 'guest_user') ...[
                    Divider(
                      height: 1,
                      indent: screenWidth * 0.04,
                      endIndent: screenWidth * 0.04,
                    ),
                    _buildSettingsTile(
                      icon: Icons.logout,
                      title: 'Çıkış Yap',
                      color: Colors.red.shade700,
                      onTap: () => _signOut(context),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    UserDataProvider userData,
    double screenWidth,
    double screenHeight,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isGuest = userData.userId == 'guest_user';

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.075,
                backgroundImage: userData.avatarPath != null
                    ? AssetImage(userData.avatarPath!) as ImageProvider
                    : (!isGuest && user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null),
                backgroundColor: Colors.grey.shade400,
                child:
                    (userData.avatarPath == null &&
                        (isGuest || user?.photoURL == null))
                    ? Icon(
                        isGuest ? Icons.person_off : Icons.person,
                        size: screenWidth * 0.08,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest
                          ? 'Misafir Kullanıcı'
                          : (user?.displayName ?? 'Kullanıcı'),
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isGuest && user?.email != null) ...[
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        user!.email!,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AvatarSelectionScreen()),
            ),
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(screenHeight * 0.055),
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black87,
            ),
            child: const Text('Avatar Değiştir'),
          ),
          if (isGuest) ...[
            SizedBox(height: screenHeight * 0.015),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('İlerlemeyi Kaydetmek İçin Giriş Yap'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(screenHeight * 0.055),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              onPressed: () => Navigator.of(context).pushNamed('/login'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.02,
        bottom: screenWidth * 0.02,
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey.shade600),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
