import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gasjm/app/core/theme/app_theme.dart';
import 'package:gasjm/app/core/theme/text_theme.dart';
import 'package:gasjm/app/data/models/pedido_model.dart';
import 'package:gasjm/app/global_widgets/button_small.dart';
import 'package:gasjm/app/global_widgets/dialogs/dialogs.dart';
import 'package:gasjm/app/global_widgets/text_description.dart';
import 'package:gasjm/app/global_widgets/text_subtitle.dart';
import 'package:gasjm/app/modules/pedidos/pedidos_controller.dart';
import 'package:get/get.dart';

class PedidosEnEsperaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PedidosController>(
        builder: (_) => Obx(() => _.cargando.value == true
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(slivers: <Widget>[
                /* SliverList(
                    delegate: SliverChildListDelegate(
                        _buildList(_.listaLength.value, _)))*/
                SliverList(
                    delegate: SliverChildListDelegate(_buildListPedidosEnEspera(
                        _.pedidosenespera,
                        _.nombresClientes,
                        _.direccionClientes,
                        _,
                        context))),
              ])));
  }

  List<Widget> _buildList(
      int count, PedidosController pedidosController, BuildContext context) {
    /*  List<Widget> listItems = [];
    for (int i = 0; i < count; i++) {
      listItems.add(Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextButton(
              onPressed: () {
                pedidosController.listaLength.value = 2;
                 
              },
              child: Text('Sliver Item $i',
                  style: const TextStyle(fontSize: 22.0)))));
    }*/
    List<Widget> listItems = _buildListPedidosEnEspera(
        pedidosController.pedidosenespera,
        pedidosController.nombresClientes,
        pedidosController.direccionClientes,
        pedidosController,
        context);
    return listItems;
  }

  List<Widget> _buildListPedidosEnEspera(
      List<PedidoModel> lista,
      List<String>? nombresClientes,
      List<String>? direccionClientes,
      PedidosController pedidosController,
      BuildContext context) {
    List<Widget> listItemsPedidosEnEspera = [];
    try {
      for (int i = 0; i < lista.length; i++) {
        listItemsPedidosEnEspera.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: _cardPedido(lista[i], nombresClientes?[i],
                direccionClientes?[i], pedidosController, context)));
      }
    } catch (e) {
      // print(e);
    }
    return listItemsPedidosEnEspera;
  }

  Widget _cardPedido(PedidoModel pedido, nombreCliente, direccionCliente,
      PedidosController controller, BuildContext context) {
    return Card(
      shape: Border.all(color: AppTheme.light, width: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextSubtitle(
                  text: nombreCliente.toString(),
                  style: TextoTheme.subtitleStyle2,
                ),
                TextSubtitle(
                    text: pedido.cantidadPedido.toString(),
                    style: TextoTheme.subtitleStyle2)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextDescription(text: direccionCliente.toString()),
                const TextDescription(text: '5 min')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextDescription(text: pedido.diaEntregaPedido),
                const TextDescription(text: '300m')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonSmall(
                    texto: "Rechazar",
                    color: AppTheme.light,
                    onPressed: () {
                      _buildShowDialog(
                          context, controller.rechzarPedido(pedido.idPedido));
                    }),
                ButtonSmall(
                    texto: "Aceptar",
                    onPressed: () {
                      controller.aceptarPedido(pedido.idPedido);
                    })
              ],
            ),
          ],
        ),
      ),
    );
  }

   _buildShowDialog(BuildContext context, Function() rechazar) {
    return Dialogs.alert(context,
        titulo: "Rechazar",
        contenido: "¿Está seguro que quiere rechazar el pedido?",
        opcion2: CupertinoDialogAction(
          child: const Text("Si",
              style: TextStyle(
                color: AppTheme.blueBackground,
              )),
          onPressed: rechazar,
        ));
    // opcionesTexto: ["Cancelar", "Rechazar"]);
  }
}
//TODO: Modulo de Pedidos (En espera page, funcion rechazar)
//TODO: Gestionar pedidos como repartidor 2 (Pedidos en espera loaddata) >ultimo push ~filtros, funciones botones, optimizar loaddatos