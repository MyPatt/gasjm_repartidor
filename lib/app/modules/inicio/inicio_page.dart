import 'package:flutter/material.dart';
import 'package:gasjm/app/core/theme/app_theme.dart';
import 'package:gasjm/app/modules/inicio/inicio_controller.dart';
import 'package:gasjm/app/modules/inicio/widgets/bottom_repartidor.dart';
import 'package:gasjm/app/modules/inicio/widgets/menu_appbar.dart';
import 'package:gasjm/app/modules/inicio/widgets/menu_lateral.dart';
import 'package:get/get.dart';

//Pantalla de inicio del cliente
class InicioPage extends StatelessWidget {
  InicioPage({key}) : super(key: key);
  final controller = InicioController();
//
  @override
  Widget build(BuildContext context) {
  
    return GetBuilder<InicioController>(
        builder: (_) => Scaffold(
            //Menú deslizable a la izquierda con opciones del  usuario
            drawer: MenuLateral(),
            //Barra de herramientas de opciones para  agenda y  historial
            appBar: AppBar(
              backgroundColor: AppTheme.blueBackground,
              actions: const [MenuAppBar()],
              title: const Text('GasJ&M'),
            ),
            //Body
            body: Stack(children: [
              //Widget Mapa
              Positioned.fill(
                // ignore: sized_box_for_whitespace
                child: Obx(() => _.pantallasInicioRepartidor[
                    _.indexPantallaSeleccionada.value]['screen']),

                //
              )
            ]),
            //Navegacion del repartidor
            bottomNavigationBar: const BottomNavigationRepartidor()));
  }
}
