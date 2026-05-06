import 'package:rxdart/subjects.dart';
import 'package:web/web.dart';

class AppController {
  AppController._();
  static final AppController instance = AppController._();

  static const String _usernameStorageKey = 'username';

  final BehaviorSubject<bool> loading = BehaviorSubject.seeded(false);

  void initialise() async {}

  void showDeveloperProfile() {
    window.open('https://github.com/uncoded-decimal', '_blank');
  }

  void setCurrentUsername(String username) =>
      window.sessionStorage.setItem(_usernameStorageKey, username);
  String getCurrentUsername() =>
      window.sessionStorage.getItem(_usernameStorageKey) ?? '';
}
