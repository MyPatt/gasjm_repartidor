import 'package:flutter/material.dart';
import 'package:gasjm/app/modules/inicio/inicio_controller.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ExplorarMapa extends StatelessWidget {
  const ExplorarMapa({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InicioController>(
        builder: (_) => FutureBuilder<LocationData?>(
            future: _.currentLocation(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapchat) {
              if (snapchat.hasData) {
                final LocationData currentLocation = snapchat.data;
                _.cargarMarcadorRepartidor(LatLng(
                    currentLocation.latitude!, currentLocation.longitude!));

                // _.cargarMarcadoresPedidos();
                return GoogleMap(
                  onMapCreated: _.onMapaCreated,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(currentLocation.latitude!,
                          currentLocation.longitude!),
                      zoom: 15),
                  markers: _.markers,
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
                );
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }
}
