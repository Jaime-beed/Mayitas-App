import 'package:flutter/material.dart';

/// Medallón con uno de los dibujos del diseño.
class MedallonImagen extends StatelessWidget {
  const MedallonImagen({super.key, required this.archivo, this.tamano = 58});

  final String archivo;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: tamano,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tamano / 2),
        child: Image.asset(
          archivo,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
