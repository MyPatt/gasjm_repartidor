import 'dart:async';

import 'package:gasjm/app/data/models/persona_model.dart';
import 'package:gasjm/app/data/repository/persona_repository.dart';
import 'package:get/get.dart';

class UsuarioController extends GetxController {
  final _personaRepository = Get.find<PersonaRepository>();

  //Para obtener datos del usuario conectado

  Rx<PersonaModel?> usuario = Rx(null);
  @override
  void onInit() {
    _getUsuarioActual();
    
    super.onInit();
  }

  /* METODOS PARA OBTENER DATOS DEL USUARIO */

  Future<void> _getUsuarioActual() async {
    usuario.value = await _personaRepository.getUsuario();
  }
}
