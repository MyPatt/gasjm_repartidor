import 'package:flutter/material.dart';
import 'package:gasjm/app/core/theme/app_theme.dart';
import 'package:gasjm/app/modules/inicio/inicio_controller.dart';
import 'package:get/get.dart';

class BottomNavigationRepartidor extends StatelessWidget {
  const BottomNavigationRepartidor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InicioController>(
      builder: (_) => Obx((() => BottomNavigationBar(
            currentIndex: _.indexPantallaSeleccionada.value,
            selectedItemColor: AppTheme.blueBackground,
            unselectedItemColor: Colors.black38,
            selectedLabelStyle: const TextStyle(color: Colors.black38),
            onTap: (index) {
              _.pantallaSeleccionadaOnTap(index, context);
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.room_outlined,
                  ),
                  label: 'Explorar'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.mode_of_travel_outlined),
                  label: "Ir ",
                  backgroundColor: AppTheme.blueBackground),
              BottomNavigationBarItem(
                  icon: Icon(Icons.list_outlined), label: "Pedidos ")
            ],
          ))),
    );
  }
}
