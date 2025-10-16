import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../models/user_data_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Google giriş işlemi iptal edildi.")),
          );
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Google kimlik doğrulama tokenları eksik.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (!mounted) return;

      await context.read<UserDataProvider>().mergeGuestDataToNewUser(
        userCredential.user!.uid,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş başarısız: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('Genel hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş sırasında bilinmeyen bir hata oluştu.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    final double buttonSize = screenWidth * 0.25;
    final double logoPadding = buttonSize * 0.18;

    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : GestureDetector(
                onTap: _signInWithGoogle,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(logoPadding),
                    child: Image.asset('assets/images/google_logo.png'),
                  ),
                ),
              ),
      ),
    );
  }
}
