import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? textcolor;

  const RoundedButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.margin,
    required this.color,
    required this.textcolor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25),
            margin: margin,
            child: Center(
              child: Text(
                text,
                style: TextStyle(color: textcolor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
