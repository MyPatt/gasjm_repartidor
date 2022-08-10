import 'package:flutter/material.dart';
import 'package:gasjm/app/modules/historial/historial_cliente.dart';
import 'package:gasjm/app/modules/inicio/inicio_controller.dart';
import 'package:get/get.dart';

//Barra de herramientas de opciones para la agenda y el historial
class MenuAppBar extends StatelessWidget {
  const MenuAppBar({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InicioController>(
        builder: (_) => Row(
              children: [ 
                //Opcion historial

                IconButton(
                    onPressed: () {
                      // Creamos una ruta
                      // recuerda que necesitamos del context proporcionado por el build
                      final route = MaterialPageRoute(builder: (context) {
                        return const TransactionPage();
                      });
                      // Usamos el método Navigator para ir a la página
                      // Este método requiere del contexto y la ruta
                      Navigator.push(context, route);
                    },
                    icon: const Icon(Icons.history_outlined)),
                const SizedBox(
                  width: 10,
                ),
              ],
            ));
  }
}