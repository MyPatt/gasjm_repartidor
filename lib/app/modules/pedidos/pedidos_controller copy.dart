import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gasjm/app/core/theme/app_theme.dart';
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

  final RxList<PedidoModel> _pedidosenespera = <PedidoModel>[].obs;
  RxList<PedidoModel> get listaPedidosEnEspera => _pedidosenespera;

  final RxList<PedidoModel> _pedidosAceptados = <PedidoModel>[].obs;
  RxList<PedidoModel> get pedidosAceptados => _pedidosAceptados;

  final RxList<String> _nombresClientes = <String>[].obs;
  RxList<String> get nombresClientes => _nombresClientes;

  final RxList<String> _direccionClientes = <String>[].obs;
  RxList<String> get direccionClientes => _direccionClientes;

  final RxList<String> _nombresClientesAceptados = <String>[].obs;
  RxList<String> get nombresClientesAceptados => _nombresClientesAceptados;

  final RxList<String> _direccionClientesAceptados = <String>[].obs;
  RxList<String> get direccionClientesAceptados => _direccionClientesAceptados;

  /* METODOS PROPIOS DEL CONTROLADOR*/

  @override
  void onInit() {
    super.onInit();

    _cargarListaPedidosEnEspera();
    _cargarListaPedidosAceptados();
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

  _cargarListaPedidosEnEspera() async {
    try {
      cargandoPedidosEnEspera.value = true;

      _pedidosenespera.value = (await _pedidosRepository.getPedidoPorField(
              field: 'idEstadoPedido', dato: 'estado1') ??
          []);

              _cargarNombresClienteParaPedidosEspera();
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

  //PEDIDOS EN ESPERA
Future<String> getNombresCliente( String cedula) async{
  final nombre = await _personaRepository.getNombresPersonaPorCedula(
            cedula: cedula);
            return nombre??'';
}

  Future<void> _cargarNombresClienteParaPedidosEspera() async {
    try {
      _nombresClientes.clear();
      _direccionClientes.clear();

      for (var item in _pedidosenespera) {
        final nombre = await _personaRepository.getNombresPersonaPorCedula(
            cedula: item.idCliente);
        _nombresClientes.add(nombre!);

        final direccion = await getDireccionXLatLng(
            LatLng(item.direccion.latitud, item.direccion.longitud));
        _direccionClientes.add(direccion);
      }
    } catch (e) {}
  }

  Future<void> _cargarNombresClienteParaPedidosAceptados() async {
    try {
      for (var item in _pedidosAceptados) {
        final nombre = await _personaRepository.getNombresPersonaPorCedula(
            cedula: item.idCliente);
        _nombresClientesAceptados.add(nombre!);

        final direccion = await getDireccionXLatLng(
            LatLng(item.direccion.latitud, item.direccion.longitud));
        _direccionClientesAceptados.add(direccion);
      }
    } catch (e) {}
  }

  _cargarListaPedidosAceptados() async {
    try {
      _pedidosAceptados.value = (await _pedidosRepository.getPedidoPorField(
              field: 'idEstadoPedido', dato: 'estado2')) ??
          [];
      _cargarNombresClienteParaPedidosAceptados();
    } on FirebaseException catch (e) {
      Get.snackbar(
        'Mensaje',
        e.message ?? 'Se produjo un error inesperado.',
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.blueDark,
      );
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

  Future<String> getDireccionXLatLng(LatLng posicion) async {
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

  aceptarPedido(String idPedido) async {
    try {
      _pedidosRepository.updateEstadoPedido(
          idPedido: idPedido, estadoPedido: "estado2");

      Mensajes.showGetSnackbar(
          titulo: "Mensaje",
          mensaje: "Pedido aceptado con éxito,",
          icono: const Icon(
            Icons.check_circle_outline_outlined,
            color: Colors.white,
          ),
          duracion: const Duration(seconds: 1));
  
  
      _cargarListaPedidosEnEspera();
      _cargarListaPedidosAceptados();

 
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

  rechzarPedido(String idPedido) async {
    try {
      _pedidosRepository.updateEstadoPedido(
          idPedido: idPedido, estadoPedido: "estado3");

      Mensajes.showGetSnackbar(
          titulo: "Mensaje",
          mensaje: "Pedido rechazado con éxito,",
          icono: const Icon(
            Icons.check_circle_outline_outlined,
            color: Colors.white,
          ),
          duracion: const Duration(seconds: 1));
      print(_pedidosenespera.length);
      print(_pedidosAceptados.length);
      _cargarListaPedidosAceptados();
      _cargarListaPedidosEnEspera();

      print("Actualizado \n");
      print(_pedidosenespera.length);
      print(_pedidosAceptados.length);
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
}
