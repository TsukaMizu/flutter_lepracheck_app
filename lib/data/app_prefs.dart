import 'package:hive/hive.dart';

class AppPrefs {
  static const _boxName = 'app_prefs';
  static const _keyOnboardingDone = 'onboarding_done';

  static Future<Box> _box() => Hive.openBox(_boxName);

  static Future<bool> isOnboardingDone() async {
    final box = await _box();
    return (box.get(_keyOnboardingDone, defaultValue: false) as bool?) ?? false;
  }

  static Future<void> setOnboardingDone(bool done) async {
    final box = await _box();
    await box.put(_keyOnboardingDone, done);
  }
}