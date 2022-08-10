import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gasjm/app/core/utils/map_style.dart';
import 'package:gasjm/app/data/controllers/usuario_controller.dart';
import 'package:gasjm/app/data/models/persona_model.dart';
import 'package:gasjm/app/data/repository/pedido_repository.dart';
import 'package:gasjm/app/data/repository/persona_repository.dart';
import 'package:gasjm/app/modules/inicio/widgets/ir_content.dart';
import 'package:gasjm/app/modules/inicio/widgets/navegacion_content.dart';
import 'package:gasjm/app/routes/app_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InicioController extends GetxController {
  /* VARIABLES */

  //Repositorios

  final _pedidoRepository = Get.find<PedidoRepository>();
  final _personaRepository = Get.find<PersonaRepository>();

  //Para obtener datos del usuario conectado

  Rx<PersonaModel?> usuario = Rx(null);
  final _controladorUsuario = Get.find<UsuarioController>();

  //Manejo de pantallas a traves del bottomnavigation

  RxInt indexPantallaSeleccionada = 0.obs;
  final List listaPantallasBottomNavigation = [
    {"screen": const ExplorarRepartidorPage()},
    {"screen": const IniciarRecorridoRepartidor()},
    {"screen": const Center(child: CircularProgressIndicator())},
  ];

  //Marcadores para el mapa del explorador

  final Map<MarkerId, Marker> _marcadoresParaExplorar = {};
  Set<Marker> get marcadoresParaExplorar =>
      _marcadoresParaExplorar.values.toSet();

  final _controladorDelMarcador = StreamController<String>.broadcast();

  Stream<String> get onMarcadorTap => _controladorDelMarcador.stream;
  late StreamSubscription<Position> _streamSubscripcion;

  //Posiciones de los marcadores
  final posicionInicialRepartidor = const LatLng(-0.2053476, -79.4894387).obs;
  final posicionMarcadorRepartidor = const LatLng(-0.2053476, -79.4894387).obs;

/*METODOS PROPIOS DEL CONTROLADOR */

  @override
  void onInit() {
    super.onInit();
    _cargarDatosIniciales();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    _controladorDelMarcador.close();
    _streamSubscripcion.cancel();
  }

/*METODO PARA CARGAR DATOS DE INICIO */
  void _cargarDatosIniciales() {
    _getUsuarioActual();
    _getLocalizacionActual();
  }

  /* METODOS PARA OBTENER DATOS DEL USUARIO */
  _getUsuarioActual() {
    usuario.value = _controladorUsuario.usuario.value;
    //   usuario.value = await _personaRepository.getUsuario();
  }

  /*METODO PARA  MANEJO DE PANTALLA POR NAVEGACION BOTTOM*/

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
      if (index == 2) {
        _cargarPedidosPage();
      }
    }
  }

  _cargarExplorarPage() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      Get.offNamed(AppRoutes.inicio);
    } catch (e) {}
  }

  _cargarPedidosPage() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      Get.offNamed(AppRoutes.pedidos);
    } catch (e) {}
  }

  /*METODOS  PARA MAPA EXPLORAR*/

  onMapaCreated(GoogleMapController controller) {
    //Cambiar el estilo de mapa
    controller.setMapStyle(estiloMapa);

    //Cargar marcadores
    _cargarMarcadorRepartidor();
    _cargarMarcadoresPedidos();
  }

  //Ubicacion actual
  Future<LocationData?> getUbicacionActual() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    Location location = Location();

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

//Cargar los pedidos en espera y aceptados
  Future<void> _cargarMarcadoresPedidos() async {
    //Icono para el marcador pedido en espera
    BitmapDescriptor _marcadorPedido = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/icons/marcadorpedido.png",
    );

    //Icono para el marcador pedido aceptado
    BitmapDescriptor _marcadorPedido2 = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/icons/marcadorpedido2.png",
    );

    //Marcador auxiliar
    BitmapDescriptor auxMarcador = _marcadorPedido;

    //Obtener la lista de los pedidos en espera y aceptados
    final listaPedidos = await _pedidoRepository.getPedidos();

    listaPedidos?.forEach((elemento) async {
      final nombreCliente = await _personaRepository.getNombresPersonaPorCedula(
          cedula: elemento.idCliente);

      final id = _marcadoresParaExplorar.length.toString();

      final markerId = MarkerId(id);
      final posicion =
          LatLng(elemento.direccion.latitud, elemento.direccion.longitud);

      //Asignar el icono del marcador segun el tipo de estado del pedido
      if (elemento.idEstadoPedido == 'estado2') {
        auxMarcador = _marcadorPedido2;
      } else {
        auxMarcador = _marcadorPedido;
      }

      final marker = Marker(
          markerId: markerId,
          position: posicion,
          draggable: false,
          icon: auxMarcador,
          infoWindow: InfoWindow(
              title: nombreCliente,
              snippet:
                  'Para ${elemento.diaEntregaPedido.toLowerCase()},  ${elemento.cantidadPedido} cilindro/s de gas.',
              onTap: () {}));
      _marcadoresParaExplorar[markerId] = marker;
    });
  }

  //Obtener ubicacion
  _getLocalizacionActual() async {
    bool servicioHbilitado;

    LocationPermission permiso;

    //Esta habilitado el servicio?
    servicioHbilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHbilitado) {
      //si la ubicacion esta deshabilitado tieneactivarse
      await Geolocator.openLocationSettings();
      return Future.error('Servicio de ubicación deshabilitada.');
    }
    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        //Si la ubicacion sigue dehabilitado mostrar sms
        return Future.error('Permiso de ubicación denegado.');
      }
    }
    if (permiso == LocationPermission.deniedForever) {
      //Permiso denegado por siempre
      return Future.error('Permiso de ubicación denegado de forma permanente.');
    }

    //Al obtener el permiso de ubicacion se accede a las coordenadas de la posicion
    _streamSubscripcion =
        Geolocator.getPositionStream().listen((Position posicion) {
      posicionInicialRepartidor.value =
          LatLng(posicion.latitude, posicion.longitude);
    });
  }

  //Cargar el marcador del repartidor con la ubicacion actual
  _cargarMarcadorRepartidor() async {
    //Icono del marcador
    BitmapDescriptor _marcadorRepartidor =
        await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/icons/camiongasjm.png",
    );

    //Posicion del repartidor
    posicionMarcadorRepartidor.value = posicionInicialRepartidor.value;

    //Asignar el id al marcador
    final id = usuario.value?.cedulaPersona ?? 'MakerIdRepartidor';
    final markerId = MarkerId(id);

    final marker = Marker(
        markerId: markerId,
        position: posicionMarcadorRepartidor.value,
        draggable: false,
        icon: _marcadorRepartidor);

    _marcadoresParaExplorar[markerId] = marker;
  }
}
