import 'package:flutter/cupertino.dart'; 
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


}
