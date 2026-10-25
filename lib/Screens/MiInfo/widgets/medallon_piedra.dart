import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../estilo/paleta_mi_info.dart';

/// Medallón circular de piedra tallada que enmarca un icono o un glifo.
class MedallonPiedra extends StatelessWidget {
  const MedallonPiedra({super.key, required this.child, this.tamano = 54});

  /// Icono o glifo que va grabado dentro del medallón.
  final Widget child;

  /// Diámetro del medallón.
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _PintorMedallon(),
      child: SizedBox.square(
        dimension: tamano,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(tamano * 0.18),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _PintorMedallon extends CustomPainter {
  const _PintorMedallon();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centro = size.center(Offset.zero);
    final double r = size.shortestSide / 2;

    // Disco de piedra con relieve.
    canvas.drawCircle(
      centro,
      r * 0.96,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PaletaMiInfo.piedraBrillo,
            PaletaMiInfo.piedra,
            PaletaMiInfo.piedraOscura,
          ],
        ).createShader(Offset.zero & size),
    );

    // Aro dorado.
    canvas.drawCircle(
      centro,
      r * 0.96,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.10
        ..color = PaletaMiInfo.oro.withValues(alpha: 0.8),
    );

    // Hueco hundido donde va el glifo.
    canvas.drawCircle(centro, r * 0.74, Paint()..color = PaletaMiInfo.jadeOscuro);
    canvas.drawCircle(
      centro,
      r * 0.74,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07
        ..color = PaletaMiInfo.piedraOscura.withValues(alpha: 0.6),
    );

    // Cuatro muescas talladas alrededor.
    final Paint muesca = Paint()
      ..color = PaletaMiInfo.piedraBrillo.withValues(alpha: 0.75);
    for (int i = 0; i < 4; i++) {
      final double angulo = math.pi / 4 + i * math.pi / 2;
      canvas.drawCircle(
        Offset(
          centro.dx + math.cos(angulo) * r * 0.86,
          centro.dy + math.sin(angulo) * r * 0.86,
        ),
        r * 0.055,
        muesca,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorMedallon anterior) => false;
}
