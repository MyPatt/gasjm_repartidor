import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gasjm/app/core/utils/mensajes.dart';
import 'package:gasjm/app/data/models/persona_model.dart';
import 'package:gasjm/app/data/repository/persona_repository.dart';
import 'package:gasjm/app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class IdentificacionController extends GetxController {
  final _userRepository = Get.find<PersonaRepository>();
  //
  Rx<PersonaModel?> usuario = Rx(null);
  //Controller para texto de la cedula
  final cedulaTextoController = TextEditingController();
  //
  final cargando = RxBool(false);
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

//Guardar cedula de forma local
  _guardarCedula() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("cedula_usuario", cedulaTextoController.text);
  }

  //
  _guardarCorreo(String correo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("correo_usuario", correo);
  }

//Buscar si tiene cuenta o no
  /*Future<void> ggetUsuarioPorCedula() async {
    usuario.value =
        await _userRepository.getPersonaPorCedula(cedula: cedulaTextoController.text);
  }
*/
//
  cargarPerfil() async {
    final cedula;

    try {
      cargando.value = true;
      await Future.delayed(const Duration(seconds: 1));
 
      usuario.value = await _userRepository.getPersonaPorCedula(
          cedula: cedulaTextoController.text);
      cedula = usuario.value?.cedulaPersona.isEmpty;

      if (cedula == null) {
        //En caso de no encontrar el numero de cedula, continuar a la pagina de registro
        _guardarCedula();

        Get.offNamed(AppRoutes.registrar);
      } else {
        //Cedula ya registrada ir a la pagina de inicio de sesion
        if (usuario.value?.idPerfil.toLowerCase() == "repartidor") {
          _guardarCorreo(usuario.value?.correoPersona ?? cedula);

          Mensajes.showGetSnackbar(
              titulo: 'Informaci??n',
              mensaje:
                  'C??dula ya registrada, ingrese su contrase??a para iniciar sesi??n o cree una nueva cuenta  con una c??dula diferente.',
              duracion: const Duration(seconds: 7),
              icono: const Icon(
                Icons.info_outlined,
                color: Colors.white,
              ));

          Get.offNamed(AppRoutes.login);
        } else {
          Mensajes.showGetSnackbar(
              titulo: 'Alerta',
              mensaje:
                  'C??dula ya registrada como cliente, instale la aplicaci??n  o ingrese una c??dula diferente para  iniciar sesi??n.',
              duracion: const Duration(seconds: 7),
              icono: const Icon(
                Icons.error_outline_outlined,
                color: Colors.white,
              ));
        }
      }
    } on FirebaseException catch (e) {
      Mensajes.showGetSnackbar(
              titulo: 'Alerta',
              mensaje:
                  'Ha ocurrido un error, por favor int??ntelo de nuevo m??s tarde',
              duracion: const Duration(seconds: 7),
              icono: const Icon(
                Icons.error_outline_outlined,
                color: Colors.white,
              ));
    }
    cargando.value = false;
  }

   void onChangedIdentificacion(valor) {
  
    if (valor.length > 9) {
    cedulaTextoController.text = valor;
    }
  }
} 