import 'package:rxdart/subjects.dart';

extension RxdartExtension<T> on BehaviorSubject<T> {
  Future<T> waitUntilValue({T? waitForValue}) async {
    while (!hasValue || (waitForValue != null && waitForValue != valueOrNull)) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return value;
  }
}
