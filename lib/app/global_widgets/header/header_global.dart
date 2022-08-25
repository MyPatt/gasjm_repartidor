import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gasjm/app/core/theme/app_theme.dart';

class HeaderGlobal extends StatelessWidget {
  const HeaderGlobal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("icons/camiongas.svg"),
          RichText(
            text: TextSpan(
              text: "Gas",
              style: Theme.of(context).textTheme.headline4?.copyWith(
                  color: AppTheme.blueDark, fontWeight: FontWeight.w900),
              children: [
                TextSpan(
                  text: "J&M",
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
