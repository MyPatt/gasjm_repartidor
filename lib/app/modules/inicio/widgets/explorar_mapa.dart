import 'package:flutter/material.dart'; 
import 'package:gasjm/app/modules/inicio/inicio_controller.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExplorarMapa extends StatelessWidget {
  const ExplorarMapa({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = InicioController();
    //Evento en el marcker clic
    controller.onMarkerTap.listen((id) {
      print("solo por probar $id");
    });
    //
    return GetBuilder<InicioController>(
        builder: (_) => Obx(
              () => _.posicionInicial.value ==
                      const LatLng(-0.2053476, -79.4894387)
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      markers: _.markers,
                      onMapCreated: _.onMapaCreated,
                      initialCameraPosition: CameraPosition(
                          target: _.posicionInicial.value, zoom: 15),
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      zoomControlsEnabled: false,
                      zoomGesturesEnabled: true,
                      mapToolbarEnabled: false,
                      trafficEnabled: false,
                      tiltGesturesEnabled: false,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: false,
                      myLocationEnabled: true,
                      liteModeEnabled: false,
                      indoorViewEnabled: false,
                    ),
            ));
  }
}
//TODO: Boton para regresar a la ubicacion inicial