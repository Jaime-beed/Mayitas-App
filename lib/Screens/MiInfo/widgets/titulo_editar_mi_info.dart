import 'package:flutter/material.dart';

/// Título "Editar perfil".
class TituloEditarMiInfo extends StatelessWidget {
  const TituloEditarMiInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          'Editar perfil',
          style: TextStyle(
            fontSize: 30,
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
