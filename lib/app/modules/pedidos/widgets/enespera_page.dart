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

class PedidosEnEsperaPage2 extends StatelessWidget {
  PedidosEnEsperaPage2({Key? key}) : super(key: key);
  final PedidosController gameController = Get.put(PedidosController());

  Future<void> _showMyDialog(BuildContext context, String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Data'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Would you like to remove data ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                overlayColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 244, 117, 108)),
              ),
              child: const Text('Remove'),
              onPressed: () => _onDeleteData(context, id),
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pullRefresh() async {
    gameController.readGame();
  }

  Future<void> _onDeleteData(BuildContext context, String id) async {
    gameController.deleteGame(id);
    Navigator.of(context).pop();
  }

  Future<void> _onEdit(int id) async {
    /* gameController.id.value = id;
    gameController.toEditPage();*/
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: _pullRefresh,
        child: Stack(
          children: [
            Column(
              children: [
                Text(
                  'Data Game',
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  child: Expanded(
                    child: ListView(
                      children: gameController.dataGame.map((e) {
                        var index = gameController.dataGame.indexOf(e);
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
                                          _showMyDialog(context, e.idPedido);
                                          /* _buildShowDialog(
                          context, controller.rechzarPedido(pedido.idPedido));*/
                                        }),
                                    ButtonSmall(
                                      texto: "Aceptar",
                                      onPressed: () =>gameController.aceptarPedido(e.idPedido),
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
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.add),
                  onPressed: () {
                    //   Get.to(() => AddGamePage());
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
