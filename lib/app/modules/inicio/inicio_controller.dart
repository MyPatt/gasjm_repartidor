import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gasjm/app/core/utils/map_style.dart';
import 'package:gasjm/app/data/models/persona_model.dart';
import 'package:gasjm/app/data/models/usuario_model.dart';
import 'package:gasjm/app/data/repository/pedido_repository.dart';
import 'package:gasjm/app/data/repository/persona_repository.dart';
import 'package:gasjm/app/data/repository/usuario_repository.dart';
import 'package:gasjm/app/global_widgets/dialogs/dialogs.dart';
import 'package:gasjm/app/modules/inicio/widgets/ir_content.dart';
import 'package:gasjm/app/modules/inicio/widgets/navegacion_content.dart';
import 'package:gasjm/app/routes/app_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InicioController extends GetxController {
  //Variables

  final Map<MarkerId, Marker> _markers = {};

  Set<Marker> get markers => _markers.values.toSet();

  //
  final _markersController = StreamController<String>.broadcast();
  Stream<String> get onMarkerTap => _markersController.stream;
  late StreamSubscription<Position> streamSubscription;

  @override
  void onInit() {
    _cargarDatosIniciales();
    getLocation();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    _markersController.close();
    streamSubscription.cancel();
  }

  /* DATOS DEL USUARIO */
  /* Variables para obtener datos del usuario */
  //Repositorio de usuario

  //
  Rx<PersonaModel?> usuario = Rx(null);
  Future<void> _getUsuarioActual() async {
    usuario.value = await _personaRepository.getUsuario();
  }

  void _cargarDatosIniciales() {
    _getUsuarioActual();
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
      if (index == 2) {
        _cargarPedidosPage();
        print(2);
      }
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

  _cargarPedidosPage() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      Get.offNamed(AppRoutes.pedidos);
    } catch (e) {
      print(e);
    }
  }
  /* MAPA PARA LA OPCION DE EXPLORACION*/

  //Cambiar el estilo de mapa
  onMapaCreated(GoogleMapController controller) {
    controller.setMapStyle(estiloMapa);
    //
    //Cargar marcadores
    _cargarMarcadorRepartidor();
    _cargarMarcadoresPedidos();
  }

  //Ubicacion actual
  Future<LocationData?> currentLocation() async {
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

  Future<void> cargarMarcadorRepartidor(LatLng posicion) async {
    //Actualizar las posiciones del mismo marker la cedula del usuario conectado como ID
    final id = usuario.value?.cedulaPersona ?? 'MakerIdRepartidor';
    //
    final markerId = MarkerId(id);

    //Marcador repartidor personalizado
    BitmapDescriptor _markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/icons/gpsrepartidor.png",
    );
    final marker = Marker(
      markerId: markerId,
      position: posicion,
      draggable: false,
      icon: _markerbitmap,
    );
    _markers[markerId] = marker;

    print("REPARTIDOR\n");
  }

  //Marcadores para visualizar los pedidos
  final _pedidoRepository = Get.find<PedidoRepository>();
  final _personaRepository = Get.find<PersonaRepository>();

  Future<void> _cargarMarcadoresPedidos() async {
    //Marcador pedido
    BitmapDescriptor _marcadorPedido = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/icons/marcadorpedido.png",
    );
//Actualizar las posiciones del mismo marker la cedula del usuario conectado como ID

    //
    final listaPedidos = await _pedidoRepository.getPedidos();
    print(listaPedidos?.length);

    listaPedidos?.forEach((element) async {
      final nombreCliente = await _personaRepository.getNombresPersonaPorCedula(
          cedula: element.idCliente);
      print(nombreCliente);
      //final id = element.idCliente;
      final id = _markers.length.toString();
      print("- $id\n");
      final markerId = MarkerId(id);
      final posicion =
          LatLng(element.direccion.latitud, element.direccion.longitud);

      final marker = Marker(
          markerId: markerId,
          position: posicion,
          draggable: false,
          icon: _marcadorPedido,
          infoWindow: InfoWindow(
              title: nombreCliente,
              snippet:
                  'Para ${element.diaEntregaPedido},  ${element.cantidadPedido} cilindro/s de gas.',
              onTap: () {
               
              }));
      _markers[markerId] = marker;
    });
  }

  

  //** EXPLORAR MAPA  */
  final posicionInicial = const LatLng(-0.2053476, -79.4894387).obs;
  final posicionMarcadorCliente = const LatLng(-0.2053476, -79.4894387).obs;
  final posicionPedido = const LatLng(-0.2053476, -79.4894387).obs;

  //Obtener ubicacion
  getLocation() async {
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
    streamSubscription =
        Geolocator.getPositionStream().listen((Position posicion) {
      posicionInicial.value = LatLng(posicion.latitude, posicion.longitude);
    });
  }

  void _cargarMarcadorRepartidor() {
    //Marcador cliente
    posicionMarcadorCliente.value = posicionInicial.value;

//Actualizar las posiciones del mismo marker la cedula del usuario conectado como ID
    final id = usuario.value?.cedulaPersona ?? 'MakerIdRepartidor';
//
    final markerId = MarkerId(id);
    // marcadores.add(Marker(
    final marker = Marker(
      markerId: markerId,
      position: posicionMarcadorCliente.value,
      draggable: false,
      //212.2
      icon: BitmapDescriptor.defaultMarkerWithHue(208),
      /*onDragEnd: (newPosition) {
          // ignore: avoid_print
          posicionMarcadorCliente.value = newPosition;
          _getDireccionXLatLng(posicionMarcadorCliente.value);
        }*/
    );
    _markers[markerId] = marker;
    //
  }
}
