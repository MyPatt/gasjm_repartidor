import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gasjm/app/data/controllers/autenticacion_controller.dart';
import 'package:gasjm/app/data/models/detallerepartidor_model.dart';
import 'package:gasjm/app/data/models/pedido_model.dart';
import 'package:gasjm/app/data/models/persona_model.dart';
import 'package:gasjm/app/data/models/ubicacionrepartidor_model.dart';
import 'package:get/get.dart';

class PersonaProvider {
  //Instancia de firestore
  final _firestoreInstance = FirebaseFirestore.instance;

  //Par devolver el usuario actual conectado
  User get usuarioActual {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) throw Exception('Excepción no autenticada');
    return usuario;
  }

  Future<void> insertPersona({
    required PersonaModel persona,
  }) async {
    //InsertarRepartidor
        // //Ingresar datos de usuario
    final uid =
        Get.find<AutenticacionController>().autenticacionUsuario.value!.uid;

  await  _firestoreInstance.collection("persona").doc(uid).set(persona.toMap()); 

    //insertar ubicacion del repartidor
    UbicacionRepartidorModel _ubicacionRepartidorModel =
        UbicacionRepartidorModel(
      idRepartidor: persona.cedulaPersona,
      fechaUbicacionRepartidor: Timestamp.now(),
      direccionUbicacionRepartidor:
          persona.direccionPersona ?? Direccion(latitud: 0, longitud: 0),
    );

    final _resultadoUbicacion = await _firestoreInstance
        .collection('ubicacionRepartidor')
        .add(_ubicacionRepartidorModel.toMap());
    await _firestoreInstance
        .collection('ubicacionRepartidor')
        .doc(_resultadoUbicacion.id)
        .update({"idUbicacionRepartidor": _resultadoUbicacion.id});

    //insertar estado del repartidor
    DetalleRepartidor _detalle = DetalleRepartidor(
        idRepartidor: persona.cedulaPersona,
        idEstadoRepartidor: "estadoRepartidor1");

    final _resultado = await _firestoreInstance
        .collection('estadoRepartidor')
        .add(_detalle.toMap());
    await _firestoreInstance
        .collection('estadoRepartidor')
        .doc(_resultado.id)
        .update({"idDetalleRepartidor": _resultado.id});
  }

  //
  Future<void> updatePersona({required PersonaModel persona}) async {
    await _firestoreInstance
        .collection('persona')
        .doc(persona.cedulaPersona)
        .update(persona.toMap());
  }

  //
  Future<void> deletePersona({required String persona}) async {
    await _firestoreInstance.collection('persona').doc(persona).delete();
  }

  //
  Future<List<PersonaModel>?> getPersonas() async {
    final snapshot = await _firestoreInstance.collection('persona').get();

    if (snapshot.docs.isNotEmpty) {
      return (snapshot.docs)
          .map((item) => PersonaModel.fromMap(item.data()))
          .toList();
    }
    return null;
  }

  //
  Future<PersonaModel?> getPersonaPorCedula({required String cedula}) async {
    final snapshot = await _firestoreInstance
        .collection("persona")
        .where("cedula", isEqualTo: cedula)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return PersonaModel.fromMap(snapshot.docs.first.data());
    }
    return null;
  }

  Future<List<PersonaModel>?> getPersonaPorField(
      {required String field, required String dato}) async {
    final resultado = await _firestoreInstance
        .collection("persona")
        .where(field, isEqualTo: dato)
        .get();
    if ((resultado.docs.isNotEmpty)) {
      return (resultado.docs)
          .map((item) => PersonaModel.fromMap(item.data()))
          .toList();
    }
    return null;
  }

  Future<String?> getNombresPersonaPorCedula({required String cedula}) async {
    final resultado = await _firestoreInstance
        .collection("persona")
        .where("cedula", isEqualTo: cedula)
        .get();

    if (resultado.docs.isNotEmpty) {
      final nombres =
          '${resultado.docs.first.get("nombre")} ${resultado.docs.first.get("apellido")} ';
      return nombres;
    }
    return null;
  }

  //Obtner datos del usuario actual
  Future<PersonaModel?> getUsuarioActual() async {
    final snapshot = await _firestoreInstance
        .collection('persona')
        .doc(usuarioActual.uid)
        .get();
    if (snapshot.exists) {
      return PersonaModel.fromMap(snapshot.data()!);
    }
    return null;
  }
}
