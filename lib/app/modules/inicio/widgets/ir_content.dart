// screen_b.dart
import 'package:flutter/material.dart';
import 'package:gasjm/app/modules/inicio/inicio_controller.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class IniciarRecorridoRepartidor extends StatelessWidget {
  const IniciarRecorridoRepartidor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InicioController>(
        builder: (_) => FutureBuilder<LocationData?>(
            future: _.currentLocation(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapchat) {
              print(snapchat.hasData);
              if (snapchat.hasData) {
                final LocationData currentLocation = snapchat.data;
                /*  _.cargarMarcadorRepartidor(LatLng(
                    currentLocation.latitude!, currentLocation.longitude!));
*/
                return GoogleMap(
                  onMapCreated: _.onMapaCreated,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(currentLocation.latitude!,
                          currentLocation.longitude!),
                      zoom: 15),
                  markers: _.markers,
                  myLocationButtonEnabled: false,
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
