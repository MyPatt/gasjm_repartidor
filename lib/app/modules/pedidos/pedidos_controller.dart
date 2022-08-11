import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:gasjm/app/core/utils/mensajes.dart';
import 'package:gasjm/app/data/models/pedido_model.dart';
import 'package:gasjm/app/data/repository/pedido_repository.dart';
import 'package:gasjm/app/data/repository/persona_repository.dart';
import 'package:gasjm/app/modules/inicio/widgets/ir_content.dart';
import 'package:gasjm/app/modules/inicio/widgets/navegacion_content.dart';
import 'package:gasjm/app/routes/app_routes.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PedidosController extends GetxController {
  /* VARIABLES*/
  final _pedidosRepository = Get.find<PedidoRepository>();
  final _personaRepository = Get.find<PersonaRepository>();

  final cargandoPedidosEnEspera = true.obs;
  final cargandoPedidosAceptados = true.obs;

  //RxList<PedidoModel> dataGame = <PedidoModel>[].obs;
  final RxList<PedidoModel> _listaPedidosEnEspera = <PedidoModel>[].obs;
  RxList<PedidoModel> get listaPedidosEnEspera => _listaPedidosEnEspera;

  final RxList<PedidoModel> _listaPedidosAceptados = <PedidoModel>[].obs;
  RxList<PedidoModel> get listaPedidosAceptados => _listaPedidosAceptados;

  /* METODOS PROPIOS DEL CONTROLADOR*/

  @override
  void onInit() {
    cargarListaPedidosEnEspera();
    cargarListaPedidosAceptados();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /* METODOS PARA PEDIDOS EN ESPERA */

  void cargarListaPedidosEnEspera() async {
    try {
      cargandoPedidosEnEspera.value = true;
      final lista = (await _pedidosRepository.getPedidoPorField(
              field: 'idEstadoPedido', dato: 'estado1')) ??
          [];

      //
      for (var i = 0; i < lista.length; i++) {
        final nombre = await _getNombresCliente(lista[i].idCliente);
        final direccion = await _getDireccionXLatLng(
            LatLng(lista[i].direccion.latitud, lista[i].direccion.longitud));
        lista[i].nombreUsuario = nombre;
        lista[i].direccionUsuario = direccion;
      }

      _listaPedidosEnEspera.value = lista;
    } on FirebaseException catch (e) {
      Mensajes.showGetSnackbar(
          titulo: "Error",
          mensaje: "Se produjo un error inesperado.",
          icono: const Icon(
            Icons.error_outline_outlined,
            color: Colors.white,
          ));
    }
    cargandoPedidosEnEspera.value = false;
  }

  Future<String> _getNombresCliente(String cedula) async {
    final nombre =
        await _personaRepository.getNombresPersonaPorCedula(cedula: cedula);
    return nombre ?? '';
  }

  void rechazarPedidoEnEspera(String idPedido) async {
    try {
      await _pedidosRepository.updateEstadoPedido(
          idPedido: idPedido, estadoPedido: "estado3");

      cargarListaPedidosEnEspera();
    } on FirebaseException catch (e) {
      Mensajes.showGetSnackbar(
          titulo: "Error",
          mensaje: "Se produjo un error inesperado.",
          icono: const Icon(
            Icons.error_outline_outlined,
            color: Colors.white,
          ));
    }
  }

  aceptarPedidoEnEspera(String idPedido) async {
    try {
      _pedidosRepository.updateEstadoPedido(
          idPedido: idPedido, estadoPedido: "estado2");

      cargarListaPedidosEnEspera();
      cargarListaPedidosAceptados();

      Mensajes.showGetSnackbar(
          titulo: "Mensaje",
          mensaje: "Pedido aceptado con éxito,",
          icono: const Icon(
            Icons.check_circle_outline_outlined,
            color: Colors.white,
          ),
          duracion: const Duration(seconds: 1));
    } on FirebaseException catch (e) {
      Mensajes.showGetSnackbar(
          titulo: "Error",
          mensaje: "Se produjo un error inesperado.",
          icono: const Icon(
            Icons.error_outline_outlined,
            color: Colors.white,
          ),
          duracion: const Duration(seconds: 2));
    }
  }

  /* METODOS PARA PEDIDOS ACEPATADOS */

  void cargarListaPedidosAceptados() async {
    try {
      cargandoPedidosAceptados.value = true;
      final lista = (await _pedidosRepository.getPedidoPorField(
              field: 'idEstadoPedido', dato: 'estado2')) ??
          [];

      //
      for (var i = 0; i < lista.length; i++) {
        final nombre = await _getNombresCliente(lista[i].idCliente);
        final direccion = await _getDireccionXLatLng(
            LatLng(lista[i].direccion.latitud, lista[i].direccion.longitud));
        lista[i].nombreUsuario = nombre;
        lista[i].direccionUsuario = direccion;
      }

      _listaPedidosAceptados.value = lista;
    } on FirebaseException catch (e) {
      Mensajes.showGetSnackbar(
          titulo: "Error",
          mensaje: "Se produjo un error inesperado.",
          icono: const Icon(
            Icons.error_outline_outlined,
            color: Colors.white,
          ));
    }
    cargandoPedidosAceptados.value = false;
  }

  void actualizarEstadoPedidoAceptado(String idPedido, String estado, [void showGetSnackbar]
    ) async {
    try {
      await _pedidosRepository.updateEstadoPedido(
          idPedido: idPedido, estadoPedido: estado);

      cargarListaPedidosAceptados();

      showGetSnackbar;
    } on FirebaseException catch (e) {
      Mensajes.showGetSnackbar(
          titulo: "Error",
          mensaje: "Se produjo un error inesperado.",
          icono: const Icon(
            Icons.error_outline_outlined,
            color: Colors.white,
          ));
    }
  }

  String _getDireccion(Placemark lugar) {
    //
    if (lugar.subLocality?.isEmpty == true) {
      return lugar.street.toString();
    } else {
      return '${lugar.street}, ${lugar.subLocality}';
    }
  }

  Future<String> _getDireccionXLatLng(LatLng posicion) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(posicion.latitude, posicion.longitude);
    Placemark lugar = placemark[0];

//
    return _getDireccion(lugar);
  }

  /* MANEJO DE PANTALLA POR NAVEGACION BOTTOM*/
  RxInt indexPantallaSeleccionada = 0.obs;
  final List pantallasInicioRepartidor = [
    {"screen": const ExplorarRepartidorPage()},
    {"screen": const IniciarRecorridoRepartidor()},
    //  {"screen": const PedidosPage()},
    {"screen": const Center(child: CircularProgressIndicator())},
  ];

//Metodo que escucha el onTap de las pantallas
  pantallaSeleccionadaOnTap(int index, BuildContext context) {
    if (indexPantallaSeleccionada.value == 0) {
      _cargarExplorarPage();
    }
    if (indexPantallaSeleccionada.value == 2 && index == 2) {
    } else {
      if (indexPantallaSeleccionada.value == 2) {
        Navigator.pop(context);
      }
      indexPantallaSeleccionada.value = index;
    }
  }

  _cargarExplorarPage() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      Get.offNamed(AppRoutes.inicio);
    } catch (e) {
      print(e);
    }
  }
}
