import 'package:flutter/material.dart';
import 'package:gasjm/app/core/theme/app_theme.dart';
import 'package:gasjm/app/global_widgets/repartidor/menu_appbar.dart';
import 'package:gasjm/app/global_widgets/repartidor/menu_lateral.dart';
import 'package:gasjm/app/modules/pedidos/widgets/bottom_repartidor.dart';
import 'package:gasjm/app/modules/pedidos/widgets/aceptados_page.dart';
import 'package:gasjm/app/modules/pedidos/widgets/enespera_page copy.dart';
import 'package:gasjm/app/modules/pedidos/widgets/enespera_page.dart';

class PedidosPage extends StatelessWidget {
  const PedidosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          /*appBar: AppBar(
            backgroundColor: AppTheme.blueBackground,
            title: const Text('Pedidos'),
            automaticallyImplyLeading: false, 
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'En espera'),
                Tab(
                  text: 'Aceptados',
                ),
              ],
            ),
          ),*/
          //Menú deslizable a la izquierda con opciones del  usuario
          drawer: const MenuLateral(),
          //Barra de herramientas de opciones para  agenda y  historial
          appBar: AppBar(
            backgroundColor: AppTheme.blueBackground,
            actions: const [MenuAppBar()],
            title: const Text('Pedidos'),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'En espera'),
                Tab(
                  text: 'Aceptados',
                ),
              ],
            ),
          ),
          //Body
          body: TabBarView(
            children: [
              PedidosEnEsperaPage2(),
              PedidosAceptadosPage(),
            ],
          ),
          //Navegacion del repartidor
          bottomNavigationBar: const BottomNavigationRepartidor(),
        ));
  }
}
