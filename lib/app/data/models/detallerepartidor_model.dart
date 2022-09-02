
class DetalleRepartidor {
    DetalleRepartidor({
         this.idDetalleRepartidor,
        required this.idRepartidor,
        required this.idEstadoRepartidor,
    });

    final String? idDetalleRepartidor;
    final String idRepartidor;
    final String idEstadoRepartidor;

    factory DetalleRepartidor.fromMap(Map<String, dynamic> json) => DetalleRepartidor(
        idDetalleRepartidor: json["idDetalleRepartidor"],
        idRepartidor: json["idRepartidor"],
        idEstadoRepartidor: json["idEstadoRepartidor"],
    );

    Map<String, dynamic> toMap() => {
        "idDetalleRepartidor": idDetalleRepartidor,
        "idRepartidor": idRepartidor,
        "idEstadoRepartidor": idEstadoRepartidor,
    };
}
