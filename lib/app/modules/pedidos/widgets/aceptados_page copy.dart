import 'package:flutter/material.dart';
import 'package:gasjm/app/core/theme/app_theme.dart';
import 'package:gasjm/app/core/theme/text_theme.dart';
import 'package:gasjm/app/core/utils/mensajes.dart';
import 'package:gasjm/app/core/utils/responsive.dart';
import 'package:gasjm/app/data/models/pedido_model.dart';
import 'package:gasjm/app/global_widgets/button_small.dart';
import 'package:gasjm/app/global_widgets/text_description.dart';
import 'package:gasjm/app/global_widgets/text_subtitle.dart';
import 'package:gasjm/app/modules/pedidos/pedidos_controller.dart';
import 'package:get/get.dart';

class PedidosAceptadosPage extends StatelessWidget {
  PedidosAceptadosPage({Key? key}) : super(key: key);
  final PedidosController controladorDePedidos = Get.put(PedidosController());
  double height = 0;
  @override
  Widget build(BuildContext context) {
    final _height = Responsive.getScreenSize(context).height * .02;
    height = _height;
    return Obx(() => CustomScrollView(slivers: <Widget>[
   
          SliverList(
              delegate: SliverChildListDelegate(
                  controladorDePedidos.listaPedidosAceptados.map((e) {
            var index = controladorDePedidos.listaPedidosAceptados.indexOf(e);
            index++;
            
            return _cardPedido(e, context);
          }).toList()))
        ]));
  }

  //List<Widget> _buildListPedidosEnEsperaa(List<PedidoModel> value) {}
  _buildListPedidosAceptados(
    List<PedidoModel> lista,
  ) {
    return RefreshIndicator(
        onRefresh: _pullRefrescar,
        child: Stack(children: [
          Column(children: [
            /* Text(
                  'Data Game',
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),*/
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    //Opcion para filtrar los pedidos en espera por dia
                    DropdownButton(
                        icon: const Icon(Icons.filter_alt_outlined,
                            color: AppTheme.light),
                        value: controladorDePedidos
                            .valorSeleccionadoItemDeFiltro.value,
                        items: _buildDropdownMenu(
                            controladorDePedidos.dropdownItemsDeFiltro),
                        onChanged: (String? value) {
                          controladorDePedidos.valorSeleccionadoItemDeFiltro
                              .value = value ?? "";
                          //
                          controladorDePedidos
                              .cargarListaFiltradaDePedidosAceptados();
                        }),

                    //Opcion para ordenar los pedidos en espera por distintos categorias
                    DropdownButton(
                        icon: const Icon(Icons.arrow_drop_down_outlined,
                            color: AppTheme.light),
                        value: controladorDePedidos
                            .valorSeleccionadoItemDeOrdenamiento.value,
                        items: _buildDropdownMenu(
                            controladorDePedidos.dropdownItemsDeOrdenamiento),
                        onChanged: (String? value) {
                          controladorDePedidos
                              .valorSeleccionadoItemDeOrdenamiento
                              .value = value ?? "";

                          //
                          controladorDePedidos
                              .ordenarListaFiltradaDePedidosAceptados();

                          print(controladorDePedidos
                              .valorSeleccionadoItemDeOrdenamiento.value);
                        }),

                    //Cantidad de total de pedidos en espera
                    TextDescription(
                      text: controladorDePedidos
                          .listaFiltradaPedidosAceptados.length
                          .toString(),
                      textAlign: TextAlign.end,
                    ),
                    //TODO: Comprobar el ordenamiento de tiempo
                    //TODO: opcional - aceptar o rechazar pedidos seleccionados
                  ]),
            ),
            SizedBox(height: height),
            Expanded(child: ListView())
          ])
        ]));
  }

  List<Widget> _buildListPedidosAceptadoss(
      List<PedidoModel> lista, BuildContext contex) {
    List<Widget> listItemsPedidosEnEspera = [];
    for (int i = 0; i < lista.length; i++) {
      listItemsPedidosEnEspera.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: _cardPedido(lista[i], contex)));
      /* child: Text('Sliver Item ${i.toString()}',
            style: const TextStyle(fontSize: 22.0))));*/
    }
    return listItemsPedidosEnEspera;
  }

  Widget _cardPedido(PedidoModel pedido, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: Border.all(color: AppTheme.light, width: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextSubtitle(
                    text: pedido.nombreUsuario ?? 'Cliente',
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
                  TextDescription(
                      text: pedido.direccionUsuario ?? 'Sin ubicación'),
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
                      texto: "Cancelar",
                      color: AppTheme.light,
                      onPressed: () {
                        _showDialogoParaRechazar(context, pedido.idPedido);
                      }),
                  ButtonSmall(
                      texto: "Finalizar",
                      onPressed: () =>
                          controladorDePedidos.actualizarEstadoPedidoAceptado(
                              pedido.idPedido,
                              "estado5",
                              Mensajes.showGetSnackbar(
                                titulo: "Mensaje",
                                mensaje: "Pedido finalizado con éxito,",
                                icono: const Icon(
                                  Icons.check_circle_outline_outlined,
                                  color: Colors.white,
                                ),
                              )))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pullRefrescar() async {
    controladorDePedidos.cargarListaPedidosAceptados();
  }

  Future<void> _showDialogoParaRechazar(BuildContext context, String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const TextSubtitle(
            text: 'Cancelar pedido',
            textAlign: TextAlign.justify,
            style: TextoTheme.subtitleStyle2,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                TextDescription(
                    text: '¿Está seguro de cancelar la entrega del pedido?')
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: <Widget>[
            TextButton(
              child: const Text(
                'No',
                style: TextStyle(
                  color: AppTheme.light,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Si',
                style: TextStyle(
                  color: AppTheme.blueBackground,
                ),
              ),
              onPressed: () => _onCancelarEntregaPedido(context, id),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onCancelarEntregaPedido(BuildContext context, String id) async {
    controladorDePedidos.actualizarEstadoPedidoAceptado(id, "estado4");
    Navigator.of(context).pop();
  }

  List<DropdownMenuItem<String>> _buildDropdownMenu(List<String> items) {
    List<DropdownMenuItem<String>> menuItems = [];
    for (var elemento in items) {
      menuItems.add(DropdownMenuItem(
          child: TextDescription(
            text: elemento,
          ),
          value: elemento));
    }
    return menuItems;
  }
}
