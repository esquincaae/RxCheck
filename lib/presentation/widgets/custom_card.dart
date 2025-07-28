import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color borderColor;
  final Color backgroundColor;
  final double? height;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 15,
    this.borderColor = const Color(0xFFE0E3E7),
    this.backgroundColor = Colors.white,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: borderColor),
          ),
          color: backgroundColor,
          child: child,
        ),
      ),
    );
  }
}
