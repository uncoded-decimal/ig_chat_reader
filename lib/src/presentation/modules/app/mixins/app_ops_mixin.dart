import 'package:ig_chat_reader/src/presentation/modules/app/controllers/app_controller.dart';

mixin AppOpsMixin {
  void setGlobalLoading(bool loading) =>
      AppController.instance.loading.sink.add(loading);
}
