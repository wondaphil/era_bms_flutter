import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSvgIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;

  const AppSvgIcon({
    Key? key,
    required this.asset,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor =
        color ?? Theme.of(context).colorScheme.onSurface;

    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        iconColor,
        BlendMode.srcIn,
      ),
    );
  }
}