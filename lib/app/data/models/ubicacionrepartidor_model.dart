import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gasjm/app/data/models/pedido_model.dart';

class UbicacionRepartidorModel {
    UbicacionRepartidorModel({
         this.idUbicacionRepartidor,
        required this.idRepartidor,
        required this.fechaUbicacionRepartidor,
        required this.direccionUbicacionRepartidor,
    });

    final String? idUbicacionRepartidor;
    final String idRepartidor;
    final Timestamp fechaUbicacionRepartidor;
    final Direccion direccionUbicacionRepartidor;

    factory UbicacionRepartidorModel.fromMap(Map<String, dynamic> json) => UbicacionRepartidorModel(
        idUbicacionRepartidor: json["idUbicacionRepartidor"],
        idRepartidor: json["idRepartidor"],
        fechaUbicacionRepartidor: json["fechaUbicacionRepartidor"],
        direccionUbicacionRepartidor: Direccion.fromMap(json["direccionUbicacionRepartidor"]),
    );

    Map<String, dynamic> toMap() => {
        "idUbicacionRepartidor": idUbicacionRepartidor,
        "idRepartidor": idRepartidor,
        "fechaUbicacionRepartidor": fechaUbicacionRepartidor,
        "direccionUbicacionRepartidor": direccionUbicacionRepartidor.toMap(),
    };
}




/*
UbicacionRepartidorModel
 {
      "idUbicacionRepartidor": "", 
       
      "idRepartidor": "",
      "fechaUbicacionRepartidor":"",
      "direccionUbicacionRepartidor":{
          "latitud":"2.0",
          "longitud":"2"
      }
       
    }
*/