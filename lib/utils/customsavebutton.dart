import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isEnables;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isEnables = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor:
            isPrimary ? const Color(0xFF004B87) : Colors.transparent,
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF004B87),
        side: BorderSide(color: const Color(0xFF004B87), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: isEnables ? onPressed : null,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          fontSize: 14,
        ),
      ),
    );
  }
}
