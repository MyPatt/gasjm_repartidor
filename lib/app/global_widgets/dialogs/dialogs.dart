import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gasjm/app/core/theme/app_theme.dart';

abstract class Dialogs {
  static Future<void> alert(
    BuildContext context, {
    String? titulo,
    String? contenido, 
    required CupertinoDialogAction opcion2, 
  }) {
    return showCupertinoModalPopup(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: titulo != null
                  ? Text(
                      titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
              content: contenido != null ? Text(contenido) : null,
              actions: [ CupertinoDialogAction(
          child: const Text(
            "No",
            style: TextStyle(
              color: AppTheme.light,
            ),
          ),
          onPressed:()=>Navigator.pop(_),
        ),opcion2],
            ));
  }

  static List<Widget> _buildListActions(List<String> opcionesTexto) {
    List<Widget> lista = [];
    for (var element in opcionesTexto) {
      lista.add(CupertinoDialogAction(
          onPressed: () {},
          child: Text(
            element,
          )));
    }

    return lista;
  }

  static Future<void> alert2(
    BuildContext context, {
    String? title,
    String? content,
  }) {
    return showCupertinoModalPopup(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Reset settings?'),
              content: Text(
                  'This will reset your device to its default factory settings.'),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('ACCEPT'),
                ),
              ],
            ));
  }
}
