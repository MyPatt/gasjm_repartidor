import 'package:flutter/material.dart';
import 'package:gasjm/app/core/theme/app_theme.dart';
import 'package:gasjm/app/core/theme/text_theme.dart';
import 'package:gasjm/app/core/utils/responsive.dart';
import 'package:gasjm/app/global_widgets/button_small.dart';
import 'package:gasjm/app/global_widgets/text_description.dart';
import 'package:gasjm/app/global_widgets/text_subtitle.dart';
import 'package:gasjm/app/modules/pedidos/pedidos_controller.dart';
import 'package:get/get.dart';

class PedidosEnEsperaPage extends StatelessWidget {
  PedidosEnEsperaPage({Key? key}) : super(key: key);
  final PedidosController controladorDePedidos = Get.put(PedidosController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: _pullRefrescar,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          DropdownButton(
                              icon: const Icon(Icons.filter_alt_outlined,
                                  color: AppTheme.light),
                              value: controladorDePedidos
                                  .valorSeleccionadoItemDeFiltro.value,
                              items: _buildDropdownMenu(
                                  controladorDePedidos.dropdownItemsDeFiltro),
                              onChanged: (String? value) {
                                controladorDePedidos
                                    .valorSeleccionadoItemDeFiltro
                                    .value = value ?? "";
                              }),
                          DropdownButton(
                              icon: const Icon(Icons.arrow_drop_down_outlined,
                                  color: AppTheme.light),
                              value: controladorDePedidos
                                  .valorSeleccionadoItemDeOrdenamiento.value,
                              items: _buildDropdownMenu(controladorDePedidos
                                  .dropdownItemsDeOrdenamiento),
                              onChanged: (String? value) {
                                controladorDePedidos
                                    .valorSeleccionadoItemDeOrdenamiento
                                    .value = value ?? "";
                              }),
                          IconButton(
                            padding: const EdgeInsets.all(0.0),
                            alignment: Alignment.centerRight,
                            icon: const Icon(
                                Icons.check_box_outline_blank_outlined,
                                color: AppTheme.light),
                            onPressed: () {},
                          ),
                        ]),
                  ),
                  SizedBox(
                      height: Responsive.getScreenSize(context).height * .02),
                  Expanded(
                    child: ListView(
                      children:
                          controladorDePedidos.listaPedidosEnEspera.map((e) {
                        var index = controladorDePedidos.listaPedidosEnEspera
                            .indexOf(e);
                        index++;

                        return Card(
                          shape: Border.all(color: AppTheme.light, width: 0.5),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    TextSubtitle(
                                      text: e.nombreUsuario ?? 'Cliente',
                                      style: TextoTheme.subtitleStyle2,
                                    ),
                                    TextSubtitle(
                                        text: e.cantidadPedido.toString(),
                                        style: TextoTheme.subtitleStyle2)
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    TextDescription(
                                        text: e.direccionUsuario ??
                                            'Sin ubicación'),
                                    const TextDescription(text: '5 min')
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    TextDescription(text: e.diaEntregaPedido),
                                    const TextDescription(text: '300m')
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ButtonSmall(
                                        texto: "Rechazar",
                                        color: AppTheme.light,
                                        onPressed: () {
                                          _showDialogoParaRechazar(
                                              context, e.idPedido);
                                          /* _buildShowDialog(
                          context, controller.rechzarPedido(pedido.idPedido));*/
                                        }),
                                    ButtonSmall(
                                      texto: "Aceptar",
                                      onPressed: () => controladorDePedidos
                                          .aceptarPedidoEnEspera(e.idPedido),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 3,
              right: 5,
              child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  tooltip: "Agregar un pedido",
                  child: const Icon(
                    Icons.add_outlined,
                    color: AppTheme.blueBackground,
                  ),
                  onPressed: () {
                    //   Get.to(() => AddGamePage());
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDialogoParaRechazar(BuildContext context, String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const TextSubtitle(
            text: 'Rechazar pedido',
            textAlign: TextAlign.justify,
            style: TextoTheme.subtitleStyle2,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                TextDescription(text: '¿Está seguro de rechazar el pedido?')
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
                'Si ',
                style: TextStyle(
                  color: AppTheme.blueBackground,
                ),
              ),
              onPressed: () => _onrechazarPedidoEnEspera(context, id),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pullRefrescar() async {
    controladorDePedidos.cargarListaPedidosEnEspera();
  }

  Future<void> _onrechazarPedidoEnEspera(
      BuildContext context, String id) async {
    controladorDePedidos.rechazarPedidoEnEspera(id);
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
