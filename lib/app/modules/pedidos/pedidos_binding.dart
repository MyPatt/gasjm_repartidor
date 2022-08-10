  
import 'package:gasjm/app/modules/pedidos/pedidos_controller.dart';
import 'package:get/get.dart';

class PedidosBinding implements Bindings {
@override
void dependencies() {
   
  Get.lazyPut(() => PedidosController());
  }
}