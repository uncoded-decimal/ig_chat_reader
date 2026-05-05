import 'package:rxdart/subjects.dart';
import 'package:web/web.dart';

class AppController {
  AppController._();
  static final AppController instance = AppController._();

  final BehaviorSubject<bool> loading = BehaviorSubject.seeded(false);

  void initialise() async {}

  void showDeveloperProfile() {
    window.open('https://github.com/uncoded-decimal', '_blank');
  }
}
