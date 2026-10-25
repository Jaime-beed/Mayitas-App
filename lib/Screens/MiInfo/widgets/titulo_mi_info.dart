import 'package:flutter/material.dart';

/// Título "Mi Info".
class TituloMiInfo extends StatelessWidget {
  const TituloMiInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: Center(
        child: Text(
          'Mi Info',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(1, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
