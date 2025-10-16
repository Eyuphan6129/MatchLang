import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/database_helper.dart';

class UserDataProvider extends ChangeNotifier {
  String? userId;
  String? displayName;
  int coins = 200;
  int hearts = 5;
  int stars = 0;
  int currentLevel = 1;
  String? userEmail;
  String? avatarPath;
  bool dailyGiftTaken = false;
  DateTime? lastDailyGiftTime;
  DateTime? lastHeartTime;
  DateTime? lastWheelSpinTime;
  bool isSoundOn = true;
  bool isVibrationOn = true;
  int todaysCorrectAnswers = 0;
  int todaysIncorrectAnswers = 0;
  static const String guestUserId = 'guest_user';

  Future<void> _save() async {
    if (userId == null) return;
    await DatabaseHelper.instance.insertOrUpdateUserData(
      userId: userId!,
      displayName: displayName ?? 'Kullanıcı',
      coins: coins,
      hearts: hearts,
      stars: stars,
      currentLevel: currentLevel,
      dailyGiftTaken: dailyGiftTaken ? 1 : 0,
      avatar: avatarPath,
      lastDailyGiftTime: lastDailyGiftTime?.toIso8601String(),
      lastHeartTime: lastHeartTime?.toIso8601String(),
      lastWheelSpinTime: lastWheelSpinTime?.toIso8601String(),
      isSoundOn: isSoundOn,
      isVibrationOn: isVibrationOn,
    );
  }
  Future<void> load() async {
    final user = FirebaseAuth.instance.currentUser;
    String effectiveUserId;
    if (user != null) {
      effectiveUserId = user.uid;
      userId = user.uid;
      userEmail = user.email;
      displayName = user.displayName ?? 'Kullanıcı';
    } else {
      effectiveUserId = guestUserId;
      userId = guestUserId;
      userEmail = null;
    }

    final data = await DatabaseHelper.instance.getUserData(effectiveUserId);

    if (data != null) {
      coins = data['coins'] ?? 200;
      hearts = data['hearts'] ?? 5;
      stars = data['stars'] ?? 0;
      currentLevel = data['current_level'] ?? 1;
      displayName =
          data['display_name'] ?? (user == null ? 'Misafir' : 'Kullanıcı');
      dailyGiftTaken = (data['daily_gift_taken'] ?? 0) == 1;
      avatarPath = data['avatar'];
      lastDailyGiftTime = data['last_daily_gift_time'] != null
          ? DateTime.tryParse(data['last_daily_gift_time'])
          : null;
      lastHeartTime = data['last_heart_time'] != null
          ? DateTime.tryParse(data['last_heart_time'])
          : null;
      lastWheelSpinTime = data['last_wheel_spin_time'] != null
          ? DateTime.tryParse(data['last_wheel_spin_time'])
          : null;
      isSoundOn = (data['is_sound_on'] ?? 1) == 1;
      isVibrationOn = (data['is_vibration_on'] ?? 1) == 1;
    } else {
      _setDefaultValues();
      displayName = (user == null
          ? 'Misafir'
          : (user.displayName ?? 'Kullanıcı'));
      await _save(); 
    }
    await loadDailyStats();
    notifyListeners();
  }

  Future<void> mergeGuestDataToNewUser(String newUserId) async {
    final existingUserData = await DatabaseHelper.instance.getUserData(
      newUserId,
    );

    if (existingUserData != null) {
      userId = newUserId;
      await load();
      return;
    }

    if (userId == guestUserId) {
      final guestData = await DatabaseHelper.instance.getUserData(guestUserId);
      if (guestData != null) {
        final finalDisplayName =
            FirebaseAuth.instance.currentUser?.displayName ?? 'Kullanıcı';

        await DatabaseHelper.instance.insertOrUpdateUserData(
          userId: newUserId,
          displayName: finalDisplayName,
          coins: guestData['coins'],
          hearts: guestData['hearts'],
          stars: guestData['stars'],
          currentLevel: guestData['current_level'],
          dailyGiftTaken: guestData['daily_gift_taken'],
          avatar: guestData['avatar'],
          lastDailyGiftTime: guestData['last_daily_gift_time'],
          lastHeartTime: guestData['last_heart_time'],
          lastWheelSpinTime: guestData['last_wheel_spin_time'],
          isSoundOn: (guestData['is_sound_on'] ?? 1) == 1,
          isVibrationOn: (guestData['is_vibration_on'] ?? 1) == 1,
        );

        await DatabaseHelper.instance.deleteUser(guestUserId);
      }
    }
    userId = newUserId;
    await load();
  }

  void _setDefaultValues() {
    coins = 200;
    hearts = 5;
    stars = 0;
    currentLevel = 1;
    isSoundOn = true;
    isVibrationOn = true;
    dailyGiftTaken = false;
    lastDailyGiftTime = null;
    lastHeartTime = null;
    lastWheelSpinTime = null;
    avatarPath = null;
    todaysCorrectAnswers = 0;
    todaysIncorrectAnswers = 0;
  }

  Future<void> signOutAndReload() async {
    _setDefaultValues();
    userId = null;
    userEmail = null;
    displayName = null;

    await load();
  }

  Future<void> resetProgress() async {
    final originalUserId = userId;
    final originalDisplayName = displayName;
    final originalUserEmail = userEmail;

    _setDefaultValues();

    userId = originalUserId;
    displayName = originalDisplayName;
    userEmail = originalUserEmail;

    if (userId != null) {
      await _save();
    }
    notifyListeners();
  }

  Future<void> loadDailyStats() async {
    if (userId == null) return;
    final todayString = DateTime.now().toIso8601String().substring(0, 10);
    final statsData = await DatabaseHelper.instance.getDailyStats(
      userId!,
      todayString,
    );
    todaysCorrectAnswers = statsData?['correct_answers'] ?? 0;
    todaysIncorrectAnswers = statsData?['incorrect_answers'] ?? 0;
    notifyListeners();
  }

  Future<void> recordAnswer(bool wasCorrect) async {
    if (userId == null) return;
    if (wasCorrect) {
      todaysCorrectAnswers++;
    } else {
      todaysIncorrectAnswers++;
    }
    DatabaseHelper.instance.updateDailyStats(userId!, wasCorrect);
    notifyListeners();
  }

  Future<void> updateCoins(int value) async {
    coins = value;
    await _save();
    notifyListeners();
  }

  Future<void> updateHearts(int value) async {
    final oldHearts = hearts;
    final newHearts = value.clamp(0, 5);
    if (oldHearts == 5 && newHearts < 5) {
      lastHeartTime = DateTime.now();
    }
    hearts = newHearts;
    await _save();
    notifyListeners();
  }

  Future<void> updateStars(int value) async {
    stars = value;
    await _save();
    notifyListeners();
  }

  Future<void> updateCurrentLevel(int value) async {
    currentLevel = value;
    if ((currentLevel - 1) % 10 == 0 && currentLevel > 1) {
      stars = (currentLevel - 1) ~/ 10;
    }
    await _save();
    notifyListeners();
  }

  Future<void> updateDailyGiftTaken(bool value) async {
    dailyGiftTaken = value;
    await _save();
    notifyListeners();
  }

  Future<void> updateLastDailyGiftTime(DateTime value) async {
    lastDailyGiftTime = value;
    await _save();
    notifyListeners();
  }

  Future<void> updateLastHeartTime(DateTime value) async {
    lastHeartTime = value;
    await _save();
    notifyListeners();
  }

  Future<void> updateLastWheelSpinTime(DateTime value) async {
    lastWheelSpinTime = value;
    await _save();
    notifyListeners();
  }

  Future<void> updateSoundSetting(bool value) async {
    isSoundOn = value;
    await _save();
    notifyListeners();
  }

  Future<void> updateVibrationSetting(bool value) async {
    isVibrationOn = value;
    await _save();
    notifyListeners();
  }

  Future<void> updateAvatarPath(String path) async {
    avatarPath = path;
    await _save();
    notifyListeners();
  }

  Future<void> updateHeartsAndLastTime(int newHearts, DateTime newTime) async {
    hearts = newHearts.clamp(0, 5);
    lastHeartTime = newTime;
    await _save();
    notifyListeners();
  }
}
