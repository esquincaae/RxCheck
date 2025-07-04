import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;
  final double? height;
  final double borderRadius;

  const CustomCard({
    super.key,
    this.onTap,
    this.backgroundColor = const Color(0xFFF1F4F8),
    this.borderColor = Colors.blue,
    required this.child,
    this.height,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Card(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: borderColor, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
