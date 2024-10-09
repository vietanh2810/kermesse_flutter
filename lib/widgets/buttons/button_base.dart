import 'package:flutter/material.dart';

class ButtonBase extends StatelessWidget{
  final String text;
  final VoidCallback onPressed;

  const ButtonBase({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(5, 93, 153, 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white
          ),
        ),
      ),
    );
  }
}