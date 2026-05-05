import 'package:rxdart/subjects.dart';

class AppController {
  AppController._();
  static final AppController instance = AppController._();

  final BehaviorSubject<bool> loading = BehaviorSubject.seeded(false);

  void initialise() async {}
}
