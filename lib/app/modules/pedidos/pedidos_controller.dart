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

  final RxList<PedidoModel> _listaFiltradaPedidosEnEspera = <PedidoModel>[].obs;
  RxList<PedidoModel> get listaFiltradaPedidosEnEspera =>
      _listaFiltradaPedidosEnEspera;

  final RxList<PedidoModel> _listaPedidosAceptados = <PedidoModel>[].obs;
  RxList<PedidoModel> get listaPedidosAceptados => _listaPedidosAceptados;

  final RxList<PedidoModel> _listaFiltradaPedidosAceptados =
      <PedidoModel>[].obs;
  RxList<PedidoModel> get listaFiltradaPedidosAceptados =>
      _listaFiltradaPedidosAceptados;

  //:TODO Pedidos aceptados (filtro diseno)

  //Lista para ordenar los pedidos por diferentes categorias

  List<String> dropdownItemsDeOrdenamiento = [
    "Ordenar por fecha",
    "Ordenar por cantidad",
    "Ordenar por tiempo",
    "Ordenar por dirección",
    "Ordenar por cliente"
  ];
  RxString valorSeleccionadoItemDeOrdenamiento = 'Ordenar por'.obs;
  RxString valorSeleccionadoItemDeOrdenamientoAceptados = 'Ordenar por'.obs;
  //Lista para filtrar los pedidos por dias

  List<String> dropdownItemsDeFiltro = [
    "Todos",
    "Ahora",
    "Mañana",
  ];
  RxString valorSeleccionadoItemDeFiltro = 'Todos'.obs;
  RxString valorSeleccionadoItemDeFiltroAceptados = 'Todos'.obs;

  /* METODOS PROPIOS DEL CONTROLADOR*/

  @override
  void onInit() {
    cargarListaPedidosEnEspera();
    valorSeleccionadoItemDeOrdenamiento.value = dropdownItemsDeOrdenamiento[0];
    valorSeleccionadoItemDeOrdenamientoAceptados.value =
        dropdownItemsDeOrdenamiento[0];
    valorSeleccionadoItemDeFiltro.value = dropdownItemsDeFiltro[0];
    valorSeleccionadoItemDeFiltroAceptados.value = dropdownItemsDeFiltro[0];
    cargarListaPedidosAceptados();
    super.onInit();
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
      //Cargar la lista filtrada al inicio todos
//      _listaFiltradaPedidosEnEspera.value = _listaPedidosEnEspera;
      cargarListaFiltradaDePedidosEnEspera();
    } on FirebaseException {
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
    } on FirebaseException {
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
    } on FirebaseException {
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

  void cargarListaFiltradaDePedidosEnEspera() {
    final filtroDia = valorSeleccionadoItemDeFiltro.value;
    final ordenarCategoria = valorSeleccionadoItemDeOrdenamiento.value;
    _cargarListaFiltradaDePedidos(_listaPedidosEnEspera,
        _listaFiltradaPedidosEnEspera, filtroDia, ordenarCategoria);
  }

  void cargarListaFiltradaDePedidosAceptados() {
    final filtroDia = valorSeleccionadoItemDeFiltroAceptados.value;
    final ordenarCategoria = valorSeleccionadoItemDeOrdenamientoAceptados.value;
    _cargarListaFiltradaDePedidos(_listaPedidosAceptados,
        _listaFiltradaPedidosAceptados, filtroDia, ordenarCategoria);
  }

  void _cargarListaFiltradaDePedidos(
      RxList<PedidoModel> listaPorFiltrar,
      RxList<PedidoModel> litaFiltrada,
      String filtroDia,
      String ordenarCategoria) {
    if (filtroDia == "Todos") {
      litaFiltrada.value = listaPorFiltrar.value;
      ordenarListaFiltradaDePedidos(litaFiltrada.value, ordenarCategoria);

      return;
    }
    List<PedidoModel> resultado = [];

    resultado = listaPorFiltrar
        .where((pedido) => pedido.diaEntregaPedido == filtroDia)
        .toList();

    litaFiltrada.value = resultado;
    ordenarListaFiltradaDePedidos(litaFiltrada.value, ordenarCategoria);
  }

  ordenarListaFiltradaDePedidosEnEspera() {
    final ordenarCategoria = valorSeleccionadoItemDeOrdenamiento.value;

    ordenarListaFiltradaDePedidos(
        _listaFiltradaPedidosEnEspera, ordenarCategoria);
  }

  ordenarListaFiltradaDePedidosAceptados() {
    final ordenarCategoria = valorSeleccionadoItemDeOrdenamientoAceptados.value;
    ordenarListaFiltradaDePedidos(
        _listaFiltradaPedidosAceptados, ordenarCategoria);
  }

  void ordenarListaFiltradaDePedidos(
      List<PedidoModel> listaFiltrada, String ordenarCategoria) {
    print(ordenarCategoria);
    if (ordenarCategoria == dropdownItemsDeOrdenamiento[0]) {
      listaFiltrada
          .sort((a, b) => a.fechaHoraPedido.compareTo(b.fechaHoraPedido));

      return;
    }

    if (ordenarCategoria == dropdownItemsDeOrdenamiento[1]) {
      listaFiltrada
          .sort((a, b) => a.cantidadPedido.compareTo(b.cantidadPedido));

      return;
    }
    if (ordenarCategoria == dropdownItemsDeOrdenamiento[2]) {
      listaFiltrada
          .sort((a, b) => a.tiempoEntrega!.compareTo(b.tiempoEntrega ?? 0));

      return;
    }
    if (ordenarCategoria == dropdownItemsDeOrdenamiento[3]) {
      listaFiltrada.sort((a, b) =>
          a.direccionUsuario!.compareTo(b.direccionUsuario.toString()));
      return;
    }
    if (ordenarCategoria == dropdownItemsDeOrdenamiento[4]) {
      listaFiltrada.sort(
          (a, b) => a.nombreUsuario!.compareTo(b.nombreUsuario.toString()));
      return;
    }
  }
  /* METODOS PARA PEDIDOS ACEPTADOS */

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
      // _listaFiltradaPedidosAceptados.value = _listaPedidosAceptados.value;
      cargarListaFiltradaDePedidosAceptados();
    } on FirebaseException {
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

  void actualizarEstadoPedidoAceptado(String idPedido, String estado,
      [void showGetSnackbar]) async {
    try {
      await _pedidosRepository.updateEstadoPedido(
          idPedido: idPedido, estadoPedido: estado);

      cargarListaPedidosAceptados();

      showGetSnackbar;
    } on FirebaseException {
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
