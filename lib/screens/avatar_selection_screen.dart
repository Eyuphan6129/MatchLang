import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_data_provider.dart';

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  final List<String> avatarPaths = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
    'assets/avatars/avatar6.png',
    'assets/avatars/avatar7.png',
    'assets/avatars/avatar8.png',
    'assets/avatars/avatar9.png',
    'assets/avatars/avatar10.png',
    'assets/avatars/avatar11.png',
    'assets/avatars/avatar12.png',
    'assets/avatars/avatar13.png',
    'assets/avatars/avatar14.png',
    'assets/avatars/avatar15.png',
    'assets/avatars/avatar16.png',
    'assets/avatars/avatar17.png',
    'assets/avatars/avatar18.png',
  ];

  String? _selectedAvatarPath;

  @override
  void initState() {
    super.initState();
    _selectedAvatarPath = context.read<UserDataProvider>().avatarPath;
  }

  @override
  Widget build(BuildContext context) {
    final initialAvatarPath = context.watch<UserDataProvider>().avatarPath;

    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final double screenPadding = screenWidth * 0.04;
    final double gridSpacing = screenWidth * 0.04;
    final double buttonVerticalPadding = screenHeight * 0.02;
    final double buttonFontSize = screenWidth * 0.045;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Avatarını Seç',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(screenPadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                ),
                itemCount: avatarPaths.length,
                itemBuilder: (context, index) {
                  final avatar = avatarPaths[index];
                  final isSelected = _selectedAvatarPath == avatar;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarPath = avatar;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: isSelected
                            ? Border.all(color: Colors.amberAccent, width: 3)
                            : Border.all(color: Colors.transparent, width: 3),
                      ),
                      child: Card(
                        elevation: 8,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(avatar, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenPadding,
                screenPadding,
                screenPadding,
                screenPadding + MediaQuery.of(context).padding.bottom / 2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: buttonVerticalPadding,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'İptal',
                        style: GoogleFonts.poppins(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: gridSpacing),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          vertical: buttonVerticalPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          (_selectedAvatarPath != null &&
                              _selectedAvatarPath != initialAvatarPath)
                          ? () {
                              context.read<UserDataProvider>().updateAvatarPath(
                                _selectedAvatarPath!,
                              );
                              Navigator.pop(context);
                            }
                          : null,
                      child: Text(
                        'Kaydet',
                        style: GoogleFonts.poppins(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
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
  }
}
