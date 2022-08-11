import 'package:gasjm/app/data/controllers/usuario_controller.dart';
import 'package:gasjm/app/modules/inicio/inicio_controller.dart';
import 'package:get/get.dart';

class InicioBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InicioController());

    Get.lazyPut(() => UsuarioController());
  }
}
